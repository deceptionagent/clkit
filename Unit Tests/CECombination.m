//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "CECombination_Private.h"

#import "CEVariantTag.h"


@implementation CECombination
{
    NSDictionary<NSString *, id> *_backing; // { identifier : series value }
    NSString *_variant;
}

@synthesize backing = _backing;
@synthesize variant = _variant;

+ (instancetype)combinationWithBacking:(NSDictionary<NSString *, id> *)backing variant:(NSString *)variant
{
    return [[[self alloc] initWithBacking:backing variant:variant] autorelease];
}

- (instancetype)initWithBacking:(NSDictionary<NSString *, id> *)backing variant:(NSString *)variant
{
    self = [super init];
    if (self != nil) {
        _backing = [backing copy];
        _variant = [variant copy];
    }
    
    return self;
}

- (void)dealloc
{
    [_backing release];
    [_variant release];
    [super dealloc];
}

- (NSUInteger)hash
{
    return (_variant.hash ^ _backing.hash);
}

- (BOOL)isEqual:(id)obj
{
    if (obj == self) {
        return YES;
    }
    
    if (![obj isKindOfClass:[CECombination class]]) {
        return NO;
    }
    
    return [self isEqualToCombination:(CECombination *)obj];
}

#pragma mark -

- (id)objectForKeyedSubscript:(NSString *)identifier
{
    id value = _backing[identifier];
//    NSAssert((value != nil), @"subscripting unknown identifier '%@'", identifier);
    return value;
}

- (BOOL)isEqualToCombination:(CECombination *)combination
{
    if (![_variant isEqualToString:combination.variant]) {
        return NO;
    }
    
    return [_backing isEqualToDictionary:combination.backing];
}

@end
