//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import "CLKArgumentParser_Internal.h"

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
#import "CLKToken.h"
#import "NSCharacterSet+CLKAdditions.h"
#import "NSError+CLKAdditions.h"
#import "NSMutableArray+CLKAdditions.h"


@implementation CLKArgumentParser
{
    NSMutableArray<NSString *> *_argumentVector;
    NSArray<CLKOption *> *_options;
    NSArray<CLKOptionGroup *> *_optionGroups;
    CLKOptionRegistry *_optionRegistry;
    CLKAPState _state;
    CLKOption *_currentParameterOption;
    CLKArgumentManifest *_manifest;
    NSMutableArray<NSError *> *_parsingErrors;
    NSMutableArray<NSError *> *_validationErrors;
}

+ (instancetype)parserWithArgumentVector:(NSArray<NSString *> *)argv options:(NSArray<CLKOption *> *)options
{
    return [[self alloc] _initWithArgumentVector:argv options:options optionGroups:nil];
}

+ (instancetype)parserWithArgumentVector:(NSArray<NSString *> *)argv options:(NSArray<CLKOption *> *)options optionGroups:(NSArray<CLKOptionGroup *> *)groups
{
    return [[self alloc] _initWithArgumentVector:argv options:options optionGroups:groups];
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
        _parsingErrors = [[NSMutableArray alloc] init];
        _validationErrors = [[NSMutableArray alloc] init];
        
        // sanity-check groups
        for (CLKOptionGroup *group in groups) {
            for (NSString *optionName in group.allOptions) {
                CLKHardAssert([_optionRegistry hasOptionNamed:optionName], NSInvalidArgumentException, @"unregistered option '%@' found in option group", optionName);
            }
        }
    }
    
    return self;
}

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"%@ { state: %d | argvec: %@ }", super.debugDescription, _state, _argumentVector];
}

#pragma mark -

- (void)setCurrentParameterOption:(CLKOption *)option
{
    NSParameterAssert(option == nil || option.type == CLKOptionTypeParameter);
    
    if (option != _currentParameterOption) {
        _currentParameterOption = option;
    }
}

- (CLKOption *)currentParameterOption
{
    return _currentParameterOption;
}

- (CLKOption *)_optionForOptionNameToken:(NSString *)token error:(NSError **)outError
{
    NSParameterAssert(token.length > 2);
    
    NSString *name = [token substringFromIndex:2];
    CLKOption *option = [_optionRegistry optionNamed:name];
    if (option == nil) {
        CLKSetOutError(outError, ([NSError clk_POSIXErrorWithCode:EINVAL description:@"unrecognized option: '%@'", token]));
        return nil;
    }
    
    return option;
}

- (CLKOption *)_optionForOptionFlagToken:(NSString *)token error:(NSError **)outError
{
    NSParameterAssert(token.length == 2);
    
    NSString *flag = [token substringFromIndex:1];
    CLKOption *option = [_optionRegistry optionForFlag:flag];
    if (option == nil) {
        CLKSetOutError(outError, ([NSError clk_POSIXErrorWithCode:EINVAL description:@"unrecognized option: '%@'", token]));
        return nil;
    }
    
    return option;
}

#pragma mark -
#pragma mark Errors

- (NSArray<NSError *> *)errors
{
    NSMutableArray<NSError *> *errors = [NSMutableArray array];
    [errors addObjectsFromArray:_parsingErrors];
    [errors addObjectsFromArray:_validationErrors];
    return (errors.count > 0 ? errors : nil);
}

- (void)_accumulateParsingError:(NSError *)error
{
    [_parsingErrors addObject:error];
}

- (void)_accumulateValidationError:(NSError *)error
{
    // the manifest won't contain a given required parameter option if no occurences of that option could be parsed.
    // in this event, both a parsing error and a validation error are generated. displaying both errors is confusing.
    // the solution is to display *just* the parsing error; we don't want to display both a parsing error *and* an
    // "option not provided" error if we know the user *did* supply the option at least once.
    if (error.code == CLKErrorRequiredOptionNotProvided && [error.domain isEqualToString:CLKErrorDomain]) {
        NSAssert(error.clk_representedOptions.count > 0, @"represented options missing");
        for (NSString *optionName in error.clk_representedOptions) {
            if ([self _hasParsingErrorForOptionNamed:optionName]) {
                return;
            }
        }
    }
    
    [_validationErrors addObject:error];
}

- (BOOL)_hasParsingErrorForOptionNamed:(NSString *)optionName
{
    for (NSError *error in _parsingErrors) {
        if ([error.clk_representedOptions containsObject:optionName]) {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark -
#pragma mark Parsing

- (CLKArgumentManifest *)parseArguments
{
    CLKHardAssert((_state == CLKAPStateBegin), NSGenericException, @"cannot re-run a parser after use");
    
    while (_state != CLKAPStateEnd) {
        @autoreleasepool {
            switch (_state) {
                case CLKAPStateBegin:
                    _state = CLKAPStateReadNextArgumentToken;
                    break;
                
                case CLKAPStateReadNextArgumentToken:
                    _state = [self _readNextArgumentToken];
                    break;
                
                case CLKAPStateParseOptionName:
                    _state = [self _parseOptionName];
                    break;
                
                case CLKAPStateParseOptionFlag:
                    _state = [self _parseOptionFlag];
                    break;
                
                case CLKAPStateParseOptionFlagSet:
                    _state = [self _parseOptionFlagSet];
                    break;
                
                case CLKAPStateParseParameterOptionNameAssignment:
                    _state = [self _parseOptionNameAssignment];
                    break;
                
                case CLKAPStateParseParameterOptionFlagAssignment:
                    _state = [self _parseOptionFlagAssignment];
                    break;
                
                case CLKAPStateParseArgument:
                    _state = [self _parseArgument];
                    break;
                
                case CLKAPStateParseRemainingArguments:
                    _state = [self _parseRemainingArguments];
                    break;
                
                case CLKAPStateEnd:
                    break;
            }
        }
    };
    
    if (![self _validateManifest]) {
        NSAssert((self.errors.count > 0), @"expected one or more errors on validation failure");
    }
    
    if (self.errors.count > 0) {
        _manifest = nil;
        return nil;
    }
    
    return _manifest;
}

- (CLKAPState)_readNextArgumentToken
{
    // if we're reached the end of the argument vector, we've parsed everything
    if (_argumentVector.count == 0) {
        return CLKAPStateEnd;
    }
    
    NSString *nextToken = _argumentVector.firstObject;
    switch (CLKTokenFormForToken(nextToken)) {
        case CLKTokenFormOptionName:
            return CLKAPStateParseOptionName;
        
        case CLKTokenFormOptionFlag:
            return CLKAPStateParseOptionFlag;
        
        case CLKTokenFormOptionFlagSet:
            return CLKAPStateParseOptionFlagSet;
        
        case CLKTokenFormParameterOptionNameAssignment:
            return CLKAPStateParseParameterOptionNameAssignment;
        
        case CLKTokenFormParameterOptionFlagAssignment:
            return CLKAPStateParseParameterOptionFlagAssignment;
        
        case CLKTokenFormOptionParsingSentinel:
            return CLKAPStateParseRemainingArguments;
        
        case CLKTokenFormArgument:
            return CLKAPStateParseArgument;
        
        case CLKTokenFormMalformedOption:
            [_argumentVector removeObjectAtIndex:0];
            [self _accumulateParsingError:[NSError clk_POSIXErrorWithCode:EINVAL description:@"unexpected token in argument vector: '%@'", nextToken]];
            return CLKAPStateReadNextArgumentToken;
    }
}

- (CLKAPState)_parseOptionName
{
    NSAssert((_argumentVector.count > 0), @"empty argument vector");
    NSString *rawArgument = [_argumentVector clk_popFirstObject];
    NSAssert((rawArgument.length > 2 && [rawArgument hasPrefix:@"--"]), @"encountered '%@' when attempting to parse an option name", rawArgument);
    
    NSError *error;
    CLKOption *option = [self _optionForOptionNameToken:rawArgument error:&error];
    if (option == nil) {
        [self _accumulateParsingError:error];
        return CLKAPStateReadNextArgumentToken;
    }
    
    return [self _processParsedOption:option userInvocation:rawArgument];
}

- (CLKAPState)_parseOptionFlagSet
{
    NSAssert((_argumentVector.count > 0), @"empty argument vector");
    
    // simple trick to implement option flag sets:
    //
    //    1. explode the group into individual flags
    //    2. add the flags to the front of argv
    //    3. let normal option flag parsing take care of them
    //
    
    NSString *flagSet = [[_argumentVector clk_popFirstObject] substringFromIndex:1];
    
    NSRange range = NSMakeRange(0, flagSet.length);
    NSStringEnumerationOptions enumerationOpts = (NSStringEnumerationByComposedCharacterSequences | NSStringEnumerationReverse); // backward to preserve order when inserting
    [flagSet enumerateSubstringsInRange:range options:enumerationOpts usingBlock:^(NSString *flag, __unused NSRange substringRange, __unused NSRange enclosingRange, __unused BOOL *outStop) {
        [_argumentVector insertObject:[@"-" stringByAppendingString:flag] atIndex:0];
    }];
    
    return CLKAPStateReadNextArgumentToken;
}

- (CLKAPState)_parseOptionFlag
{
    NSAssert((_argumentVector.count > 0), @"empty argument vector");
    NSString *rawArgument = [_argumentVector clk_popFirstObject];
    NSAssert((rawArgument.length == 2 && [rawArgument hasPrefix:@"-"]), @"encountered '%@' when attempting to parse an option flag", rawArgument);
    
    NSError *error;
    CLKOption *option = [self _optionForOptionFlagToken:rawArgument error:&error];
    if (option == nil) {
        [self _accumulateParsingError:error];
        return CLKAPStateReadNextArgumentToken;
    }
    
    return [self _processParsedOption:option userInvocation:rawArgument];
}

- (CLKAPState)_parseOptionNameAssignment
{
    NSAssert((_argumentVector.count > 0), @"empty argument vector");
    NSString *rawArgument = [_argumentVector clk_popFirstObject];
    NSAssert((rawArgument.length > 3 && [rawArgument hasPrefix:@"--"]), @"encountered '%@' when attempting to parse a parameter option name assignment token", rawArgument);
    
    NSUInteger split = [rawArgument rangeOfCharacterFromSet:NSCharacterSet.clk_parameterOptionAssignmentCharacterSet].location;
    NSAssert((split != NSNotFound), @"expected assignment character in token '%@'", rawArgument);
    NSAssert((split != 2), @"unexpected assignment character at index 2 in token '%@'", rawArgument);
    NSRange optionTokenRange = NSMakeRange(0, split);
    NSRange argumentRange = NSMakeRange((split + 1), (rawArgument.length - split - 1));
    NSString *optionSegment = [rawArgument substringWithRange:optionTokenRange];
    NSAssert((optionSegment.length > 0), @"expected option segment");
    NSString *argumentSegment = [rawArgument substringWithRange:argumentRange];
    
    NSError *optionLookupError;
    CLKOption *option = [self _optionForOptionNameToken:optionSegment error:&optionLookupError];
    if (option == nil) {
        [self _accumulateParsingError:optionLookupError];
        return CLKAPStateReadNextArgumentToken;
    }
    
    if (argumentSegment.length == 0) {
        NSError *error = [NSError clk_POSIXErrorWithCode:EINVAL representedOptions:@[ option.name ] description:@"expected argument for option '%@'", optionSegment];
        [self _accumulateParsingError:error];
        return CLKAPStateReadNextArgumentToken;
    }
    
    NSError *processingError;
    if (![self _processAssignedArgument:argumentSegment forParameterOption:option userInvocation:optionSegment error:&processingError]) {
        [self _accumulateParsingError:processingError];
        return CLKAPStateReadNextArgumentToken;
    }
    
    return CLKAPStateReadNextArgumentToken;
}

- (CLKAPState)_parseOptionFlagAssignment
{
    NSAssert((_argumentVector.count > 0), @"empty argument vector");
    NSString *rawArgument = [_argumentVector clk_popFirstObject];
    NSAssert((rawArgument.length > 2 && [rawArgument hasPrefix:@"-"]), @"encountered '%@' when attempting to parse a parameter option flag assignment token", rawArgument);
    NSAssert([NSCharacterSet.clk_parameterOptionAssignmentCharacterSet characterIsMember:[rawArgument characterAtIndex:2]], @"expected assignment character at index 2 in token '%@'", rawArgument);
    
    NSString *flagSegment = [rawArgument substringToIndex:2];
    NSString *argumentSegment = [rawArgument substringFromIndex:3];
    
    NSError *optionLookupError;
    CLKOption *option = [self _optionForOptionFlagToken:flagSegment error:&optionLookupError];
    if (option == nil) {
        [self _accumulateParsingError:optionLookupError];
        return CLKAPStateReadNextArgumentToken;
    }
    
    if (argumentSegment.length == 0) {
        NSError *error = [NSError clk_POSIXErrorWithCode:EINVAL representedOptions:@[ option.name ] description:@"expected argument for option '%@'", flagSegment];
        [self _accumulateParsingError:error];
        return CLKAPStateReadNextArgumentToken;
    }
    
    NSError *processingError;
    if (![self _processAssignedArgument:argumentSegment forParameterOption:option userInvocation:flagSegment error:&processingError]) {
        [self _accumulateParsingError:processingError];
        return CLKAPStateReadNextArgumentToken;
    }
    
    return CLKAPStateReadNextArgumentToken;
}

- (CLKAPState)_parseArgument
{
    NSAssert((_argumentVector.count > 0), @"empty argument vector");
    
    NSString *argument = [_argumentVector clk_popFirstObject];
    NSError *error;
    if (![self _processArgument:argument forParameterOption:self.currentParameterOption error:&error]) {
        self.currentParameterOption = nil;
        [self _accumulateParsingError:error];
        return CLKAPStateReadNextArgumentToken;
    }
    
    self.currentParameterOption = nil;
    return CLKAPStateReadNextArgumentToken;
}

- (CLKAPState)_parseRemainingArguments
{
    NSAssert([_argumentVector.firstObject isEqualToString:@"--"], @"expected sentinel at index 0 of argument vector");
    
    [_argumentVector removeObjectAtIndex:0]; // discard sentinel
    while (_argumentVector.count > 0) {
        NSString *argument = [_argumentVector clk_popFirstObject];
        NSError *error;
        if (![self _processArgument:argument forParameterOption:self.currentParameterOption error:&error]) {
            [self _accumulateParsingError:error];
        }
        
        self.currentParameterOption = nil;
    }
    
    return CLKAPStateEnd;
}

- (BOOL)_processAssignedArgument:(NSString *)argument forParameterOption:(CLKOption *)option userInvocation:(NSString *)userInvocation error:(NSError **)outError
{
    if (option.type != CLKOptionTypeParameter) {
        CLKSetOutError(outError, ([NSError clk_POSIXErrorWithCode:EINVAL representedOptions:@[ option.name ] description:@"option '%@' does not accept arguments", userInvocation]));
        return NO;
    }
    
    return [self _processArgument:argument forParameterOption:option error:outError];
}

- (CLKAPState)_processParsedOption:(CLKOption *)option userInvocation:(NSString *)userInvocation
{
    NSAssert(self.currentParameterOption == nil, @"currentParameterOption previously set");
    
    if (option.type == CLKOptionTypeParameter) {
        // if the argument vector is empty at this point, we have encountered a parameter option at the end of the vector
        if (_argumentVector.count == 0) {
            NSError *error = [NSError clk_POSIXErrorWithCode:EINVAL representedOptions:@[ option.name ] description:@"expected argument for option '%@'", userInvocation];
            [self _accumulateParsingError:error];
            return CLKAPStateReadNextArgumentToken;
        }
        
        self.currentParameterOption = option;
        
        // if the next argument after this option is the parsing sentinel, transition to the sentinel parsing state
        if (CLKTokenFormForToken(_argumentVector.firstObject) == CLKTokenFormOptionParsingSentinel) {
            return CLKAPStateParseRemainingArguments;
        }
        
        return CLKAPStateParseArgument;
    }
    
    [_manifest accumulateSwitchOptionNamed:option.name];
    return CLKAPStateReadNextArgumentToken;
}

- (BOOL)_processArgument:(NSString *)argument forParameterOption:(CLKOption *)option error:(NSError **)outError
{
    NSParameterAssert(option == nil || option.type == CLKOptionTypeParameter);
    
    // reject: empty string passed into argv (e.g., --foo "")
    if (argument.length == 0) {
        if (option == nil) {
            CLKSetOutError(outError, [NSError clk_POSIXErrorWithCode:EINVAL description:@"encountered zero-length argument"]);
        } else {
            CLKSetOutError(outError, [NSError clk_POSIXErrorWithCode:EINVAL representedOptions:@[ option.name ] description:@"encountered zero-length argument"]);
        }
        
        return NO;
    }
    
    if (option == nil) {
        [_manifest accumulatePositionalArgument:argument];
        return YES;
    }
    
    BOOL rejectOptionLikeToken = !(_state == CLKAPStateParseParameterOptionNameAssignment
                                   || _state == CLKAPStateParseParameterOptionFlagAssignment
                                   || _state == CLKAPStateParseRemainingArguments);
    
    // reject: the next argument looks like an option, but we expect an argument
    if (rejectOptionLikeToken) {
        CLKTokenForm form = CLKTokenFormForToken(argument);
        if (CLKTokenFormIsKindOfOption(form)) {
            CLKSetOutError(outError, ([NSError clk_POSIXErrorWithCode:EINVAL representedOptions:@[ option.name ] description:@"expected argument for option but encountered option-like token '%@'", argument]));
            return NO;
        }
    }
    
    CLKArgumentTransformer *transformer = option.transformer;
    if (transformer != nil) {
        NSError *transformerError;
        argument = [transformer transformedArgument:argument error:&transformerError];
        if (argument == nil) {
            *outError = [transformerError clk_errorByAddingRepresentedOptions:@[ option.name ]];
            return NO;
        }
    }
    
    [_manifest accumulateArgument:argument forParameterOptionNamed:option.name];
    return YES;
}

#pragma mark -
#pragma mark Validation

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
        
        CLKArgumentManifestValidator *validator = [[CLKArgumentManifestValidator alloc] initWithManifest:_manifest];
        [validator validateConstraints:constraints issueHandler:^(NSError *error) {
            result = NO;
            [self _accumulateValidationError:error];
        }];
    }
    
    return result;
}

@end
