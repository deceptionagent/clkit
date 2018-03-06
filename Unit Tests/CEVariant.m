//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "CEVariant.h"


@implementation CEVariant
{
    CEVariantTag *_tag;
    NSMutableSet *_sources;
    NSMapTable<CEVariantSource *, CEVariantSource *> *_taxonomyMap; // inferior : superior
}

@synthesize tag = _tag;
@synthesize sources = _sources;

- (instancetype)initWithTag:(CEVariantTag *)tag rootSource:(CEVariantSource *)source
{
    self = [super init];
    if (self != nil) {
        _tag = [tag retain];
        _sources = [[NSMutableSet setWithObject:source] retain];
        _taxonomyMap = [[NSMapTable strongToStrongObjectsMapTable] retain];
    }
    
    return self;
}

- (void)dealloc
{
    [_tag release];
    [_taxonomyMap release];
    [super dealloc];
}

#pragma mark -

- (void)addSource:(CEVariantSource *)superiorSource superiorToSource:(CEVariantSource *)inferiorSource
{
    NSAssert([_sources containsObject:inferiorSource], @"inferior source not registered: %@", inferiorSource);
    NSAssert(![_sources containsObject:superiorSource], @"superior source already registered: %@", superiorSource);
    NSAssert(([_taxonomyMap objectForKey:inferiorSource] == nil), @"inferior source already mapped: %@", inferiorSource);
    [_sources addObject:superiorSource];
    [_taxonomyMap setObject:superiorSource forKey:inferiorSource];
}

- (CEVariantSource *)sourceSuperiorToSource:(CEVariantSource *)source
{
    return [_taxonomyMap objectForKey:source];
}

@end
