//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CECombination_Private.h"
#import "CETemplateSeries.h"
#import "CEVariant.h"
#import "CEVariantSource.h"
#import "CEVariantTag.h"
#import "CEVariantView.h"


NS_ASSUME_NONNULL_BEGIN

@interface Test_CEVariantView : XCTestCase

- (void)performTestWithVariantView:(CEVariantView *)view expectedCombinations:(NSArray<CECombination *> *)expectedCombinations;

@end

NS_ASSUME_NONNULL_END


@implementation Test_CEVariantView

- (void)performTestWithVariantView:(CEVariantView *)view expectedCombinations:(NSArray<CECombination *> *)expectedCombinations
{
    XCTAssertNotNil(view);
    XCTAssertNotNil(expectedCombinations);
    XCTAssertFalse(view.exhausted);
    
    for (CECombination *expectedCombination in expectedCombinations) {
        XCTAssertEqualObjects(view.combination, expectedCombination);
        XCTAssertFalse(view.exhausted);
        [view advance];
    }
    
    XCTAssertTrue(view.exhausted);
}

#pragma mark -

- (void)testInit
{
    CEVariantSource *flarn = [CEVariantSource sourceWithIdentifier:@"flarn" values:@[ @"quone" ]];
    CEVariantSource *barf = [CEVariantSource sourceWithIdentifier:@"barf" values:@[ @"xyzzy" ]];
    CEVariant *alphaVariant = [CEVariant variantWithTag:@"tag" sources:@[ flarn ]];
    CEVariant *bravoVariant = [CEVariant variantWithTag:@"tag" sources:@[ flarn, barf ]];
    
    CEVariantView *view = [[CEVariantView alloc] initWithVariant:alphaVariant];
    XCTAssertNotNil(view);
    XCTAssertEqual(view.variant, alphaVariant);
    XCTAssertFalse(view.exhausted);
    
    view = [[CEVariantView alloc] initWithVariant:bravoVariant];
    XCTAssertNotNil(view);
    XCTAssertEqual(view.variant, bravoVariant);
    XCTAssertFalse(view.exhausted);
}

- (void)testGenerateCombinations_evenSources
{
    CEVariantSource *flarn = [CEVariantSource sourceWithIdentifier:@"flarn" values:@[ @(1), @(2) ]];
    CEVariantSource *barf  = [CEVariantSource sourceWithIdentifier:@"barf"  values:@[ @(3), @(4) ]];
    CEVariantSource *quone = [CEVariantSource sourceWithIdentifier:@"quone" values:@[ @(5), @(6) ]];
    CEVariant *variant = [CEVariant variantWithTag:@"tag" sources:@[ flarn, barf, quone ]];
    
    NSArray *expectedCombinations = @[
        [CECombination combinationWithBacking:@{ @"flarn" : @(1), @"barf" : @(3), @"quone" : @(5) } variant:@"tag"],
        [CECombination combinationWithBacking:@{ @"flarn" : @(2), @"barf" : @(3), @"quone" : @(5) } variant:@"tag"],
        
        [CECombination combinationWithBacking:@{ @"flarn" : @(1), @"barf" : @(4), @"quone" : @(5) } variant:@"tag"],
        [CECombination combinationWithBacking:@{ @"flarn" : @(2), @"barf" : @(4), @"quone" : @(5) } variant:@"tag"],
        
        [CECombination combinationWithBacking:@{ @"flarn" : @(1), @"barf" : @(3), @"quone" : @(6) } variant:@"tag"],
        [CECombination combinationWithBacking:@{ @"flarn" : @(2), @"barf" : @(3), @"quone" : @(6) } variant:@"tag"],
        
        [CECombination combinationWithBacking:@{ @"flarn" : @(1), @"barf" : @(4), @"quone" : @(6) } variant:@"tag"],
        [CECombination combinationWithBacking:@{ @"flarn" : @(2), @"barf" : @(4), @"quone" : @(6) } variant:@"tag"],
    ];
    
    CEVariantView *view = [[[CEVariantView alloc] initWithVariant:variant] autorelease];
    [self performTestWithVariantView:view expectedCombinations:expectedCombinations];
}

- (void)testGenerateCombinations_unevenSources
{
    CEVariantSource *flarn = [CEVariantSource sourceWithIdentifier:@"flarn" values:@[ @(1) ]];
    CEVariantSource *barf  = [CEVariantSource sourceWithIdentifier:@"barf"  values:@[ @(2), @(3) ]];
    CEVariantSource *quone = [CEVariantSource sourceWithIdentifier:@"quone" values:@[ @(4), @(5), @(6) ]];
    CEVariant *variant = [CEVariant variantWithTag:@"tag" sources:@[ flarn, barf, quone ]];
    
    NSArray *expectedCombinations = @[
        [CECombination combinationWithBacking:@{ @"flarn" : @(1), @"barf" : @(2), @"quone" : @(4) } variant:@"tag"],
        [CECombination combinationWithBacking:@{ @"flarn" : @(1), @"barf" : @(3), @"quone" : @(4) } variant:@"tag"],
        
        [CECombination combinationWithBacking:@{ @"flarn" : @(1), @"barf" : @(2), @"quone" : @(5) } variant:@"tag"],
        [CECombination combinationWithBacking:@{ @"flarn" : @(1), @"barf" : @(3), @"quone" : @(5) } variant:@"tag"],
        
        [CECombination combinationWithBacking:@{ @"flarn" : @(1), @"barf" : @(2), @"quone" : @(6) } variant:@"tag"],
        [CECombination combinationWithBacking:@{ @"flarn" : @(1), @"barf" : @(3), @"quone" : @(6) } variant:@"tag"],
    ];
    
    CEVariantView *view = [[[CEVariantView alloc] initWithVariant:variant] autorelease];
    [self performTestWithVariantView:view expectedCombinations:expectedCombinations];
}

- (void)testGenerateCombinations_singleSource
{
    CEVariantSource *flarn = [CEVariantSource sourceWithIdentifier:@"flarn" values:@[ @(1), @(2), @(3) ]];
    CEVariant *variant = [CEVariant variantWithTag:@"tag" sources:@[ flarn ]];
    
    NSArray *expectedCombinations = @[
        [CECombination combinationWithBacking:@{ @"flarn" : @(1) } variant:@"tag"],
        [CECombination combinationWithBacking:@{ @"flarn" : @(2) } variant:@"tag"],
        [CECombination combinationWithBacking:@{ @"flarn" : @(3) } variant:@"tag"],
    ];
    
    CEVariantView *view = [[[CEVariantView alloc] initWithVariant:variant] autorelease];
    [self performTestWithVariantView:view expectedCombinations:expectedCombinations];
}

- (void)testGenerateCombinations_singleSource_singleValue
{
    CEVariantSource *flarn = [CEVariantSource sourceWithIdentifier:@"flarn" values:@[ @(1) ]];
    CEVariant *variant = [CEVariant variantWithTag:@"tag" sources:@[ flarn ]];
    CECombination *expectedCombination = [CECombination combinationWithBacking:@{ @"flarn" : @(1) } variant:@"tag"];
    
    CEVariantView *view = [[[CEVariantView alloc] initWithVariant:variant] autorelease];
    [self performTestWithVariantView:view expectedCombinations:@[ expectedCombination ]];
}

- (void)testGenerateCombinations_multipleSources_singleValue
{
    CEVariantSource *flarn = [CEVariantSource sourceWithIdentifier:@"flarn" values:@[ @(1) ]];
    CEVariantSource *barf  = [CEVariantSource sourceWithIdentifier:@"barf"  values:@[ @(2) ]];
    CEVariantSource *quone = [CEVariantSource sourceWithIdentifier:@"quone" values:@[ @(3) ]];
    CEVariant *variant = [CEVariant variantWithTag:@"tag" sources:@[ flarn, barf, quone ]];
    CECombination *expectedCombination = [CECombination combinationWithBacking:@{ @"flarn" : @(1), @"barf" : @(2), @"quone" : @(3) } variant:@"tag"];
    
    CEVariantView *view = [[[CEVariantView alloc] initWithVariant:variant] autorelease];
    [self performTestWithVariantView:view expectedCombinations:@[ expectedCombination ]];
}

- (void)testGenerateCombinations_noValueMarker
{
    id elide = CEVariantSource.noValueMarker;
    CEVariantSource *flarn = [CEVariantSource sourceWithIdentifier:@"flarn" values:@[ @(1), @(2) ]];
    CEVariantSource *barf  = [CEVariantSource sourceWithIdentifier:@"barf"  values:@[ elide, @(4) ]];
    CEVariantSource *quone = [CEVariantSource sourceWithIdentifier:@"quone" values:@[ @(5), elide, @(6) ]];
    CEVariant *variant = [CEVariant variantWithTag:@"tag" sources:@[ flarn, barf, quone ]];
    
    NSArray *expectedCombinations = @[
        [CECombination combinationWithBacking:@{ @"flarn" : @(1), @"quone" : @(5) } variant:@"tag"],
        [CECombination combinationWithBacking:@{ @"flarn" : @(2), @"quone" : @(5) } variant:@"tag"],
        
        [CECombination combinationWithBacking:@{ @"flarn" : @(1), @"barf" : @(4), @"quone" : @(5) } variant:@"tag"],
        [CECombination combinationWithBacking:@{ @"flarn" : @(2), @"barf" : @(4), @"quone" : @(5) } variant:@"tag"],
        
        [CECombination combinationWithBacking:@{ @"flarn" : @(1) } variant:@"tag"],
        [CECombination combinationWithBacking:@{ @"flarn" : @(2) } variant:@"tag"],
        
        [CECombination combinationWithBacking:@{ @"flarn" : @(1), @"barf" : @(4) } variant:@"tag"],
        [CECombination combinationWithBacking:@{ @"flarn" : @(2), @"barf" : @(4) } variant:@"tag"],
        
        [CECombination combinationWithBacking:@{ @"flarn" : @(1), @"quone" : @(6) } variant:@"tag"],
        [CECombination combinationWithBacking:@{ @"flarn" : @(2), @"quone" : @(6) } variant:@"tag"],
        
        [CECombination combinationWithBacking:@{ @"flarn" : @(1), @"barf" : @(4), @"quone" : @(6) } variant:@"tag"],
        [CECombination combinationWithBacking:@{ @"flarn" : @(2), @"barf" : @(4), @"quone" : @(6) } variant:@"tag"],
    ];
    
    CEVariantView *view = [[[CEVariantView alloc] initWithVariant:variant] autorelease];
    [self performTestWithVariantView:view expectedCombinations:expectedCombinations];
}

@end
