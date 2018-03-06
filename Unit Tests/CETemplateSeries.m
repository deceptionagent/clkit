//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "CETemplateSeries.h"

#import "CEVariantTag.h"


@implementation CETemplateSeries
{
    NSString *_identifier;
    NSArray *_values;
    NSArray<CEVariantTag *> *_variantTags;
}

@synthesize identifier = _identifier;
@synthesize values = _values;
@synthesize variantTags = _variantTags;

+ (instancetype)seriesWithIdentifier:(NSString *)identifier values:(NSArray *)values variantTags:(NSArray<CEVariantTag *> *)variantTags
{
    return [[[self alloc] initWithIdentifier:identifier values:values variantTags:variantTags] autorelease];
}

- (instancetype)initWithIdentifier:(NSString *)identifier values:(NSArray *)values variantTags:(NSArray<CEVariantTag *> *)variantTags
{
    self = [super init];
    if (self != nil) {
        _identifier = [identifier copy];
        _values = [values copy];
        _variantTags = [variantTags copy];
    }
    
    return self;
}

- (void)dealloc
{
    [_identifier release];
    [_values release];
    [_variantTags release];
    [super dealloc];
}

@end
