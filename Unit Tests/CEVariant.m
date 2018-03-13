//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "CEVariant.h"


@implementation CEVariant
{
    CEVariantTag *_tag;
    NSArray *_sources;
}

@synthesize tag = _tag;
@synthesize sources = _sources;

+ (instancetype)variantWithTag:(CEVariantTag *)tag sources:(NSArray<CEVariantSource *> *)sources
{
    return [[[self alloc] initWithTag:tag sources:sources] autorelease];
}

- (instancetype)initWithTag:(CEVariantTag *)tag sources:(NSArray<CEVariantSource *> *)sources
{
    NSParameterAssert(sources.count > 0);
    
    self = [super init];
    if (self != nil) {
        _tag = [tag retain];
        _sources = [sources copy];
    }
    
    return self;
}

- (void)dealloc
{
    [_sources release];
    [_tag release];
    [super dealloc];
}

@end
