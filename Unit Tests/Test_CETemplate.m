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
    CETemplateSeries *alpha = [[[CETemplateSeries alloc] initWithIdentifier:@"quone" values:@[ @"flarn", @"barf" ] elidable:NO variants:@[ north, south ]] autorelease];
    CETemplateSeries *bravo = [[[CETemplateSeries alloc] initWithIdentifier:@"xyzzy" values:@[ @"confound", @"delivery" ] elidable:NO variants:@[ east, west ]] autorelease];
    
    CETemplate *template = [[[CETemplate alloc] initWithSeries:@[ alpha, bravo ]] autorelease];
    XCTAssertNotNil(template);
    XCTAssertEqual(template.allSeries.count, 2UL);
    XCTAssertEqual(template.allSeries[0], alpha);
    XCTAssertEqual(template.allSeries[1], bravo);
    
    template = [CETemplate templateWithSeries:@[ alpha, bravo ]];
    XCTAssertNotNil(template);
    XCTAssertEqual(template.allSeries.count, 2UL);
    XCTAssertEqual(template.allSeries[0], alpha);
    XCTAssertEqual(template.allSeries[1], bravo);
}

@end
