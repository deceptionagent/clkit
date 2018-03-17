//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CETemplate.h"
#import "CETemplateSeries.h"
#import "CEVariantTag.h"


@interface Test_CETemplate : XCTestCase

@end


@implementation Test_CETemplate

- (void)testInit
{
    CEVariantTag *north = [CEVariantTag tag];
    CEVariantTag *south = [CEVariantTag tag];
    CEVariantTag *east = [CEVariantTag tag];
    CEVariantTag *west = [CEVariantTag tag];
    CETemplateSeries *alpha = [[[CETemplateSeries alloc] initWithIdentifier:@"quone" values:@[ @"flarn", @"barf" ] variants:@[ north, south ]] autorelease];
    CETemplateSeries *bravo = [[[CETemplateSeries alloc] initWithIdentifier:@"xyzzy" values:@[ @"confound", @"delivery" ] variants:@[ east, west ]] autorelease];
    
    #define VERIFY_TEMPLATE(__template__) \
        XCTAssertNotNil(__template__); \
        XCTAssertEqual(__template__.allSeries.count, 2UL); \
        XCTAssertEqualObjects(__template__.allSeries.firstObject.identifier, @"quone"); \
        XCTAssertEqualObjects(__template__.allSeries.firstObject.values, (@[ @"flarn", @"barf" ])); \
        XCTAssertEqualObjects(__template__.allSeries.firstObject.variants, (@[ north, south ])); \
        XCTAssertEqualObjects(__template__.allSeries.lastObject.identifier, @"xyzzy"); \
        XCTAssertEqualObjects(__template__.allSeries.lastObject.values, (@[ @"confound", @"delivery" ])); \
        XCTAssertEqualObjects(__template__.allSeries.lastObject.variants, (@[ east, west ]));
    
    CETemplate *template = [[[CETemplate alloc] initWithSeries:@[ alpha, bravo ]] autorelease];
    VERIFY_TEMPLATE(template);
    
    template = [CETemplate templateWithSeries:@[ alpha, bravo ]];
    VERIFY_TEMPLATE(template);
}

@end
