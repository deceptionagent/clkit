//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "CLKVerbDepot.h"

#import <sysexits.h>

#import "CLKArgumentParser.h"
#import "CLKAssert.h"
#import "CLKCommandResult.h"
#import "CLKError.h"
#import "CLKVerb.h"
#import "CLKVerbFamily.h"
#import "NSMutableArray+CLKAdditions.h"
#import "NSError+CLKAdditions.h"


NS_ASSUME_NONNULL_BEGIN

@interface CLKVerbDepot ()

- (CLKCommandResult *)_runVerb:(id<CLKVerb>)verb withArgumentVector:(NSArray<NSString *> *)argumentVector;

@end

NS_ASSUME_NONNULL_END

@implementation CLKVerbDepot
{
    NSArray<NSString *> *_argumentVector;
    CLKVerbFamily *_topLevelVerbFamily;
    NSMutableDictionary<NSString *, CLKVerbFamily *> *_verbFamilyMap;
}

//- (instancetype)initWithArgv:(const char * _Nonnull [])argv argc:(int)argc verbs:(NSArray<CLKVerb> *)verbs

- (instancetype)initWithArgumentVector:(NSArray<NSString *> *)argumentVector verbs:(NSArray<id<CLKVerb>> *)verbs
{
    return [self initWithArgumentVector:argumentVector verbs:verbs verbFamilies:nil];
}

- (instancetype)initWithArgumentVector:(NSArray<NSString *> *)argumentVector verbs:(NSArray<id<CLKVerb>> *)verbs verbFamilies:(NSArray<CLKVerbFamily *> *)verbFamilies
{
    CLKHardParameterAssert(argumentVector != nil);
    CLKHardParameterAssert(verbs.count > 0);
    
    self = [super init];
    if (self != nil) {
        _argumentVector = [argumentVector copy];
        _topLevelVerbFamily = [[CLKVerbFamily familyWithName:@"(top-level verbs)" verbs:verbs] retain];
        _verbFamilyMap = [[NSMutableDictionary alloc] init];
        
        for (CLKVerbFamily *family in verbFamilies) {
            CLKHardAssert(([_topLevelVerbFamily verbNamed:family.name] == nil), NSInvalidArgumentException, @"encountered identically named top-level verb and verb family: '%@'", family.name);
            CLKHardAssert((_verbFamilyMap[family.name] == nil), NSInvalidArgumentException, @"encountered multiple verb families named '%@'", family.name);
            _verbFamilyMap[family.name] = family;
        }
    }
    
    return self;
}

- (void)dealloc
{
    [_verbFamilyMap release];
    [_topLevelVerbFamily release];
    [_argumentVector release];
    [super dealloc];
}

#pragma mark -

- (CLKCommandResult *)dispatchVerb
{
    if (_argumentVector.count == 0) {
        NSError *error = [NSError clk_CLKErrorWithCode:CLKErrorNoVerbSpecified description:@"No verb specified."];
        return [CLKCommandResult resultWithExitStatus:EX_USAGE errors:@[ error ]];
    }
    
    id<CLKVerb> verb = nil;
    NSMutableArray<NSString *> *remainingArguments = [[_argumentVector mutableCopy] autorelease];
    NSString *verbOrFamilyName = [remainingArguments clk_popFirstObject];
    
    CLKVerbFamily *family = _verbFamilyMap[verbOrFamilyName];
    if (family != nil) {
        verbOrFamilyName = [remainingArguments clk_popFirstObject];
        verb = [family verbNamed:verbOrFamilyName];
    } else {
        verb = [_topLevelVerbFamily verbNamed:verbOrFamilyName];
    }
    
    if (verb == nil) {
        NSError *error;
        if (family != nil) {
            error = [NSError clk_CLKErrorWithCode:CLKErrorUnrecognizedVerb description:@"%@: Unrecognized %@ verb.", verbOrFamilyName, family.name];
        } else {
            error = [NSError clk_CLKErrorWithCode:CLKErrorUnrecognizedVerb description:@"%@: Unrecognized verb.", verbOrFamilyName];
        }
        
        return [CLKCommandResult resultWithExitStatus:EX_USAGE errors:@[ error ]];
    }
    
    return [self _runVerb:verb withArgumentVector:remainingArguments];
}

- (CLKCommandResult *)_runVerb:(id<CLKVerb>)verb withArgumentVector:(NSArray<NSString *> *)argumentVector
{
    NSArray<CLKOption *> *options = (verb.options != nil ? verb.options : @[]);
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:argumentVector options:options optionGroups:verb.optionGroups];
    CLKArgumentManifest *manifest = [parser parseArguments];
    if (manifest == nil) {
        return [CLKCommandResult resultWithExitStatus:EX_USAGE errors:parser.errors];
    }
    
    return [verb runWithManifest:manifest];
}

@end
