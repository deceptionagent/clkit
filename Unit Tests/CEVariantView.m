//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "CEVariantView.h"

#import "CECombination_Private.h"
#import "CEVariant.h"
#import "CEVariantSource.h"
#import "CEVariantSourceView.h"


NS_ASSUME_NONNULL_BEGIN

@interface CEVariantView () <CEVariantSourceViewObserver>

@property (readonly) CEVariantSourceView *_rootSourceView;

- (void)_setSourceView:(CEVariantSourceView *)superiorSourceView superiorToSourceView:(CEVariantSourceView *)inferiorSourceView;
- (nullable CEVariantSourceView *)_sourceViewSuperiorToSourceView:(CEVariantSourceView *)sourceView;

@end

NS_ASSUME_NONNULL_END


@implementation CEVariantView
{
    BOOL _exhausted;
    CEVariant *_variant;
    NSMutableArray<CEVariantSourceView *> *_sourceViews;
    NSMapTable<CEVariantSourceView *, CEVariantSourceView *> *_taxonomyMap; // inferior : superior
}

@synthesize variant = _variant;
@synthesize exhausted = _exhausted;

- (instancetype)initWithVariant:(CEVariant *)variant
{
    self = [super init];
    if (self != nil) {
        _variant = [variant retain];
        _sourceViews = [[NSMutableArray alloc] init];
        _taxonomyMap = [[NSMapTable strongToStrongObjectsMapTable] retain];
        
        for (CEVariantSource *source in variant.sources) {
            CEVariantSourceView *view = [[CEVariantSourceView alloc] initWithVariantSource:source];
            [view addObserver:self];
            [_sourceViews addObject:view];
            [view release];
        }
        
        for (NSUInteger i = 0, j = 1 ; j < _sourceViews.count ; i++, j++) {
            CEVariantSourceView *superiorView = _sourceViews[j];
            CEVariantSourceView *inferiorView = _sourceViews[i];
            [self _setSourceView:superiorView superiorToSourceView:inferiorView];
        }
    }
    
    return self;
}

- (void)dealloc
{
    [_taxonomyMap release];
    [_sourceViews release];
    [_variant release];
    [super dealloc];
}

#pragma mark -

- (void)_setSourceView:(CEVariantSourceView *)superiorSourceView superiorToSourceView:(CEVariantSourceView *)inferiorSourceView
{
    NSAssert(([_taxonomyMap objectForKey:inferiorSourceView] == nil), @"inferior source view already mapped: %@", inferiorSourceView);
    [_taxonomyMap setObject:superiorSourceView forKey:inferiorSourceView];
}

- (CEVariantSourceView *)_sourceViewSuperiorToSourceView:(CEVariantSourceView *)sourceView
{
    return [_taxonomyMap objectForKey:sourceView];
}

#pragma mark -

- (CECombination *)combination
{
    NSMutableDictionary<NSString *, id> *combinationDict = [NSMutableDictionary dictionary];
    
    for (CEVariantSourceView *sourceView in _sourceViews) {
        id value = sourceView.value;
        if (value != nil) {
            combinationDict[sourceView.variantSource.identifier] = value;
        }
    }
    
    return [[[CECombination alloc] initWithBacking:combinationDict tag:_variant.tag] autorelease];
}

- (CEVariantSourceView *)_rootSourceView
{
    return _sourceViews[0];
}

- (void)advance
{
    [self._rootSourceView advance];
}

#pragma mark -
#pragma mark <CEVariantSourceViewObserver>

- (void)variantSourceViewDidAdvanceToInitialValue:(CEVariantSourceView *)sourceView
{
    CEVariantSourceView *superiorView = [self _sourceViewSuperiorToSourceView:sourceView];
    if (superiorView != nil) {
        [superiorView advance];
    } else {
        _exhausted = YES;
    }
}

@end
