//
//  Copyright (c) 2023 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CLKOptionGroup.h"

@interface Test_CLKOptionGroup : XCTestCase

@end

@implementation Test_CLKOptionGroup

- (void)testInvalidGroups
{
    XCTAssertThrows([CLKOptionGroup groupRequiringAnyOfOptionsNamed:@[]]);
    XCTAssertThrows([CLKOptionGroup groupForOptionNamed:@"acme" requiringAnyOfDependents:@[]]);
    XCTAssertThrows([CLKOptionGroup mutexedGroupForOptionsNamed:@[ @"acme "]]);
    
    XCTAssertThrows([CLKOptionGroup groupForOptionNamed:@"acme" requiringAnyOfDependents:(@[ @"station", @"acme" ])]);
    XCTAssertThrows([CLKOptionGroup standaloneGroupForOptionNamed:@"acme" allowing:(@[ @"station", @"acme" ])]);
    XCTAssertThrows([CLKOptionGroup groupForOptionNamed:@"acme" requiringDependency:@"acme"]);
}

@end
