//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import "CLKVerbDepot.h"

#import "CLKVerb.h"
#import "NSMutableArray+CLKAdditions.h"


NSString * const CLKVerbDepotErrorDomain = @"CLKVerbDepotErrorDomain";


@implementation CLKVerbDepot

- (instancetype)initWithArgumentVector:(NSArray<NSString *> *)argumentVector verbs:(NSArray<CLKVerb *> *)verbs
{
    NSParameterAssert(argumentVector.count > 0);
    NSParameterAssert(verbs.count > 0);
    
    self = [super init];
    if (self != nil) {
        _argumentVector = [argumentVector copy];
        _verbs = [[NSMutableDictionary alloc] init];
        for (CLKVerb *verb in verbs) {
            NSAssert((_verbs[verb.name] == nil), @"duplicate verb name: '%@'", verb.name);
            _verbs[verb.name] = verb;
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
    // will want to pass to an optarg parser.
    NSMutableArray *argumentVector = [[_argumentVector mutableCopy] autorelease];
    NSString *arg;
    while ((arg = [argumentVector clk_popFirstObject]) != nil) {
        arg = [arg lowercaseString];
        verb = _verbs[arg];
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
