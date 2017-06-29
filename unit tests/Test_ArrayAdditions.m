//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "NSArray+OptArgAdditions.h"
#import "NSMutableArray+OptArgAdditions.h"


@interface Test_NSArray_OptArgAdditions : XCTestCase

@end


@implementation Test_NSArray_OptArgAdditions

- (void)test_arrayWithArgv_argc
{
    const char *argvAlpha[] = { "alpha" };
    NSArray *alpha = [NSArray arrayWithArgv:argvAlpha argc:1];
    XCTAssertEqualObjects(alpha, @[ @"alpha" ]);
    
    const char *argvBravo[] = { "alpha", "bravo" };
    NSArray *bravo = [NSArray arrayWithArgv:argvBravo argc:2];
    XCTAssertEqualObjects(bravo, (@[ @"alpha", @"bravo" ]));
    
    const char *argvCharlie[] = {};
    NSArray *charlie = [NSArray arrayWithArgv:argvCharlie argc:0];
    XCTAssertNotNil(charlie);
    XCTAssertEqual(charlie.count, 0);
}

@end


#pragma mark -


@interface Test_NSMutableArray_OptArgAdditions : XCTestCase

@end


@implementation Test_NSMutableArray_OptArgAdditions

- (void)test_popLastObject
{
    NSMutableArray *alpha = [[@[ @"alpha" ] mutableCopy] autorelease];
    XCTAssertEqualObjects([alpha popFirstObject], @"alpha");
    XCTAssertEqual(alpha.count, 0);
    
    NSMutableArray *bravo = [[@[ @"alpha", @"bravo" ] mutableCopy] autorelease];
    XCTAssertEqualObjects([bravo popFirstObject], @"alpha");
    XCTAssertEqualObjects(bravo, @[ @"bravo" ]);
    
    NSMutableArray *charlie = [NSMutableArray array];
    XCTAssertNil([charlie popFirstObject]);
    XCTAssertEqual(charlie.count, 0);
}

@end
