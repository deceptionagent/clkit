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


typedef NS_ENUM(uint32_t, CLKAPState) {
    CLKAPStateBegin = 0,
    CLKAPStateReadNextItem,
    CLKAPStateParseOptionName,
    CLKAPStateParseOptionFlag,
    CLKAPStateParseOptionFlagGroup,
    CLKAPStateParseArgument,
    CLKAPStateError,
    CLKAPStateEnd
};


NS_ASSUME_NONNULL_BEGIN

@interface CLKArgumentParser ()

- (instancetype)_initWithArgumentVector:(NSArray<NSString *> *)argv
                               options:(NSArray<CLKOption *> *)options
                          optionGroups:(nullable NSArray<CLKOptionGroup *> *)groups NS_DESIGNATED_INITIALIZER;

@property (nullable, retain) CLKOption *currentOption;
@property (readonly) NSArray<NSError *> *errors;

- (void)_accumulateError:(NSError *)error;

- (CLKAPState)_processOptionIdentifier:(NSString *)identifier usingMap:(NSDictionary<NSString *, CLKOption *> *)optionMap;

@end

NS_ASSUME_NONNULL_END


@implementation CLKArgumentParser
{
    CLKAPState _state;
    CLKOption *_currentOption;
    NSMutableArray<NSString *> *_argumentVector;
    NSArray<CLKOption *> *_options;
    NSMutableDictionary<NSString *, CLKOption *> *_optionNameMap;
    NSMutableDictionary<NSString *, CLKOption *> *_optionFlagMap;
    NSArray<CLKOptionGroup *> *_optionGroups;
    CLKArgumentManifest *_manifest;
    NSMutableArray<NSError *> *_errors;
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
        _state = CLKAPStateBegin;
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
    [_errors release];
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
    CLKHardAssert((_state == CLKAPStateBegin), NSGenericException, @"cannot re-run a parser after use");
    
    while (_state != CLKAPStateEnd) {
        @autoreleasepool {
            switch (_state) {
                case CLKAPStateBegin:
                    _state = CLKAPStateReadNextItem;
                    break;
                
                case CLKAPStateReadNextItem:
                    _state = [self _readNextItem];
                    break;
                
                case CLKAPStateParseOptionName:
                    _state = [self _parseOptionName];
                    break;
                
                case CLKAPStateParseOptionFlag:
                    _state = [self _parseOptionFlag];
                    break;
                
                case CLKAPStateParseOptionFlagGroup:
                    _state = [self _parseOptionFlagGroup];
                    break;
                
                case CLKAPStateParseArgument:
                    _state = [self _parseArgument];
                    break;
                
                case CLKAPStateError:
                    NSAssert((self.errors.count > 0), @"expected at least one error on CLKAPStateError");
                    _state = CLKAPStateEnd;
                    [_manifest release];
                    _manifest = nil;
                    break;
                
                case CLKAPStateEnd:
                    break;
            }
        } // autorelease pool
    }; // state machine loop
    
    if (_manifest == nil) {
        NSError *error = self.errors.firstObject;
        NSAssert(error != nil, @"expected an error when manifest is nil");
        CLKSetOutError(outError, error);
        return nil;
    }
    
    NSAssert(self.errors == nil, @"expected no errors when manifest is non-nil");
    
    if (![self _validateManifest]) {
        NSError *error = self.errors.firstObject;
        NSAssert(error != nil, @"expected an error on validation failure");
        CLKSetOutError(outError, error);
        [_manifest release];
        _manifest = nil;
        return nil;
    }
    
    return _manifest;
}

- (BOOL)_validateManifest
{
    NSAssert(_manifest != nil, @"attempting validation without a manifest");
    
    @autoreleasepool {
        NSMutableArray<CLKArgumentManifestConstraint *> *constraints = [NSMutableArray array];
        for (CLKOption *option in _options) {
            [constraints addObjectsFromArray:option.constraints];
        }
        
        for (CLKOptionGroup *group in _optionGroups) {
            [constraints addObjectsFromArray:group.constraints];
        }
        
        CLKArgumentManifestValidator *validator = [[[CLKArgumentManifestValidator alloc] initWithManifest:_manifest] autorelease];
        
        NSError *error;
        if (![validator validateConstraints:constraints error:&error]) {
            [self _accumulateError:error];
            return NO;
        }
    }
    
    return YES;
}

- (void)_accumulateError:(NSError *)error
{
    if (_errors == nil) {
        _errors = [[NSMutableArray alloc] init];
    }
    
    [_errors addObject:error];
}

#pragma mark -
#pragma mark State Steps

- (CLKAPState)_readNextItem
{
    NSString *nextItem = _argumentVector.firstObject;
    
    // if we're reached the end of the arg vector, we've parsed everything
    if (nextItem == nil) {
        return CLKAPStateEnd;
    }
    
    // reject meaningless input
    // [TACK] if we wanted to support remainder arguments, we would remove the "--" guard and add that as a scenario.
    //        (we'd probably just collect them into a separate array on the manifest so the client can pass them through
    //         to another program or send them through a second parser.)
    if ([nextItem isEqualToString:@"--"] || [nextItem isEqualToString:@"-"]) {
        NSError *error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"unexpected token in argument vector: '%@'", nextItem];
        [self _accumulateError:error];
        return CLKAPStateError;
    }
    
    if ([nextItem hasPrefix:@"--"]) {
        return CLKAPStateParseOptionName;
    }
    
    if ([nextItem hasPrefix:@"-"]) {
        if (nextItem.length == 2) {
            return CLKAPStateParseOptionFlag;
        }
        
        if (nextItem.length > 2) {
            return CLKAPStateParseOptionFlagGroup;
        }
    }
    
    return CLKAPStateParseArgument;
}

- (CLKAPState)_processOptionIdentifier:(NSString *)identifier usingMap:(NSDictionary<NSString *, CLKOption *> *)optionMap
{
    CLKOption *option = optionMap[identifier];
    if (option == nil) {
        NSError *error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"unrecognized option: '%@'", identifier];
        [self _accumulateError:error];
        return CLKAPStateError;
    }
    
    if (option.type == CLKOptionTypeParameter) {
        self.currentOption = option;
        return CLKAPStateParseArgument;
    }
    
    [_manifest accumulateSwitchOption:option];
    return CLKAPStateReadNextItem;
}

- (CLKAPState)_parseOptionName
{
    NSAssert((_argumentVector.count > 0), @"unexpectedly empty argument vector");
    NSString *name = [[_argumentVector clk_popFirstObject] substringFromIndex:2];
    return [self _processOptionIdentifier:name usingMap:_optionNameMap];
}

- (CLKAPState)_parseOptionFlag
{
    NSAssert((_argumentVector.count > 0), @"unexpectedly empty argument vector");
    NSString *flag = [[_argumentVector clk_popFirstObject] substringFromIndex:1];
    return [self _processOptionIdentifier:flag usingMap:_optionFlagMap];
}

- (CLKAPState)_parseOptionFlagGroup
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
    
    return CLKAPStateReadNextItem;
}

- (CLKAPState)_parseArgument
{
    NSAssert((_argumentVector.count > 0), @"unexpectedly empty argument vector");
    NSString *argument = [_argumentVector clk_popFirstObject];
    
    // reject: empty string passed into argv (e.g., --foo "")
    if (argument.length == 0) {
        NSError *error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"encountered zero-length argument"];
        [self _accumulateError:error];
        return CLKAPStateError;
    }
    
    if (self.currentOption != nil) {
        NSAssert((self.currentOption.type == CLKOptionTypeParameter), @"attempting to parse an argument for a non-parameter option");
        
        // reject: the next argument is some kind of option, but we expect an argument
        if ([argument hasPrefix:@"-"]) {
            NSError *error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"expected argument but encountered option-like token '%@'", argument];
            [self _accumulateError:error];
            return CLKAPStateError;
        }
        
        CLKArgumentTransformer *transformer = self.currentOption.transformer;
        if (transformer != nil) {
            NSError *error;
            argument = [transformer transformedArgument:argument error:&error];
            if (argument == nil) {
                [self _accumulateError:error];
                return CLKAPStateError;
            }
        }
        
        [_manifest accumulateArgument:argument forParameterOption:self.currentOption];
        self.currentOption = nil;
    } else {
        [_manifest accumulatePositionalArgument:argument];
    }
    
    return CLKAPStateReadNextItem;
}

@end
