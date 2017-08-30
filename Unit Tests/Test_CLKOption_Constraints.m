//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CLKConstraint.h"
#import "CLKConstraintTestCase.h"
#import "CLKOption.h"
#import "CLKOption_Private.h"


@interface Test_CLKOption_Constraints : CLKConstraintTestCase

@end


@implementation Test_CLKOption_Constraints

- (void)testDefaultOptionConstraints
{
    CLKOption *payloadOption = [CLKOption optionWithName:@"payload" flag:@"p"];
    XCTAssertEqualObjects(payloadOption.constraints, @[]);
    
    CLKOption *freeOption = [CLKOption optionWithName:@"free" flag:@"f"];
    XCTAssertEqualObjects(freeOption.constraints, @[]);
}

- (void)testRequiredOptionConstraint
{
    CLKOption *option = [CLKOption optionWithName:@"flarn" flag:@"f" required:YES];
    NSArray *constraints = option.constraints;
    XCTAssertEqual(constraints.count, 1);
    [self verifyConstraint:constraints.firstObject options:@[ option ] groups:nil required:YES mutexed:NO];
}

@end
