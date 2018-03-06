//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CEVariant.h"
#import "CEVariantSeries.h"
#import "CEVariantTag.h"


@interface Test_CEVariant : XCTestCase <CEVariantSeriesDelegate>

@end


@implementation Test_CEVariant

#pragma mark <CEVariantSeriesDelegate>

- (void)variantSeriesDidAdvanceToInitialPosition:(__unused CEVariantSeries *)series
{
    // protocol compliance only
}

#pragma mark -

- (void)testInit
{
    CEVariantTag *tag = [CEVariantTag tag];
    CEVariantSeries *series = [[[CEVariantSeries alloc] initWithIdentifier:@"flarn" values:@[ @"barf" ] delegate:self] autorelease];
    CEVariant *variant = [[[CEVariant alloc] initWithSeries:series tag:tag] autorelease];
    XCTAssertNotNil(variant);
    XCTAssertEqual(variant.series, series);
}

@end
