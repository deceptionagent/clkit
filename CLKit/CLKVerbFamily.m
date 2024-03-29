//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "CLKVerbFamily.h"

#import "CLKAssert.h"
#import "CLKVerb.h"

NS_ASSUME_NONNULL_BEGIN

@interface CLKVerbFamily ()

- (instancetype)_initWithName:(NSString *)name verbs:(NSArray<id<CLKVerb>> *)verbs NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END

@implementation CLKVerbFamily
{
    NSString *_name;
    NSArray<id<CLKVerb>> *_verbs;
    NSMutableDictionary<NSString *, id<CLKVerb>> *_verbMap;
}

@synthesize name = _name;
@synthesize verbs = _verbs;

+ (instancetype)familyWithName:(NSString *)name verbs:(NSArray<id<CLKVerb>> *)verbs
{
    return [[self alloc] _initWithName:name verbs:verbs];
}

- (instancetype)_initWithName:(NSString *)name verbs:(NSArray<id<CLKVerb>> *)verbs
{
    CLKHardParameterAssert(name != nil);
    CLKHardParameterAssert(verbs.count > 0);
    
    self = [super init];
    if (self != nil) {
        _name = [name copy];
        _verbs = [verbs copy];
        _verbMap = [[NSMutableDictionary alloc] init];
        
        for (id<CLKVerb> verb in verbs) {
            CLKHardAssert((_verbMap[verb.name] == nil), NSInvalidArgumentException, @"encountered multiple verbs named '%@' for verb family '%@'", verb.name, _name);
            _verbMap[verb.name] = verb;
        }
    }
    
    return self;
}

- (nullable id<CLKVerb>)verbNamed:(NSString *)verbName
{
    return _verbMap[verbName];
}

@end
