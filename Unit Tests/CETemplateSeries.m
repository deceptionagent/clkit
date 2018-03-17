//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "CETemplateSeries.h"

#import "CEVariantTag.h"


id CETemplateSeriesNoValue;


__attribute__((constructor))
static void _init(void)
{
    CETemplateSeriesNoValue = [[NSObject alloc] init];
}


@implementation CETemplateSeries
{
    NSString *_identifier;
    NSArray *_values;
    NSArray<CEVariantTag *> *_variants;
}

@synthesize identifier = _identifier;
@synthesize values = _values;
@synthesize variants = _variants;

+ (instancetype)seriesWithIdentifier:(NSString *)identifier values:(NSArray *)values variants:(NSArray<CEVariantTag *> *)variants
{
    return [[[self alloc] initWithIdentifier:identifier values:values variants:variants] autorelease];
}

- (instancetype)initWithIdentifier:(NSString *)identifier values:(NSArray *)values variants:(NSArray<CEVariantTag *> *)variants
{
    self = [super init];
    if (self != nil) {
        _identifier = [identifier copy];
        _values = [values copy];
        _variants = [variants copy];
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
