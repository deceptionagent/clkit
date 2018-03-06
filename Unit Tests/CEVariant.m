//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "CEVariant.h"


@implementation CEVariant
{
    CEVariantSeries *_series;
    CEVariantTag *_tag;
}

@synthesize series = _series;
@synthesize tag = _tag;

- (instancetype)initWithSeries:(CEVariantSeries *)series tag:(CEVariantTag *)tag
{
    self = [super init];
    if (self != nil) {
        _series = [series retain];
        _tag = [tag retain];
    }
    
    return self;
}

- (void)dealloc
{
    [_series release];
    [_tag release];
    [super dealloc];
}

@end
