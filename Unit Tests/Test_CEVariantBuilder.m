//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CETemplate.h"
#import "CETemplateSeries.h"
#import "CEVariant.h"
#import "CEVariantBuilder.h"
#import "CEVariantSource.h"
#import "CEVariantTag.h"


NS_ASSUME_NONNULL_BEGIN

@interface Test_CEVariantBuilder : XCTestCase

- (void)performTestWithTemplate:(CETemplate *)template expectedVariants:(NSArray<CEVariant *> *)expectedVariants;
- (void)verifyVariants:(NSArray<CEVariant *> *)variants usingExpectedVariants:(NSArray<CEVariant *> *)expectedVariants;
- (void)verifyVariantSources:(NSArray<CEVariantSource *> *)variantSources usingExpectedVariantSources:(NSArray<CEVariantSource *> *)expectedVariantSources;

@end

NS_ASSUME_NONNULL_END


@implementation Test_CEVariantBuilder

- (void)performTestWithTemplate:(CETemplate *)template expectedVariants:(NSArray<CEVariant *> *)expectedVariants
{
    NSArray<CEVariant *> *variants = [CEVariantBuilder variantsFromTemplate:template];
    XCTAssertNotNil(variants);
    if (variants == nil) {
        return;
    }
    
    [self verifyVariants:variants usingExpectedVariants:expectedVariants];
}

- (void)verifyVariants:(NSArray<CEVariant *> *)variants usingExpectedVariants:(NSArray<CEVariant *> *)expectedVariants
{
    XCTAssertEqual(variants.count, expectedVariants.count);
    if (variants.count != expectedVariants.count) {
        return;
    }
    
    for (NSUInteger i = 0 ; i < variants.count ; i++) {
        CEVariant *variant = variants[i];
        CEVariant *expectedVariant = expectedVariants[i];
        XCTAssertEqual(variant.tag, expectedVariant.tag);
        XCTAssertNotNil(variant.sources);
        if (variant.sources == nil) {
            continue;
        }
        
        [self verifyVariantSources:variant.sources usingExpectedVariantSources:expectedVariant.sources];
    }
}

- (void)verifyVariantSources:(NSArray<CEVariantSource *> *)variantSources usingExpectedVariantSources:(NSArray<CEVariantSource *> *)expectedVariantSources
{
    XCTAssertEqual(variantSources.count, expectedVariantSources.count);
    if (variantSources.count != expectedVariantSources.count) {
        return;
    }
    
    for (NSUInteger i = 0 ; i < variantSources.count ; i++) {
        CEVariantSource *variantSource = variantSources[i];
        CEVariantSource *expectedVariantSource = expectedVariantSources[i];
        XCTAssertEqualObjects(variantSource.identifier, expectedVariantSource.identifier);
        XCTAssertEqualObjects(variantSource.values, expectedVariantSource.values);
    }
}

#pragma mark -

- (void)testVariantFromTemplateSeries
{
    CETemplateSeries *series = [CETemplateSeries seriesWithIdentifier:@"flarn" values:@[ @(420) ] variants:@[ @"tag" ]];
    CETemplate *template = [CETemplate templateWithSeries:@[ series ]];
    
    // expectation
    CEVariantSource *source = [CEVariantSource sourceWithIdentifier:@"flarn" values:@[ @(420) ]];
    CEVariant *variant = [CEVariant variantWithTag:@"tag" sources:@[ source ]];
    
    [self performTestWithTemplate:template expectedVariants:@[ variant ]];
}

- (void)testVariantFromElidableTemplateSeries
{
    CETemplateSeries *series = [CETemplateSeries elidableSeriesWithIdentifier:@"flarn" values:@[ @(420) ] variants:@[ @"tag" ]];
    CETemplate *template = [CETemplate templateWithSeries:@[ series ]];
    
    // expectation
    CEVariantSource *source = [CEVariantSource sourceWithIdentifier:@"flarn" values:@[ CEVariantSource.noValueMarker, @(420) ]];
    CEVariant *variant = [CEVariant variantWithTag:@"tag" sources:@[ source ]];
    
    [self performTestWithTemplate:template expectedVariants:@[ variant ]];
}

- (void)testVariantFromMultipleTemplateSeries
{
    CETemplateSeries *seriesAlpha = [CETemplateSeries seriesWithIdentifier:@"alpha" values:@[ @(7) ]   variants:@[ @"tag" ]];
    CETemplateSeries *seriesBravo = [CETemplateSeries seriesWithIdentifier:@"bravo" values:@[ @(420) ] variants:@[ @"tag" ]];
    CETemplate *template = [CETemplate templateWithSeries:@[ seriesAlpha, seriesBravo ]];
    
    // expectation
    CEVariantSource *sourceAlpha = [CEVariantSource sourceWithIdentifier:@"alpha" values:@[ @(7) ]];
    CEVariantSource *sourceBravo = [CEVariantSource sourceWithIdentifier:@"bravo" values:@[ @(420) ]];
    CEVariant *variant = [CEVariant variantWithTag:@"tag" sources:@[ sourceAlpha, sourceBravo ]];
    
    [self performTestWithTemplate:template expectedVariants:@[ variant ]];
}

// i don't know why you'd do this but it should behave sanely
- (void)testMultipleVariantsFromTemplateSeries
{
    CETemplateSeries *series = [CETemplateSeries seriesWithIdentifier:@"flarn" values:@[ @(420) ] variants:@[ @"alpha", @"bravo" ]];
    CETemplate *template = [CETemplate templateWithSeries:@[ series ]];
    
    CEVariantSource *source = [CEVariantSource sourceWithIdentifier:@"flarn" values:@[ @(420) ]];
    CEVariant *alphaVariant = [CEVariant variantWithTag:@"alpha" sources:@[ source ]];
    CEVariant *bravoVariant = [CEVariant variantWithTag:@"bravo" sources:@[ source ]];
    
    [self performTestWithTemplate:template expectedVariants:@[ alphaVariant, bravoVariant ]];
}

- (void)testMultipleVariantsFromMultipleTemplateSeries
{
    NSString *alphaTag = @"alpha"; // elec + muon
    NSString *bravoTag = @"bravo"; // elec + tau
    NSString *charlieTag = @"charlie"; // charm
    
    CETemplateSeries *elecSeries  = [CETemplateSeries seriesWithIdentifier:@"elec"  values:@[ @(1) ] variants:@[ alphaTag, bravoTag ]];
    CETemplateSeries *muonSeries  = [CETemplateSeries seriesWithIdentifier:@"muon"  values:@[ @(2) ] variants:@[ alphaTag ]];
    CETemplateSeries *tauSeries   = [CETemplateSeries seriesWithIdentifier:@"tau"   values:@[ @(3) ] variants:@[ bravoTag ]];
    CETemplateSeries *charmSeries = [CETemplateSeries seriesWithIdentifier:@"charm" values:@[ @(4) ] variants:@[ charlieTag ]];
    CETemplate *template = [CETemplate templateWithSeries:@[ elecSeries, muonSeries, tauSeries, charmSeries ]];
    
    CEVariantSource *elecSource  = [CEVariantSource sourceWithIdentifier:@"elec"  values:@[ @(1) ]];
    CEVariantSource *muonSource  = [CEVariantSource sourceWithIdentifier:@"muon"  values:@[ @(2) ]];
    CEVariantSource *tauSource   = [CEVariantSource sourceWithIdentifier:@"tau"   values:@[ @(3) ]];
    CEVariantSource *charmSource = [CEVariantSource sourceWithIdentifier:@"charm" values:@[ @(4) ]];
    
    CEVariant *alphaVariant   = [CEVariant variantWithTag:alphaTag sources:@[ elecSource, muonSource ]];
    CEVariant *bravoVariant   = [CEVariant variantWithTag:bravoTag sources:@[ elecSource, tauSource ]];
    CEVariant *charlieVariant = [CEVariant variantWithTag:charlieTag sources:@[ charmSource ]];
    
    [self performTestWithTemplate:template expectedVariants:@[ alphaVariant, bravoVariant, charlieVariant ]];
}

@end





