//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CECombination_Private.h"
#import "CEGenerator.h"
#import "CEVariant.h"
#import "CEVariantSource.h"
#import "CEVariantTag.h"


NS_ASSUME_NONNULL_BEGIN

@interface Test_CEGenerator : XCTestCase

- (NSArray<CECombination *> *)generateCombinationsUsingGenerator:(CEGenerator *)generator;

@end

NS_ASSUME_NONNULL_END


@implementation Test_CEGenerator

- (NSArray<CECombination *> *)generateCombinationsUsingGenerator:(CEGenerator *)generator
{
    NSMutableArray<CECombination *> *combinations = [NSMutableArray array];
    
    [generator enumerateCombinations:^(CECombination *combination) {
        [combinations addObject:combination];
    }];
    
    return combinations;
}

#pragma mark -

- (void)testInit
{
    CEVariantTag *alphaTag = [CEVariantTag tag];
    CEVariantTag *bravoTag = [CEVariantTag tag];
    CEVariantSource *flarn = [CEVariantSource sourceWithIdentifier:@"flarn" values:@[ @(1) ]];
    CEVariantSource *barf = [CEVariantSource sourceWithIdentifier:@"barf" values:@[ @(1) ]];
    CEVariant *alphaVariant = [CEVariant variantWithTag:alphaTag sources:@[ flarn ]];
    CEVariant *bravoVariant = [CEVariant variantWithTag:bravoTag sources:@[ flarn, barf ]];
    
    CEGenerator *generator = [[[CEGenerator alloc] initWithVariants:@[ alphaVariant ]] autorelease];
    XCTAssertNotNil(generator);
    XCTAssertEqualObjects(generator.variants, @[ alphaVariant ]);
    
    generator = [[[CEGenerator alloc] initWithVariants:@[ alphaVariant, bravoVariant ]] autorelease];
    XCTAssertNotNil(generator);
    XCTAssertEqualObjects(generator.variants, (@[ alphaVariant, bravoVariant ]));
}

- (void)test_enumerateCombinations_singleVariant
{
    CEVariantTag *tag = [CEVariantTag tag];
    CEVariantSource *flarn = [CEVariantSource sourceWithIdentifier:@"flarn" values:@[ @(1), @(2) ]];
    CEVariantSource *barf = [CEVariantSource sourceWithIdentifier:@"barf" values:@[ @(3), @(4) ]];
    CEVariant *variant = [CEVariant variantWithTag:tag sources:@[ flarn, barf ]];
    NSArray *expectedCombinations = @[
        [CECombination combinationWithBacking:@{ @"flarn" : @(1), @"barf" : @(3) } tag:tag],
        [CECombination combinationWithBacking:@{ @"flarn" : @(2), @"barf" : @(3) } tag:tag],
        
        [CECombination combinationWithBacking:@{ @"flarn" : @(1), @"barf" : @(4) } tag:tag],
        [CECombination combinationWithBacking:@{ @"flarn" : @(2), @"barf" : @(4) } tag:tag]
    ];
    
    CEGenerator *generator = [[[CEGenerator alloc] initWithVariants:@[ variant ]] autorelease];
    NSArray *combinations = [self generateCombinationsUsingGenerator:generator];
    XCTAssertEqualObjects(combinations, expectedCombinations);
}

- (void)test_enumerateCombinations_multipleVariants
{
    CEVariantTag *alphaTag = [CEVariantTag tag];
    CEVariantTag *bravoTag = [CEVariantTag tag];
    CEVariantSource *flarn = [CEVariantSource sourceWithIdentifier:@"flarn" values:@[ @(1), @(2) ]];
    CEVariantSource *barf = [CEVariantSource sourceWithIdentifier:@"barf" values:@[ @(3), @(4) ]];
    CEVariant *alphaVariant = [CEVariant variantWithTag:alphaTag sources:@[ flarn ]];
    CEVariant *bravoVariant = [CEVariant variantWithTag:bravoTag sources:@[ flarn, barf ]];
    NSArray *expectedCombinations = @[
        /* alphaVariant */
        
        [CECombination combinationWithBacking:@{ @"flarn" : @(1) } tag:alphaTag],
        [CECombination combinationWithBacking:@{ @"flarn" : @(2) } tag:alphaTag],
        
        /* bravoVariant */
        
        [CECombination combinationWithBacking:@{ @"flarn" : @(1), @"barf" : @(3) } tag:bravoTag],
        [CECombination combinationWithBacking:@{ @"flarn" : @(2), @"barf" : @(3) } tag:bravoTag],
        
        [CECombination combinationWithBacking:@{ @"flarn" : @(1), @"barf" : @(4) } tag:bravoTag],
        [CECombination combinationWithBacking:@{ @"flarn" : @(2), @"barf" : @(4) } tag:bravoTag],
    ];

    CEGenerator *generator = [[[CEGenerator alloc] initWithVariants:@[ alphaVariant, bravoVariant ]] autorelease];
    NSArray *combinations = [self generateCombinationsUsingGenerator:generator];
    XCTAssertEqualObjects(combinations, expectedCombinations);
}

@end
