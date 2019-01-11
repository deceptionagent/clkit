//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "CETemplate.h"


@implementation CETemplate
{
    NSArray<CETemplateSeries *> *_allSeries;
}

@synthesize allSeries = _allSeries;

+ (instancetype)templateWithSeries:(NSArray<CETemplateSeries *> *)series
{
    return [[self alloc] initWithSeries:series];
}

- (instancetype)initWithSeries:(NSArray<CETemplateSeries *> *)series
{
    self = [super init];
    if (self != nil) {
        _allSeries = [series copy];
    }
    
    return self;
}

@end
