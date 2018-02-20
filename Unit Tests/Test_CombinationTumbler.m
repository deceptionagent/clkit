//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CombinationTumbler.h"


@interface Test_CombinationTumbler : XCTestCase <CombinationTumblerDelegate>

@end


@implementation Test_CombinationTumbler
{
    BOOL _turnedOver;
}

#pragma mark <CombinationTumblerDelegate>

- (void)tumblerDidTurnOver:(CombinationTumbler *)tumbler
{
    XCTAssertNotNil(tumbler);
    XCTAssertNotNil(tumbler.identifier);
    _turnedOver = YES;
}

#pragma mark -

- (void)testInit
{
    CombinationTumbler *tumbler = [[[CombinationTumbler alloc] initWithIdentifier:@"barf" values:@[ @"flarn" ] delegate:self] autorelease];
    XCTAssertNotNil(tumbler);
    XCTAssertEqualObjects(tumbler.identifier, @"barf");
    XCTAssertEqualObjects(tumbler.currentValue, @"flarn");
    
    tumbler = [[[CombinationTumbler alloc] initWithIdentifier:@"quone" values:@[ @"flarn", @"barf" ] delegate:self] autorelease];
    XCTAssertNotNil(tumbler);
    XCTAssertEqualObjects(tumbler.identifier, @"quone");
    XCTAssertEqualObjects(tumbler.currentValue, @"flarn");
    
    XCTAssertThrows([[[CombinationTumbler alloc] initWithIdentifier:@"flarn" values:@[] delegate:self] autorelease]);
    XCTAssertThrows([[[CombinationTumbler alloc] initWithIdentifier:@"" values:@[ @"barf" ] delegate:self] autorelease]);
}

- (void)testTurnOver
{
    CombinationTumbler *tumbler = [[[CombinationTumbler alloc] initWithIdentifier:@"xyzzy" values:@[ @"flarn", @"barf", @"quone" ] delegate:self] autorelease];
    XCTAssertEqualObjects(tumbler.currentValue, @"flarn");
    XCTAssertFalse(_turnedOver);
    for (int i = 0 ; i < 3 ; i++) {
        [tumbler turn];
        XCTAssertEqualObjects(tumbler.currentValue, @"barf");
        XCTAssertFalse(_turnedOver);
        [tumbler turn];
        XCTAssertEqualObjects(tumbler.currentValue, @"quone");
        XCTAssertFalse(_turnedOver);
        [tumbler turn];
        XCTAssertEqualObjects(tumbler.currentValue, @"flarn");
        XCTAssertTrue(_turnedOver);
        _turnedOver = NO;
    }
}

- (void)testTurnOver_singleValue
{
    CombinationTumbler *tumbler = [[[CombinationTumbler alloc] initWithIdentifier:@"xyzzy" values:@[ @"flarn" ] delegate:self] autorelease];
    XCTAssertEqualObjects(tumbler.currentValue, @"flarn");
    XCTAssertFalse(_turnedOver);
    for (int i = 0 ; i < 3 ; i++) {
        [tumbler turn];
        XCTAssertEqualObjects(tumbler.currentValue, @"flarn");
        XCTAssertTrue(_turnedOver);
        _turnedOver = NO;
    }
}

@end
