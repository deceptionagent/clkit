//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "CECombination_Private.h"

#import "CLKAssert.h"
#import "CEVariantTag.h"


@implementation CECombination
{
    NSDictionary<NSString *, id> *_combination; // { identifier : series value }
    CEVariantTag *_tag;
}

@synthesize tag = _tag;

- (instancetype)initWithCombinationDictionary:(NSDictionary<NSString *, id> *)dictionary tag:(CEVariantTag *)tag
{
    self = [super init];
    if (self != nil) {
        _combination = [dictionary copy];
        _tag = [tag copy];
    }
    
    return self;
}

- (void)dealloc
{
    [_combination release];
    [_tag release];
    [super dealloc];
}

- (id)objectForKeyedSubscript:(NSString *)identifier
{
    id value = _combination[identifier];
    CLKHardAssert((value != nil), NSInvalidArgumentException, @"subscripting unknown identifier '%@'", identifier);
    return value;
}

@end
