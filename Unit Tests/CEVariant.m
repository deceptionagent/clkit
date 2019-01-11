//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "CEVariant.h"


@implementation CEVariant
{
    NSString *_tag;
    NSArray *_sources;
}

@synthesize tag = _tag;
@synthesize sources = _sources;

+ (instancetype)variantWithTag:(NSString *)tag sources:(NSArray<CEVariantSource *> *)sources
{
    return [[self alloc] initWithTag:tag sources:sources];
}

- (instancetype)initWithTag:(NSString *)tag sources:(NSArray<CEVariantSource *> *)sources
{
    NSParameterAssert(sources.count > 0);
    
    self = [super init];
    if (self != nil) {
        _tag = [tag copy];
        _sources = [sources copy];
    }
    
    return self;
}

@end
