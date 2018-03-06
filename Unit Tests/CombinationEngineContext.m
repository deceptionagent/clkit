//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "CombinationEngineContext.h"

#import "CEVariantSeries.h"


@implementation CombinationEngineContext
{
    NSArray<CEVariantSeries *> *_tumblers;
    NSMapTable<CEVariantSeries *, CEVariantSeries *> *_taxonomyMap; // (inferior) tumbler -> (superior) next highest order tumbler
    BOOL _exhausted;
}

@synthesize tumblers = _tumblers;
@synthesize exhausted = _exhausted;

- (instancetype)initWithTumblers:(NSArray<CEVariantSeries *> *)tumblers
{
    self = [super init];
    if (self != nil) {
        _tumblers = [tumblers copy];
        
        _taxonomyMap = [[NSMapTable weakToWeakObjectsMapTable] retain];
        for (NSUInteger i = 0, j = 1 ; j < _tumblers.count ; i++, j++) {
            [_taxonomyMap setObject:_tumblers[j] forKey:_tumblers[i]];
        }
    }
    
    return self;
}

- (void)dealloc
{
    [_taxonomyMap release];
    [_tumblers release];
    [super dealloc];
}

#pragma mark -

- (nullable CEVariantSeries *)tumblerSuperiorToTumbler:(CEVariantSeries *)tumbler
{
    return [_taxonomyMap objectForKey:tumbler];
}

- (void)setExhausted
{
    _exhausted = YES;
}

@end

