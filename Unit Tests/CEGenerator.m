//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "CEGenerator_Private.h"

#import "CLKAssert.h"
#import "CECombination.h"
#import "CEVariant.h"
#import "CEVariantView.h"


NS_ASSUME_NONNULL_BEGIN

@interface CEGenerator ()

- (void)_processVariant:(CEVariant *)variant usingCombinationBlock:(void (^)(CECombination *))combinationBlock;

@end

NS_ASSUME_NONNULL_END

@implementation CEGenerator
{
    NSArray<CEVariant *> *_variants;
    BOOL _exhausted;
}

@synthesize variants = _variants;

- (instancetype)initWithVariants:(NSArray<CEVariant *> *)variants
{
    NSAssert((variants.count > 0), @"initializing a generator with no variants");
    
    self = [super init];
    if (self != nil) {
        _variants = [variants copy];
    }
    
    return self;
}

#pragma mark -

- (void)enumerateCombinations:(void (^)(CECombination *))combinationBlock
{
    CLKHardAssert(!_exhausted, NSGenericException, @"attempting to re-run a generator");
    
    for (CEVariant *variant in _variants) {
        [self _processVariant:variant usingCombinationBlock:combinationBlock];
    }
    
    _exhausted = YES;
}

- (void)_processVariant:(CEVariant *)variant usingCombinationBlock:(void (^)(CECombination *))combinationBlock
{
    CEVariantView *view = [[CEVariantView alloc] initWithVariant:variant];
    while (!view.exhausted) {
        @autoreleasepool {
            CECombination *combination = view.combination;
            combinationBlock(combination);
            [view advance];
        }
    }
}

@end
