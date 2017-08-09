//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "NSArray+CLKAdditions.h"
#import "NSError+CLKAdditions.h"
#import "NSMutableArray+CLKAdditions.h"


@interface Test_NSArray_CLKAdditions : XCTestCase

@end


@implementation Test_NSArray_CLKAdditions

- (void)test_clk_arrayWithArgv_argc
{
    const char *argvAlpha[] = { "alpha" };
    NSArray *alpha = [NSArray clk_arrayWithArgv:argvAlpha argc:1];
    XCTAssertEqualObjects(alpha, @[ @"alpha" ]);
    
    const char *argvBravo[] = { "alpha", "bravo" };
    NSArray *bravo = [NSArray clk_arrayWithArgv:argvBravo argc:2];
    XCTAssertEqualObjects(bravo, (@[ @"alpha", @"bravo" ]));
    
    const char *argvCharlie[] = {};
    NSArray *charlie = [NSArray clk_arrayWithArgv:argvCharlie argc:0];
    XCTAssertNotNil(charlie);
    XCTAssertEqual(charlie.count, 0);
}

@end


#pragma mark -


@interface Test_NSError_CLKAdditions : XCTestCase

@end


@implementation Test_NSError_CLKAdditions

- (void)test_clk_POSIXErrorWithCode_localizedDescription
{
    NSError *error = [NSError clk_POSIXErrorWithCode:ENOENT localizedDescription:@"404 flarn not found"];
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, ENOENT);
    XCTAssertEqualObjects(error.localizedDescription, @"404 flarn not found");
    
    error = [NSError clk_POSIXErrorWithCode:ENOENT localizedDescription:@"404 %@ not found", @"flarn"];
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, ENOENT);
    XCTAssertEqualObjects(error.localizedDescription, @"404 flarn not found");
}

@end


#pragma mark -


@interface Test_NSMutableArray_CLKAdditions : XCTestCase

@end


@implementation Test_NSMutableArray_CLKAdditions

- (void)test_clk_popLastObject
{
    NSMutableArray *alpha = [[@[ @"alpha" ] mutableCopy] autorelease];
    XCTAssertEqualObjects([alpha clk_popFirstObject], @"alpha");
    XCTAssertEqual(alpha.count, 0);
    
    NSMutableArray *bravo = [[@[ @"alpha", @"bravo" ] mutableCopy] autorelease];
    XCTAssertEqualObjects([bravo clk_popFirstObject], @"alpha");
    XCTAssertEqualObjects(bravo, @[ @"bravo" ]);
    
    NSMutableArray *charlie = [NSMutableArray array];
    XCTAssertNil([charlie clk_popFirstObject]);
    XCTAssertEqual(charlie.count, 0);
}

@end