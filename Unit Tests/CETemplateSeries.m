//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "CETemplateSeries.h"

#import "CEVariantTag.h"


@implementation CETemplateSeries
{
    NSString *_identifier;
    NSArray *_values;
    NSArray<NSString *> *_variants;
    BOOL _elidable;
}

@synthesize identifier = _identifier;
@synthesize values = _values;
@synthesize variants = _variants;
@synthesize elidable = _elidable;

+ (instancetype)seriesWithIdentifier:(NSString *)identifier values:(NSArray *)values variant:(NSString *)variant
{
    return [[[self alloc] initWithIdentifier:identifier values:values elidable:NO variants:@[ variant ]] autorelease];
}

+ (instancetype)seriesWithIdentifier:(NSString *)identifier values:(NSArray *)values variants:(NSArray<NSString *> *)variants
{
    return [[[self alloc] initWithIdentifier:identifier values:values elidable:NO variants:variants] autorelease];
}

+ (instancetype)elidableSeriesWithIdentifier:(NSString *)identifier values:(NSArray *)values variant:(NSString *)variant
{
    return [[[self alloc] initWithIdentifier:identifier values:values elidable:YES variants:@[ variant ]] autorelease];
}

+ (instancetype)elidableSeriesWithIdentifier:(NSString *)identifier values:(NSArray *)values variants:(NSArray<NSString *> *)variants
{
    return [[[self alloc] initWithIdentifier:identifier values:values elidable:YES variants:variants] autorelease];
}

- (instancetype)initWithIdentifier:(NSString *)identifier values:(NSArray *)values elidable:(BOOL)elidable variants:(NSArray<NSString *> *)variants
{
    self = [super init];
    if (self != nil) {
        _identifier = [identifier copy];
        _values = [values copy];
        _variants = [variants copy];
        _elidable = elidable;
    }
    
    return self;
}

- (void)dealloc
{
    [_identifier release];
    [_values release];
    [_variants release];
    [super dealloc];
}

@end
