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
    CEVariantTag *east = [CEVariantTag tag];
    CEVariantTag *west = [CEVariantTag tag];
    CETemplateSeries *series = [[[CETemplateSeries alloc] initWithIdentifier:@"quone" values:@[ @"flarn", @"barf" ] variantTags:@[ east, west ]] autorelease];
    XCTAssertNotNil(series);
    XCTAssertEqualObjects(series.identifier, @"quone");
    XCTAssertEqualObjects(series.values, (@[ @"flarn", @"barf" ]));
    XCTAssertEqualObjects(series.variantTags, (@[ east, west]));
    
    series = [CETemplateSeries seriesWithIdentifier:@"quone" values:@[ @"flarn", @"barf" ] variantTags:@[ east, west ]];
    XCTAssertNotNil(series);
    XCTAssertEqualObjects(series.identifier, @"quone");
    XCTAssertEqualObjects(series.values, (@[ @"flarn", @"barf" ]));
    XCTAssertEqualObjects(series.variantTags, (@[ east, west]));
}

@end
