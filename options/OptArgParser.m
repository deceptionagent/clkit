//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import "OptArgParser.h"

#import "ArgumentTransformer.h"
#import "NSMutableArray+OptArgAdditions.h"
#import "Option.h"
#import "OptArgManifest.h"


@interface OptArgParser ()

@property (nullable, retain) Option *currentOption;

@end


@implementation OptArgParser

@synthesize currentOption = _currentOption;

+ (instancetype)parserWithArgumentVector:(NSArray<NSString *> *)argv options:(NSArray<Option *> *)options
{
    return [[[self alloc] initWithArgumentVector:argv options:options] autorelease];
}

- (instancetype)initWithArgumentVector:(NSArray<NSString *> *)argv options:(NSArray<Option *> *)options
{
    NSParameterAssert(argv != nil);
    NSParameterAssert(options != nil);
    
    self = [super init];
    if (self != nil) {
        _state = OAPStateReadNextItem;
        _argumentVector = [argv mutableCopy];
        _longOptionMap = [[NSMutableDictionary alloc] init];
        _shortOptionMap = [[NSMutableDictionary alloc] init];
        
        for (Option *opt in options) {
            NSAssert((_longOptionMap[opt.longName] == nil), @"duplicate option '%@'", opt.longName);
            NSAssert((_shortOptionMap[opt.shortName] == nil), @"duplicate option '%@'", opt.longName);
            _longOptionMap[opt.longName] = opt;
            _shortOptionMap[opt.shortName] = opt;
        }
        
        _manifest = [[OptArgManifest alloc] init];
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

- (nullable OptArgManifest *)parseArguments:(NSError **)outError
{
    NSAssert(_state != OAPStateBegin, @"cannot re-run a parser after use");
    
    while (_state != OAPStateEnd) {
        switch (_state) {
            case OAPStateBegin:
                _state = OAPStateReadNextItem;
                break;
            
            case OAPStateReadNextItem:
                _state = [self _readNextItem:outError];
                break;
            
            case OAPStateParseLongOption:
                _state = [self _parseLongOption:outError];
                break;
            
            case OAPStateParseShortOption:
                _state = [self _parseShortOption:outError];
                break;
            
            case OAPStateParseShortOptionGroup:
                _state = [self _parseShortOptionGroup:outError];
                break;
            
            case OAPStateParseArgument:
                _state = [self _parseArgument:outError];
                break;
            
            case OAPStateError:
                _state = OAPStateEnd;
                [_manifest release];
                _manifest = nil;
                break;
            
            case OAPStateEnd:
                break;
        }
    };
    
    return _manifest;
}

#pragma mark -
#pragma mark State Steps

- (OAParserState)_readNextItem:(NSError **)outError
{
    NSString *nextItem = _argumentVector.firstObject;
    
    // if we're reached the end of the arg vector, we've parsed everything
    if (nextItem == nil) {
        return OAPStateEnd;
    }
    
    // meaningless input
    // [TACK] if we wanted to support overflow arguments, we would remove the "--" guard and add that as a scenario
    if ([nextItem isEqualToString:@"--"] || [nextItem isEqualToString:@"-"]) {
        if (outError != nil) {
            NSDictionary *info = @{ NSLocalizedDescriptionKey : [NSString stringWithFormat:@"unexpected token in argument vector: '%@'", nextItem] };
            *outError = [NSError errorWithDomain:NSPOSIXErrorDomain code:EINVAL userInfo:info];
        }
        
        return OAPStateError;
    }
    
    if ([nextItem hasPrefix:@"--"]) {
        return OAPStateParseLongOption;
    }
    
    if ([nextItem hasPrefix:@"-"]) {
        if (nextItem.length == 2) {
            return OAPStateParseShortOption;
        }
        
        if (nextItem.length > 2) {
            return OAPStateParseShortOptionGroup;
        }
    }
    
    return OAPStateParseArgument;
}

- (OAParserState)_parseOptionName:(NSString *)optionName usingMap:(NSDictionary<NSString *, Option *> *)optionMap error:(NSError **)outError
{
    self.currentOption = optionMap[optionName];
    if (self.currentOption == nil) {
        if (outError != nil) {
            NSDictionary *info = @{ NSLocalizedDescriptionKey : [NSString stringWithFormat:@"unrecognized option: '%@'", optionName] };
            *outError = [NSError errorWithDomain:NSPOSIXErrorDomain code:EINVAL userInfo:info];
        }
        
        return OAPStateError;
    }
    
    if (self.currentOption.hasArgument) {
        return OAPStateParseArgument;
    }
    
    [_manifest accumulateFreeOption:self.currentOption.longName];
    self.currentOption = nil;
    return OAPStateReadNextItem;
}

- (OAParserState)_parseLongOption:(NSError **)outError
{
    NSAssert((_argumentVector.count > 0), @"unexpectedly empty argument vector");
    NSString *optionName = [[_argumentVector popFirstObject] substringFromIndex:2];
    return [self _parseOptionName:optionName usingMap:_longOptionMap error:outError];
}

- (OAParserState)_parseShortOption:(NSError **)outError
{
    NSAssert((_argumentVector.count > 0), @"unexpectedly empty argument vector");
    NSString *optionName = [[_argumentVector popFirstObject] substringFromIndex:1];
    return [self _parseOptionName:optionName usingMap:_shortOptionMap error:outError];
}

- (OAParserState)_parseShortOptionGroup:(__unused NSError **)outError
{
    NSAssert((_argumentVector.count > 0), @"unexpectedly empty argument vector");
    NSString *optionGroup = [[_argumentVector popFirstObject] substringFromIndex:1];
    
    // simple trick to implement short option groups:
    //    1. explode the group into individual options
    //    2. add the options to the front of argv
    //    3. let normal short option parsing take care of them
    NSRange range = [optionGroup rangeOfString:optionGroup];
    NSStringEnumerationOptions flags = (NSStringEnumerationByComposedCharacterSequences | NSStringEnumerationReverse); // backwards to preserve order when inserting
    [optionGroup enumerateSubstringsInRange:range options:flags usingBlock:^(NSString *optionName, __unused NSRange substringRange, __unused NSRange enclosingRange, __unused BOOL *outStop) {
        [_argumentVector insertObject:[@"-" stringByAppendingString:optionName] atIndex:0];
    }];
    
    return OAPStateReadNextItem;
}

- (OAParserState)_parseArgument:(NSError **)outError
{
    NSAssert((_argumentVector.count > 0), @"unexpectedly empty argument vector");
    NSString *argument = [_argumentVector popFirstObject];
    
    if (self.currentOption != nil) {
        id<ArgumentTransformer> transformer = self.currentOption.argumentTransformer;
        if (transformer != nil) {
            argument = [transformer transformArgument:argument error:outError];
            if (argument == nil) {
                return OAPStateError;
            }
        }
        
        [_manifest accumulateArgument:argument forOption:self.currentOption.longName];
        self.currentOption = nil;
    } else {
        [_manifest accumulateRemainderArgument:argument];
    }
    
    return OAPStateReadNextItem;
}

@end
