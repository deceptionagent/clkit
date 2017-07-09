//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import "CLKOptArgParser.h"

#import "NSError+CLKAdditions.h"
#import "NSMutableArray+CLKAdditions.h"
#import "CLKArgumentTransformer.h"
#import "CLKAssert.h"
#import "CLKOption.h"
#import "CLKOptArgManifest.h"


@interface CLKOptArgParser ()

@property (nullable, retain) CLKOption *currentOption;

@end


@implementation CLKOptArgParser

@synthesize currentOption = _currentOption;

+ (instancetype)parserWithArgumentVector:(NSArray<NSString *> *)argv options:(NSArray<CLKOption *> *)options
{
    return [[[self alloc] initWithArgumentVector:argv options:options] autorelease];
}

- (instancetype)initWithArgumentVector:(NSArray<NSString *> *)argv options:(NSArray<CLKOption *> *)options
{
    CLKHardParameterAssert(argv != nil);
    CLKHardParameterAssert(options != nil);
    
    self = [super init];
    if (self != nil) {
        _state = CLKOAPStateBegin;
        _argumentVector = [argv mutableCopy];
        _optionNameMap = [[NSMutableDictionary alloc] init];
        _optionFlagMap = [[NSMutableDictionary alloc] init];
        
        for (CLKOption *opt in options) {
            CLKHardAssert((_optionNameMap[opt.name] == nil), NSInvalidArgumentException, @"duplicate option '%@'", opt.name);
            CLKHardAssert((_optionFlagMap[opt.flag] == nil), NSInvalidArgumentException, @"duplicate option '%@'", opt.name);
            _optionNameMap[opt.name] = opt;
            _optionFlagMap[opt.flag] = opt;
        }
        
        _manifest = [[CLKOptArgManifest alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [_manifest release];
    [_argumentVector release];
    [_optionFlagMap release];
    [_optionNameMap release];
    [_currentOption release];
    [super dealloc];
}

#pragma mark -

- (nullable CLKOptArgManifest *)parseArguments:(NSError **)outError
{
    CLKHardAssert((_state == CLKOAPStateBegin), NSGenericException, @"cannot re-run a parser after use");
    
    while (_state != CLKOAPStateEnd) {
        switch (_state) {
            case CLKOAPStateBegin:
                _state = CLKOAPStateReadNextItem;
                break;
            
            case CLKOAPStateReadNextItem:
                _state = [self _readNextItem:outError];
                break;
            
            case CLKOAPStateParseOptionName:
                _state = [self _parseOptionName:outError];
                break;
            
            case CLKOAPStateParseOptionFlag:
                _state = [self _parseOptionFlag:outError];
                break;
            
            case CLKOAPStateParseOptionFlagGroup:
                _state = [self _parseOptionFlagGroup:outError];
                break;
            
            case CLKOAPStateParseArgument:
                _state = [self _parseArgument:outError];
                break;
            
            case CLKOAPStateError:
                _state = CLKOAPStateEnd;
                [_manifest release];
                _manifest = nil;
                break;
            
            case CLKOAPStateEnd:
                break;
        }
    };
    
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
    // [TACK] if we wanted to support overflow arguments, we would remove the "--" guard and add that as a scenario
    if ([nextItem isEqualToString:@"--"] || [nextItem isEqualToString:@"-"]) {
        if (outError != nil) {
            *outError = [NSError clk_POSIXErrorWithCode:EINVAL localizedDescription:@"unexpected token in argument vector: '%@'", nextItem];
        }
        
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
        if (outError != nil) {
            *outError = [NSError clk_POSIXErrorWithCode:EINVAL localizedDescription:@"unrecognized option: '%@'", identifier];
        }
        
        return CLKOAPStateError;
    }
    
    if (option.expectsArgument) {
        self.currentOption = option;
        return CLKOAPStateParseArgument;
    }
    
    [_manifest accumulateFreeOptionNamed:option.name];
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
    NSStringEnumerationOptions enumerationOpts = (NSStringEnumerationByComposedCharacterSequences | NSStringEnumerationReverse); // backwards to preserve order when inserting
    [flagGroup enumerateSubstringsInRange:range options:enumerationOpts usingBlock:^(NSString *flag, __unused NSRange substringRange, __unused NSRange enclosingRange, __unused BOOL *outStop) {
        [_argumentVector insertObject:[@"-" stringByAppendingString:flag] atIndex:0];
    }];
    
    return CLKOAPStateReadNextItem;
}

- (CLKOAPState)_parseArgument:(NSError **)outError
{
    NSAssert((_argumentVector.count > 0), @"unexpectedly empty argument vector");
    NSString *argument = [_argumentVector clk_popFirstObject];
    
    if (self.currentOption != nil) {
        // reject: the next argument is some kind of option, but we expect an argument
        if ([argument hasPrefix:@"-"]) {
            if (outError != nil) {
                *outError = [NSError clk_POSIXErrorWithCode:EINVAL localizedDescription:@"expected argument but encountered option-like token '%@'", argument];
            }
            
            return CLKOAPStateError;
        }
        
        CLKArgumentTransformer *transformer = self.currentOption.transformer;
        if (transformer != nil) {
            argument = [transformer transformedArgument:argument error:outError];
            if (argument == nil) {
                return CLKOAPStateError;
            }
        }
        
        [_manifest accumulateArgument:argument forOptionNamed:self.currentOption.name];
        self.currentOption = nil;
    } else {
        [_manifest accumulateRemainderArgument:argument];
    }
    
    return CLKOAPStateReadNextItem;
}

@end
