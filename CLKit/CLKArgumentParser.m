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
#import "CLKOptionRegistry.h"
#import "NSError+CLKAdditions.h"
#import "NSMutableArray+CLKAdditions.h"


typedef NS_ENUM(uint32_t, CLKAPState) {
    CLKAPStateBegin = 0,
    CLKAPStateReadNextItem,
    CLKAPStateParseOptionName,
    CLKAPStateParseOptionFlag,
    #warning rename: "group" is overloaded
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

@property (nullable, retain) CLKOption *currentParameterOption;

- (void)_accumulateError:(NSError *)error;

- (CLKAPState)_processParsedOption:(CLKOption *)option;

@end

NS_ASSUME_NONNULL_END

@implementation CLKArgumentParser
{
    CLKAPState _state;
    CLKOption *_currentParameterOption;
    NSMutableArray<NSString *> *_argumentVector;
    NSArray<CLKOption *> *_options;
    NSArray<CLKOptionGroup *> *_optionGroups;
    CLKOptionRegistry *_optionRegistry;
    CLKArgumentManifest *_manifest;
    NSMutableArray<NSError *> *_errors;
}

@synthesize currentParameterOption = _currentParameterOption;
@synthesize errors = _errors;

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
        _optionGroups = [groups copy];
        _optionRegistry = [[CLKOptionRegistry alloc] initWithOptions:options];
        _manifest = [[CLKArgumentManifest alloc] initWithOptionRegistry:_optionRegistry];
        
        // sanity-check dependencies
        for (CLKOption *option in options) {
            for (NSString *dependencyName in option.dependencies) {
                CLKOption *dependency = [_optionRegistry optionNamed:dependencyName];
                CLKHardAssert((dependency != nil), @"unregistered option '%@' found in dependency list for option '%@'", dependencyName, option.name);
                CLKHardAssert((dependency.type == CLKOptionTypeParameter), @"dependencies must be parameter options -- switch options cannot be required (option: '%@' -> dependency: '%@')", option.name, dependencyName);
            }
        }
        
        // sanity-check groups
        for (CLKOptionGroup *group in groups) {
            for (NSString *optionName in group.allOptions) {
                CLKHardAssert([_optionRegistry hasOptionNamed:optionName], NSInvalidArgumentException, @"unregistered option '%@' found in option group", optionName);
            }
        }
    }
    
    return self;
}

- (void)dealloc
{
    [_errors release];
    [_manifest release];
    [_optionRegistry release];
    [_optionGroups release];
    [_argumentVector release];
    [_currentParameterOption release];
    [_options release];
    [super dealloc];
}

#pragma mark -

- (CLKArgumentManifest *)parseArguments
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
        NSAssert((self.errors.count > 0), @"expected one or more errors when manifest is nil");
        return nil;
    }
    
    NSAssert(self.errors == nil, @"self.errors should be nil when manifest is non-nil");
    
    if (![self _validateManifest]) {
        NSAssert((self.errors.count > 0), @"expected one or more errors on validation failure");
        [_manifest release];
        _manifest = nil;
        return nil;
    }
    
    return _manifest;
}

- (void)setCurrentParameterOption:(CLKOption *)option
{
    NSParameterAssert(option == nil || option.type == CLKOptionTypeParameter);
    
    if (option != _currentParameterOption) {
        [_currentParameterOption release];
        _currentParameterOption = [option retain];
    }
}

- (CLKOption *)currentParameterOption
{
    return _currentParameterOption;
}

- (BOOL)_validateManifest
{
    NSAssert(_manifest != nil, @"attempting validation without a manifest");
    
    __block BOOL result = YES;
    
    @autoreleasepool {
        NSMutableArray<CLKArgumentManifestConstraint *> *constraints = [NSMutableArray array];
        for (CLKOption *option in _options) {
            [constraints addObjectsFromArray:option.constraints];
        }
        
        for (CLKOptionGroup *group in _optionGroups) {
            [constraints addObjectsFromArray:group.constraints];
        }
        
        CLKArgumentManifestValidator *validator = [[[CLKArgumentManifestValidator alloc] initWithManifest:_manifest] autorelease];
        [validator validateConstraints:constraints issueHandler:^(NSError *error) {
            result = NO;
            [self _accumulateError:error];
        }];
    }
    
    return result;
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

- (CLKAPState)_parseOptionName
{
    NSAssert((_argumentVector.count > 0), @"unexpectedly empty argument vector");
    
    NSString *rawArgument = [_argumentVector clk_popFirstObject];
    NSAssert((rawArgument.length > 2 && [rawArgument hasPrefix:@"--"]), @"unexpectedly encountered '%@' when attempting to parse an option name", rawArgument);
    
    NSString *name = [rawArgument substringFromIndex:2];
    CLKOption *option = [_optionRegistry optionNamed:name];
    if (option == nil) {
        NSError *error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"unrecognized option: '--%@'", name];
        [self _accumulateError:error];
        return CLKAPStateError;
    }
    
    return [self _processParsedOption:option];
}

- (CLKAPState)_parseOptionFlag
{
    NSAssert((_argumentVector.count > 0), @"unexpectedly empty argument vector");
    
    NSString *rawArgument = [_argumentVector clk_popFirstObject];
    NSAssert((rawArgument.length == 2 && [rawArgument hasPrefix:@"-"]), @"unexpectedly encountered '%@' when attempting to parse an option flag", rawArgument);
    
    NSString *flag = [rawArgument substringFromIndex:1];
    CLKOption *option = [_optionRegistry optionForFlag:flag];
    if (option == nil) {
        NSError *error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"unrecognized option: '-%@'", flag];
        [self _accumulateError:error];
        return CLKAPStateError;
    }
    
    return [self _processParsedOption:option];
}

- (CLKAPState)_processParsedOption:(CLKOption *)option
{
    NSAssert(self.currentParameterOption == nil, @"currentOption unexpectedly set when processing parsed option");
    
    if (option.type == CLKOptionTypeParameter) {
        self.currentParameterOption = option;
        return CLKAPStateParseArgument;
    }
    
    [_manifest accumulateSwitchOptionNamed:option.name];
    return CLKAPStateReadNextItem;
}

#warning rename: "group" is overloaded
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
    
    if (self.currentParameterOption != nil) {
        // reject: the next argument is some kind of option, but we expect an argument
        if ([argument hasPrefix:@"-"]) {
            NSError *error = [NSError clk_POSIXErrorWithCode:EINVAL description:@"expected argument but encountered option-like token '%@'", argument];
            [self _accumulateError:error];
            return CLKAPStateError;
        }
        
        CLKArgumentTransformer *transformer = self.currentParameterOption.transformer;
        if (transformer != nil) {
            NSError *error;
            argument = [transformer transformedArgument:argument error:&error];
            if (argument == nil) {
                [self _accumulateError:error];
                return CLKAPStateError;
            }
        }
        
        [_manifest accumulateArgument:argument forParameterOptionNamed:self.currentParameterOption.name];
        self.currentParameterOption = nil;
    } else {
        [_manifest accumulatePositionalArgument:argument];
    }
    
    return CLKAPStateReadNextItem;
}

@end
