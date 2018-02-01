//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import "CLKArgumentParser.h"

#import "CLKArgumentManifest.h"
#import "CLKArgumentManifest_Private.h"
#import "CLKArgumentManifestValidator.h"
#import "CLKArgumentTransformer.h"
#import "CLKAssert.h"
#import "CLKError_Private.h"
#import "CLKOption.h"
#import "CLKOption_Private.h"
#import "CLKOptionGroup.h"
#import "CLKOptionGroup_Private.h"
#import "NSError+CLKAdditions.h"
#import "NSMutableArray+CLKAdditions.h"


typedef NS_ENUM(uint32_t, CLKOAPState) {
    CLKOAPStateBegin = 0,
    CLKOAPStateReadNextItem,
    CLKOAPStateParseOptionName,
    CLKOAPStateParseOptionFlag,
    CLKOAPStateParseOptionFlagGroup,
    CLKOAPStateParseArgument,
    CLKOAPStateError,
    CLKOAPStateEnd
};


NS_ASSUME_NONNULL_BEGIN

@interface CLKArgumentParser ()

- (instancetype)_initWithArgumentVector:(NSArray<NSString *> *)argv
                               options:(NSArray<CLKOption *> *)options
                          optionGroups:(nullable NSArray<CLKOptionGroup *> *)groups NS_DESIGNATED_INITIALIZER;

@property (nullable, retain) CLKOption *currentOption;

- (CLKOAPState)_processOptionIdentifier:(NSString *)identifier usingMap:(NSDictionary<NSString *, CLKOption *> *)optionMap error:(NSError **)outError;

@end

NS_ASSUME_NONNULL_END


@implementation CLKArgumentParser
{
    CLKOAPState _state;
    CLKOption *_currentOption;
    NSMutableArray<NSString *> *_argumentVector;
    NSArray<CLKOption *> *_options;
    NSMutableDictionary<NSString *, CLKOption *> *_optionNameMap;
    NSMutableDictionary<NSString *, CLKOption *> *_optionFlagMap;
    NSArray<CLKOptionGroup *> *_optionGroups;
    CLKArgumentManifest *_manifest;
}

@synthesize currentOption = _currentOption;

+ (instancetype)parserWithArgumentVector:(NSArray<NSString *> *)argv options:(NSArray<CLKOption *> *)options
{
    return [[[self alloc] _initWithArgumentVector:argv options:options optionGroups:nil] autorelease];
}

+ (instancetype)parserWithArgumentVector:(NSArray<NSString *> *)argv options:(NSArray<CLKOption *> *)options optionGroups:(NSArray<CLKOptionGroup *> *)groups
{
    return [[[self alloc] _initWithArgumentVector:argv options:options optionGroups:groups] autorelease];
}

- (instancetype)_initWithArgumentVector:(NSArray<NSString *> *)argv options:(NSArray<CLKOption *> *)options optionGroups:(NSArray<CLKOptionGroup *> *)groups
{
    CLKHardParameterAssert(argv != nil);
    CLKHardParameterAssert(options != nil);
    
    self = [super init];
    if (self != nil) {
        _state = CLKOAPStateBegin;
        _argumentVector = [argv mutableCopy];
        _options = [options copy];
        _optionNameMap = [[NSMutableDictionary alloc] init];
        _optionFlagMap = [[NSMutableDictionary alloc] init];
        
        for (CLKOption *opt in options) {
            CLKHardAssert((_optionNameMap[opt.name] == nil), NSInvalidArgumentException, @"duplicate option '%@'", opt.name);
            _optionNameMap[opt.name] = opt;
            
            if (opt.flag != nil) {
                CLKOption *collision = _optionFlagMap[opt.flag];
                CLKHardAssert((collision == nil), NSInvalidArgumentException, @"colliding flag '%@' found for options '%@' and '%@'", opt.flag, opt.name, collision.name);
                _optionFlagMap[opt.flag] = opt;
            }
        }
        
        for (CLKOptionGroup *group in groups) {
            for (NSString *optionName in group.allOptions) {
                CLKHardAssert((_optionNameMap[optionName] != nil), NSInvalidArgumentException, @"unregistered option found in option group: '--%@'", optionName);
            }
        }
        
        _optionGroups = [groups copy];
        _manifest = [[CLKArgumentManifest alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [_manifest release];
    [_optionGroups release];
    [_argumentVector release];
    [_optionFlagMap release];
    [_optionNameMap release];
    [_currentOption release];
    [_options release];
    [super dealloc];
}

#pragma mark -

- (CLKArgumentManifest *)parseArguments:(NSError **)outError
{
    CLKHardAssert((_state == CLKOAPStateBegin), NSGenericException, @"cannot re-run a parser after use");
    
    NSError *error = nil;
    
    while (_state != CLKOAPStateEnd) {
        @autoreleasepool {
            switch (_state) {
                case CLKOAPStateBegin:
                    _state = CLKOAPStateReadNextItem;
                    break;
                
                case CLKOAPStateReadNextItem:
                    _state = [self _readNextItem:&error];
                    break;
                
                case CLKOAPStateParseOptionName:
                    _state = [self _parseOptionName:&error];
                    break;
                
                case CLKOAPStateParseOptionFlag:
                    _state = [self _parseOptionFlag:&error];
                    break;
                
                case CLKOAPStateParseOptionFlagGroup:
                    _state = [self _parseOptionFlagGroup:&error];
                    break;
                
                case CLKOAPStateParseArgument:
                    _state = [self _parseArgument:&error];
                    break;
                
                case CLKOAPStateError:
                    _state = CLKOAPStateEnd;
                    [_manifest release];
                    _manifest = nil;
                    break;
                
                case CLKOAPStateEnd:
                    break;
            }
            
            // when transitioning to CLKOAPStateError, hoist the error out of this autorelease pool.
            // we will not transition through CLKOAPStateError more than once.
            if (_state == CLKOAPStateError) {
                [error retain];
            }
        } // autorelease pool
    }; // state machine loop
    
    if (_manifest == nil) {
        NSAssert(error != nil, @"expected an error when manifest is nil");
        [error autorelease];
        CLKSetOutError(outError, error);
        return nil;
    }
    
    NSAssert(error == nil, @"expected nil error when manifest is non-nil");
    
    if (![self _validateManifest:outError]) {
        [_manifest release];
        _manifest = nil;
        return nil;
    }
    
    return _manifest;
}

#pragma mark -
#pragma mark State Steps

- (CLKOAPState)_readNextItem:(NSError **)outError
{
    NSString *nextItem = _argumentVector.firstObject;
    
    // if we're reached the end of the arg vector, we've parsed everything
    if (nextItem == nil) {
        return CLKOAPStateEnd;
    }
    
    // reject meaningless input
    // [TACK] if we wanted to support remainder arguments, we would remove the "--" guard and add that as a scenario.
    //        (we'd probably just collect them into a separate array on the manifest so the client can pass them through
    //         to another program or send them through a second parser.)
    if ([nextItem isEqualToString:@"--"] || [nextItem isEqualToString:@"-"]) {
        CLKSetOutError(outError, ([NSError clk_POSIXErrorWithCode:EINVAL description:@"unexpected token in argument vector: '%@'", nextItem]));
        return CLKOAPStateError;
    }
    
    if ([nextItem hasPrefix:@"--"]) {
        return CLKOAPStateParseOptionName;
    }
    
    if ([nextItem hasPrefix:@"-"]) {
        if (nextItem.length == 2) {
            return CLKOAPStateParseOptionFlag;
        }
        
        if (nextItem.length > 2) {
            return CLKOAPStateParseOptionFlagGroup;
        }
    }
    
    return CLKOAPStateParseArgument;
}

- (CLKOAPState)_processOptionIdentifier:(NSString *)identifier usingMap:(NSDictionary<NSString *, CLKOption *> *)optionMap error:(NSError **)outError
{
    CLKOption *option = optionMap[identifier];
    if (option == nil) {
        CLKSetOutError(outError, ([NSError clk_POSIXErrorWithCode:EINVAL description:@"unrecognized option: '%@'", identifier]));
        return CLKOAPStateError;
    }
    
    if (option.type == CLKOptionTypeParameter) {
        self.currentOption = option;
        return CLKOAPStateParseArgument;
    }
    
    [_manifest accumulateSwitchOption:option];
    return CLKOAPStateReadNextItem;
}

- (CLKOAPState)_parseOptionName:(NSError **)outError
{
    NSAssert((_argumentVector.count > 0), @"unexpectedly empty argument vector");
    NSString *name = [[_argumentVector clk_popFirstObject] substringFromIndex:2];
    return [self _processOptionIdentifier:name usingMap:_optionNameMap error:outError];
}

- (CLKOAPState)_parseOptionFlag:(NSError **)outError
{
    NSAssert((_argumentVector.count > 0), @"unexpectedly empty argument vector");
    NSString *flag = [[_argumentVector clk_popFirstObject] substringFromIndex:1];
    return [self _processOptionIdentifier:flag usingMap:_optionFlagMap error:outError];
}

- (CLKOAPState)_parseOptionFlagGroup:(__unused NSError **)outError
{
    NSAssert((_argumentVector.count > 0), @"unexpectedly empty argument vector");
    NSString *flagGroup = [[_argumentVector clk_popFirstObject] substringFromIndex:1];
    
    // simple trick to implement option flag groups:
    //
    //    1. explode the group into individual flags
    //    2. add the flags to the front of argv
    //    3. let normal option flag parsing take care of them
    //
    
    NSRange range = [flagGroup rangeOfString:flagGroup];
    NSStringEnumerationOptions enumerationOpts = (NSStringEnumerationByComposedCharacterSequences | NSStringEnumerationReverse); // backward to preserve order when inserting
    [flagGroup enumerateSubstringsInRange:range options:enumerationOpts usingBlock:^(NSString *flag, __unused NSRange substringRange, __unused NSRange enclosingRange, __unused BOOL *outStop) {
        [_argumentVector insertObject:[@"-" stringByAppendingString:flag] atIndex:0];
    }];
    
    return CLKOAPStateReadNextItem;
}

- (CLKOAPState)_parseArgument:(NSError **)outError
{
    NSAssert((_argumentVector.count > 0), @"unexpectedly empty argument vector");
    NSString *argument = [_argumentVector clk_popFirstObject];
    
    // reject: empty string passed into argv (e.g., --foo "")
    if (argument.length == 0) {
        CLKSetOutError(outError, ([NSError clk_POSIXErrorWithCode:EINVAL description:@"encountered zero-length argument"]));
        return CLKOAPStateError;
    }
    
    if (self.currentOption != nil) {
        NSAssert((self.currentOption.type == CLKOptionTypeParameter), @"attempting to parse an argument for a non-parameter option");
        
        // reject: the next argument is some kind of option, but we expect an argument
        if ([argument hasPrefix:@"-"]) {
            CLKSetOutError(outError, ([NSError clk_POSIXErrorWithCode:EINVAL description:@"expected argument but encountered option-like token '%@'", argument]));
            return CLKOAPStateError;
        }
        
        CLKArgumentTransformer *transformer = self.currentOption.transformer;
        if (transformer != nil) {
            argument = [transformer transformedArgument:argument error:outError];
            if (argument == nil) {
                return CLKOAPStateError;
            }
        }
        
        [_manifest accumulateArgument:argument forParameterOption:self.currentOption];
        self.currentOption = nil;
    } else {
        [_manifest accumulatePositionalArgument:argument];
    }
    
    return CLKOAPStateReadNextItem;
}

#pragma mark -

- (BOOL)_validateManifest:(NSError **)outError
{
    NSAssert(_manifest != nil, @"attempting validation without a manifest");
    
    BOOL result = YES;
    NSError *error = nil;
    
    @autoreleasepool {
        NSMutableArray<CLKArgumentManifestConstraint *> *constraints = [NSMutableArray array];
        for (CLKOption *option in _options) {
            [constraints addObjectsFromArray:option.constraints];
        }
        
        for (CLKOptionGroup *group in _optionGroups) {
            [constraints addObjectsFromArray:group.constraints];
        }
        
        CLKArgumentManifestValidator *validator = [[[CLKArgumentManifestValidator alloc] initWithManifest:_manifest] autorelease];
        result = [validator validateConstraints:constraints error:&error];
        [error retain];
    }
    
    [error autorelease];
    CLKSetOutError(outError, error);
    return result;
}

@end
