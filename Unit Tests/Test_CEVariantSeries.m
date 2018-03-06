//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CEVariantSeries.h"


@interface Test_CEVariantSeries : XCTestCase <CEVariantSeriesDelegate>

@end


@implementation Test_CEVariantSeries
{
    BOOL _receivedDidAdvanceToInitialPosition;
}

#pragma mark <CEVariantSeriesDelegate>

- (void)variantSeriesDidAdvanceToInitialPosition:(CEVariantSeries *)series
{
    XCTAssertNotNil(series);
    XCTAssertNotNil(series.identifier);
    _receivedDidAdvanceToInitialPosition = YES;
}

#pragma mark -

- (void)testInit
{
    CEVariantSeries *series = [[[CEVariantSeries alloc] initWithIdentifier:@"barf" values:@[ @"flarn" ] delegate:self] autorelease];
    XCTAssertNotNil(series);
    XCTAssertEqualObjects(series.identifier, @"barf");
    XCTAssertEqualObjects(series.currentValue, @"flarn");
    
    series = [[[CEVariantSeries alloc] initWithIdentifier:@"quone" values:@[ @"flarn", @"barf" ] delegate:self] autorelease];
    XCTAssertNotNil(series);
    XCTAssertEqualObjects(series.identifier, @"quone");
    XCTAssertEqualObjects(series.currentValue, @"flarn");
    
    XCTAssertThrows([[[CEVariantSeries alloc] initWithIdentifier:@"flarn" values:@[] delegate:self] autorelease]);
    XCTAssertThrows([[[CEVariantSeries alloc] initWithIdentifier:@"" values:@[ @"barf" ] delegate:self] autorelease]);
}

- (void)test_variantSeriesDidAdvanceToInitialPosition
{
    CEVariantSeries *series = [[[CEVariantSeries alloc] initWithIdentifier:@"xyzzy" values:@[ @"flarn", @"barf", @"quone" ] delegate:self] autorelease];
    XCTAssertEqualObjects(series.currentValue, @"flarn");
    XCTAssertFalse(_receivedDidAdvanceToInitialPosition);
    for (int i = 0 ; i < 3 ; i++) {
        [series advance];
        XCTAssertEqualObjects(series.currentValue, @"barf");
        XCTAssertFalse(_receivedDidAdvanceToInitialPosition);
        [series advance];
        XCTAssertEqualObjects(series.currentValue, @"quone");
        XCTAssertFalse(_receivedDidAdvanceToInitialPosition);
        [series advance];
        XCTAssertEqualObjects(series.currentValue, @"flarn");
        XCTAssertTrue(_receivedDidAdvanceToInitialPosition);
        _receivedDidAdvanceToInitialPosition = NO;
    }
}

- (void)test_variantSeriesDidAdvanceToInitialPosition_singleValue
{
    CEVariantSeries *series = [[[CEVariantSeries alloc] initWithIdentifier:@"xyzzy" values:@[ @"flarn" ] delegate:self] autorelease];
    XCTAssertEqualObjects(series.currentValue, @"flarn");
    XCTAssertFalse(_receivedDidAdvanceToInitialPosition);
    for (int i = 0 ; i < 3 ; i++) {
        [series advance];
        XCTAssertEqualObjects(series.currentValue, @"flarn");
        XCTAssertTrue(_receivedDidAdvanceToInitialPosition);
        _receivedDidAdvanceToInitialPosition = NO;
    }
}

@end
