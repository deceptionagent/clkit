//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CLKConstraint.h"
#import "CLKConstraintTestCase.h"
#import "CLKOption.h"


@interface Test_CLKConstraint : CLKConstraintTestCase

@end


@implementation Test_CLKConstraint

- (void)testInit
{
    CLKOption *option = [CLKOption optionWithName:@"option" flag:@"o"];
    CLKConstraint *constraint = [[[CLKConstraint alloc] initWithOptions:@[ option ] groups:nil required:YES mutexed:YES] autorelease];
    [self verifyConstraint:constraint options:@[ option ] groups:nil required:YES mutexed:YES];
    
    XCTAssertThrows([[[CLKConstraint alloc] initWithOptions:nil groups:nil required:NO mutexed:NO] autorelease]);
    XCTAssertThrows([[[CLKConstraint alloc] initWithOptions:@[] groups:nil required:NO mutexed:NO] autorelease]);
    XCTAssertThrows([[[CLKConstraint alloc] initWithOptions:nil groups:@[] required:NO mutexed:NO] autorelease]);
    XCTAssertThrows([[[CLKConstraint alloc] initWithOptions:@[] groups:@[] required:NO mutexed:NO] autorelease]);
}

- (void)test_constraintForRequiredOption
{
    CLKOption *option = [CLKOption optionWithName:@"option" flag:@"o"];
    CLKConstraint *constraint = [CLKConstraint constraintForRequiredOption:option];
    [self verifyConstraint:constraint options:@[ option ] groups:nil required:YES mutexed:NO];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    XCTAssertThrows([CLKConstraint constraintForRequiredOption:nil]);
#pragma clang diagnostic pop
}

@end
