//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import "CLKOptArgParser.h"

#import "NSMutableArray+CLKAdditions.h"
#import "CLKArgumentTransformer.h"
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
    NSParameterAssert(argv != nil);
    NSParameterAssert(options != nil);
    
    self = [super init];
    if (self != nil) {
        _state = CLKOAPStateBegin;
        _argumentVector = [argv mutableCopy];
        _longOptionMap = [[NSMutableDictionary alloc] init];
        _shortOptionMap = [[NSMutableDictionary alloc] init];
        
        for (CLKOption *opt in options) {
            NSAssert((_longOptionMap[opt.longName] == nil), @"duplicate option '%@'", opt.longName);
            NSAssert((_shortOptionMap[opt.shortName] == nil), @"duplicate option '%@'", opt.longName);
            _longOptionMap[opt.longName] = opt;
            _shortOptionMap[opt.shortName] = opt;
        }
        
        _manifest = [[CLKOptArgManifest alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [_manifest release];
    [_argumentVector release];
    [_shortOptionMap release];
    [_longOptionMap release];
    [_currentOption release];
    [super dealloc];
}

#pragma mark -

- (nullable CLKOptArgManifest *)parseArguments:(NSError **)outError
{
    NSAssert((_state == CLKOAPStateBegin), @"cannot re-run a parser after use");
    
    while (_state != CLKOAPStateEnd) {
        switch (_state) {
            case CLKOAPStateBegin:
                _state = CLKOAPStateReadNextItem;
                break;
            
            case CLKOAPStateReadNextItem:
                _state = [self _readNextItem:outError];
                break;
            
            case CLKOAPStateParseLongOption:
                _state = [self _parseLongOption:outError];
                break;
            
            case CLKOAPStateParseShortOption:
                _state = [self _parseShortOption:outError];
                break;
            
            case CLKOAPStateParseShortOptionGroup:
                _state = [self _parseShortOptionGroup:outError];
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
            NSDictionary *info = @{ NSLocalizedDescriptionKey : [NSString stringWithFormat:@"unexpected token in argument vector: '%@'", nextItem] };
            *outError = [NSError errorWithDomain:NSPOSIXErrorDomain code:EINVAL userInfo:info];
        }
        
        return CLKOAPStateError;
    }
    
    if ([nextItem hasPrefix:@"--"]) {
        return CLKOAPStateParseLongOption;
    }
    
    if ([nextItem hasPrefix:@"-"]) {
        if (nextItem.length == 2) {
            return CLKOAPStateParseShortOption;
        }
        
        if (nextItem.length > 2) {
            return CLKOAPStateParseShortOptionGroup;
        }
    }
    
    return CLKOAPStateParseArgument;
}

- (CLKOAPState)_parseOptionName:(NSString *)optionName usingMap:(NSDictionary<NSString *, CLKOption *> *)optionMap error:(NSError **)outError
{
    self.currentOption = optionMap[optionName];
    if (self.currentOption == nil) {
        if (outError != nil) {
            NSDictionary *info = @{ NSLocalizedDescriptionKey : [NSString stringWithFormat:@"unrecognized option: '%@'", optionName] };
            *outError = [NSError errorWithDomain:NSPOSIXErrorDomain code:EINVAL userInfo:info];
        }
        
        return CLKOAPStateError;
    }
    
    if (self.currentOption.expectsArgument) {
        return CLKOAPStateParseArgument;
    }
    
    [_manifest accumulateFreeOption:self.currentOption.longName];
    self.currentOption = nil;
    return CLKOAPStateReadNextItem;
}

- (CLKOAPState)_parseLongOption:(NSError **)outError
{
    NSAssert((_argumentVector.count > 0), @"unexpectedly empty argument vector");
    NSString *optionName = [[_argumentVector clk_popFirstObject] substringFromIndex:2];
    return [self _parseOptionName:optionName usingMap:_longOptionMap error:outError];
}

- (CLKOAPState)_parseShortOption:(NSError **)outError
{
    NSAssert((_argumentVector.count > 0), @"unexpectedly empty argument vector");
    NSString *optionName = [[_argumentVector clk_popFirstObject] substringFromIndex:1];
    return [self _parseOptionName:optionName usingMap:_shortOptionMap error:outError];
}

- (CLKOAPState)_parseShortOptionGroup:(__unused NSError **)outError
{
    NSAssert((_argumentVector.count > 0), @"unexpectedly empty argument vector");
    NSString *optionGroup = [[_argumentVector clk_popFirstObject] substringFromIndex:1];
    
    // simple trick to implement short option groups:
    //    1. explode the group into individual options
    //    2. add the options to the front of argv
    //    3. let normal short option parsing take care of them
    NSRange range = [optionGroup rangeOfString:optionGroup];
    NSStringEnumerationOptions flags = (NSStringEnumerationByComposedCharacterSequences | NSStringEnumerationReverse); // backwards to preserve order when inserting
    [optionGroup enumerateSubstringsInRange:range options:flags usingBlock:^(NSString *optionName, __unused NSRange substringRange, __unused NSRange enclosingRange, __unused BOOL *outStop) {
        [_argumentVector insertObject:[@"-" stringByAppendingString:optionName] atIndex:0];
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
                NSDictionary *info = @{ NSLocalizedDescriptionKey : [NSString stringWithFormat:@"expected argument but encountered option-like token '%@'", argument] };
                *outError = [NSError errorWithDomain:NSPOSIXErrorDomain code:EINVAL userInfo:info];
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
        
        [_manifest accumulateArgument:argument forOption:self.currentOption.longName];
        self.currentOption = nil;
    } else {
        [_manifest accumulateRemainderArgument:argument];
    }
    
    return CLKOAPStateReadNextItem;
}

@end
