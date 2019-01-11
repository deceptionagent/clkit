//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CombinationEngine.h"
#import "CLKCommandResult.h"
#import "NSError+CLKAdditions.h"


@interface Test_CLKCommandResult : XCTestCase

@end

@implementation Test_CLKCommandResult

- (void)testInit
{
    NSError *error = [NSError clk_POSIXErrorWithCode:ENOENT description:@"ENOENT"];
    NSDictionary *userInfo = @{ @"flarn" : @"barf" };
    CETemplate *template = [CETemplate templateWithSeries:@[
        [CETemplateSeries elidableSeriesWithIdentifier:@"errors" values:@[ @[], @[ error ] ] variant:@""],
        [CETemplateSeries elidableSeriesWithIdentifier:@"userInfo" values:@[ @{}, userInfo ] variant:@""]
    ]];
    
    CEGenerator *generator = [CEGenerator generatorWithTemplate:template];
    [generator enumerateCombinations:^(CECombination *combination) {
        NSArray<NSError *> *errors = combination[@"errors"];
        NSDictionary *userInfo_ = combination[@"userInfo"];
        
        CLKCommandResult *result = [[CLKCommandResult alloc] initWithExitStatus:7 errors:errors userInfo:userInfo_];
        XCTAssertNotNil(result);
        XCTAssertEqual(result.exitStatus, 7);
        XCTAssertEqualObjects(result.errors, errors);
        XCTAssertEqualObjects(result.userInfo, userInfo_);
        
        result = [CLKCommandResult resultWithExitStatus:7 errors:errors];
        XCTAssertNotNil(result);
        XCTAssertEqual(result.exitStatus, 7);
        XCTAssertEqualObjects(result.errors, errors);
        XCTAssertNil(result.userInfo);
        
        result = [CLKCommandResult resultWithExitStatus:7 userInfo:userInfo_];
        XCTAssertNotNil(result);
        XCTAssertEqual(result.exitStatus, 7);
        XCTAssertNil(result.errors);
        XCTAssertEqualObjects(result.userInfo, userInfo_);
    }];
    
    CLKCommandResult *result = [CLKCommandResult resultWithExitStatus:7];
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
    NSString *expectedErrorDescription = [NSString stringWithFormat:@"aye mak sicur (%@: %d)", NSPOSIXErrorDomain, ENOENT];
    XCTAssertEqualObjects(result.errorDescription, expectedErrorDescription);
    
    result = [[CLKCommandResult alloc] initWithExitStatus:7 errors:@[ errorAlpha, errorBravo ] userInfo:nil];
    NSString *fmt = @"aye mak sicur (%@: %d)\nne cede malis (%@: %ld)";
    expectedErrorDescription = [NSString stringWithFormat:fmt, NSPOSIXErrorDomain, ENOENT, CLKErrorDomain, CLKErrorRequiredOptionNotProvided];
    XCTAssertEqualObjects(result.errorDescription, expectedErrorDescription);
}

@end
