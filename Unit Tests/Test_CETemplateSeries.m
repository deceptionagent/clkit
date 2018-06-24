//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CETemplateSeries.h"
#import "CEVariantTag.h"


@interface Test_CETemplateSeries : XCTestCase

@end


@implementation Test_CETemplateSeries

- (void)testInit
{
    CETemplateSeries *series = [[[CETemplateSeries alloc] initWithIdentifier:@"quone" values:@[ @"flarn", @"barf" ] elidable:YES variants:@[ @"east", @"west" ]] autorelease];
    XCTAssertNotNil(series);
    XCTAssertEqualObjects(series.identifier, @"quone");
    XCTAssertEqualObjects(series.values, (@[ @"flarn", @"barf" ]));
    XCTAssertTrue(series.elidable);
    XCTAssertEqualObjects(series.variants, (@[ @"east", @"west" ]));
    
    series = [CETemplateSeries seriesWithIdentifier:@"quone" values:@[ @"flarn", @"barf" ] variants:@[ @"east", @"west" ]];
    XCTAssertNotNil(series);
    XCTAssertEqualObjects(series.identifier, @"quone");
    XCTAssertEqualObjects(series.values, (@[ @"flarn", @"barf" ]));
    XCTAssertFalse(series.elidable);
    XCTAssertEqualObjects(series.variants, (@[ @"east", @"west" ]));
    
    series = [CETemplateSeries seriesWithIdentifier:@"quone" values:@[ @"flarn", @"barf" ] variant:@"east"];
    XCTAssertNotNil(series);
    XCTAssertEqualObjects(series.identifier, @"quone");
    XCTAssertEqualObjects(series.values, (@[ @"flarn", @"barf" ]));
    XCTAssertFalse(series.elidable);
    XCTAssertEqualObjects(series.variants, @[ @"east" ]);
    
    series = [CETemplateSeries elidableSeriesWithIdentifier:@"quone" values:@[ @"flarn", @"barf" ] variants:@[ @"east", @"west" ]];
    XCTAssertNotNil(series);
    XCTAssertEqualObjects(series.identifier, @"quone");
    XCTAssertEqualObjects(series.values, (@[ @"flarn", @"barf" ]));
    XCTAssertTrue(series.elidable);
    XCTAssertEqualObjects(series.variants, (@[ @"east", @"west" ]));
    
    series = [CETemplateSeries elidableSeriesWithIdentifier:@"quone" values:@[ @"flarn", @"barf" ] variant:@"east"];
    XCTAssertNotNil(series);
    XCTAssertEqualObjects(series.identifier, @"quone");
    XCTAssertEqualObjects(series.values, (@[ @"flarn", @"barf" ]));
    XCTAssertTrue(series.elidable);
    XCTAssertEqualObjects(series.variants, @[ @"east" ]);
}

@end
