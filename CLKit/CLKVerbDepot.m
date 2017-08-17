//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import "CLKVerbDepot.h"

#import "CLKAssert.h"
#import "CLKVerb.h"
#import "NSMutableArray+CLKAdditions.h"


NSString * const CLKVerbDepotErrorDomain = @"CLKVerbDepotErrorDomain";


@implementation CLKVerbDepot
{
    NSArray<NSString *> *_argumentVector;
    NSMutableDictionary<NSString *, CLKVerb *> *_verbs;
}

- (instancetype)initWithArgumentVector:(NSArray<NSString *> *)argumentVector verbs:(NSArray<CLKVerb *> *)verbs
{
    CLKHardParameterAssert(argumentVector.count > 0);
    CLKHardParameterAssert(verbs.count > 0);
    
    self = [super init];
    if (self != nil) {
        _argumentVector = [argumentVector copy];
        _verbs = [[NSMutableDictionary alloc] init];
        for (CLKVerb *verb in verbs) {
            NSString *verbName = verb.name.lowercaseString; // verb lookups are case-insensitive
            CLKHardAssert((_verbs[verbName] == nil), NSInvalidArgumentException, @"duplicate verb name: '%@'", verb.name);
            _verbs[verbName] = verb;
        }
    }
    
    return self;
}

- (void)dealloc
{
    [_verbs release];
    [_argumentVector release];
    [super dealloc];
}

#pragma mark -

- (int)dispatch:(NSError **)outError
{
    CLKVerb *verb = nil;
    
    // scan the argument vector to find the verb, then pass the remaining arguments to the verb.
    // whatever's to the right of the verb should be the verb's optargs. that's what the verb
    // will want to pass to a parser.
    NSMutableArray *argumentVector = [[_argumentVector mutableCopy] autorelease];
    NSString *arg;
    while ((arg = [argumentVector clk_popFirstObject]) != nil) {
        verb = _verbs[arg.lowercaseString]; // verb lookups are case-insensitive
        if (verb != nil) {
            break;
        }
    }
    
    if (verb != nil) {
        return verb.block(argumentVector, outError);
    }
    
    if (outError != nil) {
        NSDictionary *info = @{ NSLocalizedDescriptionKey : @"verb not found" };
        *outError = [NSError errorWithDomain:CLKVerbDepotErrorDomain code:404 userInfo:info];
    }
    
    return 1;
}

@end
