//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "CombinationEngine.h"

#import "CEVariantSeries.h"
#import "CombinationEngineContext.h"


id CEPrototypeNoValue;


__attribute__((constructor))
static void _init(void)
{
    CEPrototypeNoValue = [[NSObject alloc] init];
}


NS_ASSUME_NONNULL_BEGIN

@interface _CombinationVariant : NSObject
{
    NSArray<CEVariantSeries *> *_tumblers;
}

- (instancetype)initWithTumblers:(NSArray<CEVariantSeries *> *)tumblers;

@property (readonly) NSArray<CEVariantSeries *> *tumblers;

@end

NS_ASSUME_NONNULL_END


@implementation _CombinationVariant

@synthesize tumblers = _tumblers;

- (instancetype)initWithTumblers:(NSArray<CEVariantSeries *> *)tumblers
{
    self = [super init];
    if (self != nil) {
        _tumblers = [tumblers copy];
    }
    
    return self;
}

- (void)dealloc
{
    [_tumblers release];
    [super dealloc];
}

@end


#pragma mark -


@interface CombinationEngine () <CEVariantSeriesDelegate>

@end


@implementation CombinationEngine
{
    NSMutableArray<CEVariantSeries *> *_baseTumblers;
    NSMutableArray<_CombinationVariant *> *_variants;
    CombinationEngineContext *_currentCombinationContext;
}

- (instancetype)initWithPrototype:(NSDictionary<NSString *, NSArray *> *)prototype
{
    NSParameterAssert(prototype.count > 0);
    
    self = [super init];
    if (self != nil) {
        _baseTumblers = [[NSMutableArray alloc] init];
        for (NSString *key in prototype) {
            id values = prototype[key];
            CEVariantSeries *tumbler = [[CEVariantSeries alloc] initWithIdentifier:key values:values delegate:self];
            [_baseTumblers addObject:tumbler];
            [tumbler release];
        }
    }
    
    return self;
}

- (void)dealloc
{
    [_currentCombinationContext release];
    [_variants release];
    [_baseTumblers release];
    [super dealloc];
}

- (void)enumerateCombinations:(void (^)(NSDictionary<NSString *, id> *))combinationBlock
{
    // ...
}

- (void)_enumerateCombinations:(void (^)(NSDictionary<NSString *, id> *))combinationBlock
{
    NSAssert(_currentCombinationContext != nil, @"no context set");
    NSAssert(!_currentCombinationContext.exhausted, @"attempting to reuse an exhausted context");
    
    while (!_currentCombinationContext.exhausted) {
        @autoreleasepool {
            // build a combination, dispatch it to the caller, then advance the machine
            NSDictionary *combination = [self _combinationFromCurrentContext];
            combinationBlock(combination);
            [_currentCombinationContext.tumblers[0] advance];
        }
    }
}

- (NSDictionary<NSString *, id> *)_combinationFromCurrentContext
{
    NSMutableDictionary *combination = [[[NSMutableDictionary alloc] init] autorelease];
    for (CEVariantSeries *tumbler in _currentCombinationContext.tumblers) {
        if (tumbler.currentValue == CEPrototypeNoValue) {
            // skip this tumbler
            continue;
        }
        
        combination[tumbler.identifier] = tumbler.currentValue;
    }
    
    return combination;
}

- (void)addVariantPrototype:(NSDictionary<NSString *, NSArray *> *)prototype
{
    NSMutableArray *tumblers = [[NSMutableArray alloc] init];
    for (NSString *identifier in prototype) {
        id values = prototype[identifier];
        CEVariantSeries *tumbler = [[CEVariantSeries alloc] initWithIdentifier:identifier values:values delegate:self];
        [tumblers addObject:tumbler];
        [tumbler release];
    }
    
    _CombinationVariant *variant = [[_CombinationVariant alloc] initWithTumblers:tumblers];
    
    if (_variants == nil) {
        _variants = [[NSMutableArray alloc] init];
    }
    
    [_variants addObject:variant];
    [variant release];
    [tumblers release];
}

#pragma mark -
#pragma mark <CEVariantSeriesDelegate>

- (void)variantSeriesDidAdvanceToInitialPosition:(CEVariantSeries *)series
{
//    CEVariantSeries *nextTumbler = [_currentCombinationContext tumblerSuperiorToTumbler:tumbler];
//    if (nextTumbler != nil) {
//        [nextTumbler turn];
//    } else {
//        [_currentCombinationContext setExhausted];
//    }
}

@end
