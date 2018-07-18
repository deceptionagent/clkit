//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "CLKVerbDepot.h"

#import "CLKAssert.h"
#import "CLKVerb.h"


@implementation CLKVerbDepot
{
    NSArray<NSString *> *_argumentVector;
    NSMutableDictionary<NSString *, id<CLKVerb>> *_verbMap;
}

- (instancetype)initWithArgumentVector:(NSArray<NSString *> *)argumentVector verbs:(NSArray<id<CLKVerb>> *)verbs
{
    CLKHardParameterAssert(argumentVector.count > 0);
    CLKHardParameterAssert(verbs.count > 0);
    
    self = [super init];
    if (self != nil) {
        _argumentVector = [argumentVector copy];
        
        _verbMap = [[NSMutableDictionary alloc] init];
        for (id<CLKVerb> verb in verbs) {
            CLKHardAssert((_verbMap[verb.name] == nil), NSInvalidArgumentException, @"duplicate verb name: '%@'", verb.name);
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

@end
