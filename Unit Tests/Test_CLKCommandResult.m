//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CLKCommandResult.h"
#import "NSError+CLKAdditions.h"

@interface Test_CLKCommandResult : XCTestCase

@end

@implementation Test_CLKCommandResult

- (void)testInit
{
    NSArray *errors = @[ [NSError clk_POSIXErrorWithCode:ENOENT description:@"ENOENT"] ];
    NSDictionary *userInfo = @{ @"flarn" : @"barf" };
    
    CLKCommandResult *result = [[CLKCommandResult alloc] initWithExitStatus:7 errors:nil userInfo:nil];
    XCTAssertNotNil(result);
    XCTAssertEqual(result.exitStatus, 7);
    XCTAssertNil(result.errors);
    XCTAssertNil(result.userInfo);
    
    result = [[CLKCommandResult alloc] initWithExitStatus:7 errors:@[] userInfo:@{}];
    XCTAssertNotNil(result);
    XCTAssertEqual(result.exitStatus, 7);
    XCTAssertEqualObjects(result.errors, @[]);
    XCTAssertEqualObjects(result.userInfo, @{});

    result = [[CLKCommandResult alloc] initWithExitStatus:7 errors:errors userInfo:nil];
    XCTAssertNotNil(result);
    XCTAssertEqual(result.exitStatus, 7);
    XCTAssertEqualObjects(result.errors, errors);
    XCTAssertNil(result.userInfo);
    
    result = [[CLKCommandResult alloc] initWithExitStatus:7 errors:nil userInfo:userInfo];
    XCTAssertNotNil(result);
    XCTAssertEqual(result.exitStatus, 7);
    XCTAssertNil(result.errors);
    XCTAssertEqualObjects(result.userInfo, userInfo);
    
    result = [CLKCommandResult resultWithExitStatus:7 errors:errors];
    XCTAssertNotNil(result);
    XCTAssertEqual(result.exitStatus, 7);
    XCTAssertEqualObjects(result.errors, errors);
    XCTAssertNil(result.userInfo);
    
    result = [CLKCommandResult resultWithExitStatus:7 userInfo:userInfo];
    XCTAssertNotNil(result);
    XCTAssertEqual(result.exitStatus, 7);
    XCTAssertNil(result.errors);
    XCTAssertEqualObjects(result.userInfo, userInfo);
    
    result = [CLKCommandResult resultWithExitStatus:7];
    XCTAssertNotNil(result);
    XCTAssertEqual(result.exitStatus, 7);
    XCTAssertNil(result.errors);
    XCTAssertNil(result.userInfo);
}

- (void)test_errorDescription
{
    CLKCommandResult *result = [[CLKCommandResult alloc] initWithExitStatus:7 errors:nil userInfo:nil];
    XCTAssertNil(result.errorDescription);
    
    result = [[CLKCommandResult alloc] initWithExitStatus:7 errors:@[] userInfo:nil];
    XCTAssertNil(result.errorDescription);
    
    NSError *errorAlpha = [NSError clk_POSIXErrorWithCode:ENOENT description:@"aye mak sicur"];
    NSError *errorBravo = [NSError clk_CLKErrorWithCode:CLKErrorRequiredOptionNotProvided description:@"ne cede malis"];
    
    result = [[CLKCommandResult alloc] initWithExitStatus:7 errors:@[ errorAlpha ] userInfo:nil];
    XCTAssertEqualObjects(result.errorDescription, @"aye mak sicur");
    
    result = [[CLKCommandResult alloc] initWithExitStatus:7 errors:@[ errorAlpha, errorBravo ] userInfo:nil];
    XCTAssertEqualObjects(result.errorDescription, @"aye mak sicur\nne cede malis");
}

@end
