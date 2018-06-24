//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "CECombination_Private.h"

#import "CEVariantTag.h"


@implementation CECombination
{
    NSDictionary<NSString *, id> *_backing; // { identifier : series value }
    NSString *_tag;
}

@synthesize backing = _backing;
@synthesize tag = _tag;

+ (instancetype)combinationWithBacking:(NSDictionary<NSString *, id> *)backing tag:(NSString *)tag
{
    return [[[self alloc] initWithBacking:backing tag:tag] autorelease];
}

- (instancetype)initWithBacking:(NSDictionary<NSString *, id> *)backing tag:(NSString *)tag
{
    self = [super init];
    if (self != nil) {
        _backing = [backing copy];
        _tag = [tag copy];
    }
    
    return self;
}

- (void)dealloc
{
    [_backing release];
    [_tag release];
    [super dealloc];
}

- (NSUInteger)hash
{
    return (_tag.hash ^ _backing.hash);
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
    NSAssert((value != nil), @"subscripting unknown identifier '%@'", identifier);
    return value;
}

- (BOOL)isEqualToCombination:(CECombination *)combination
{
    if (![_tag isEqualToString:combination.tag]) {
        return NO;
    }
    
    return [_backing isEqualToDictionary:combination.backing];
}

@end
