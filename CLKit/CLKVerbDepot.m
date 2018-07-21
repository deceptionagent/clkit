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
    NSMutableDictionary<NSString *, id<CLKVerb>> *_verbMap;
}

- (instancetype)initWithArgumentVector:(NSArray<NSString *> *)argumentVector verbs:(NSArray<id<CLKVerb>> *)verbs
{
    CLKHardParameterAssert(argumentVector != nil);
    CLKHardParameterAssert(verbs.count > 0);
    
    self = [super init];
    if (self != nil) {
        _argumentVector = [argumentVector copy];
        
        _verbMap = [[NSMutableDictionary alloc] init];
        for (id<CLKVerb> verb in verbs) {
            CLKHardAssert((_verbMap[verb.name] == nil), NSInvalidArgumentException, @"encountered multiple verbs named '%@'", verb.name);
            _verbMap[verb.name] = verb;
        }
    }
    
    return self;
}

- (void)dealloc
{
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
    
    NSMutableArray<NSString *> *remainingArguments = [[_argumentVector mutableCopy] autorelease];
    NSString *verbName = [remainingArguments clk_popFirstObject];
    id<CLKVerb> verb = _verbMap[verbName];
    if (verb == nil) {
        NSError *error = [NSError clk_CLKErrorWithCode:CLKErrorUnrecognizedVerb description:@"%@: Unrecognized verb.", verbName];
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
