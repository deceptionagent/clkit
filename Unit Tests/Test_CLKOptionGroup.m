//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CLKArgumentManifestConstraint.h"
#import "CLKOption.h"
#import "CLKOptionGroup_Private.h"

@interface Test_CLKOptionGroup : XCTestCase

@end

@implementation Test_CLKOptionGroup

#warning is there value in these cases?

- (void)testRequired
{
    CLKOptionGroup *group = [CLKOptionGroup requiredGroupForOptionsNamed:@[ @"flarn", @"barf" ]];
    NSArray<CLKArgumentManifestConstraint *> *expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintRequiringRepresentationForOptions:@[ @"flarn", @"barf" ]]
    ];
    
    XCTAssertEqualObjects(group.constraints, expectedConstraints);
    XCTAssertEqualObjects(group.allOptions, ([NSSet setWithObjects:@"flarn", @"barf", nil]));
    
    XCTAssertThrows([CLKOptionGroup requiredGroupForOptionsNamed:@[]]);
}

- (void)testMutexed
{
    CLKOptionGroup *group = [CLKOptionGroup mutexedGroupForOptionsNamed:@[ @"flarn", @"barf", @"quone" ]];
    NSArray<CLKArgumentManifestConstraint *> *expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"flarn", @"barf", @"quone" ]]
    ];
    
    XCTAssertEqualObjects(group.constraints, expectedConstraints);
    XCTAssertEqualObjects(group.allOptions, ([NSSet setWithObjects:@"flarn", @"barf", @"quone", nil]));
    
    XCTAssertThrows([CLKOptionGroup mutexedGroupForOptionsNamed:@[]]);
}

- (void)testStandalone
{
    CLKOptionGroup *group = [CLKOptionGroup standaloneGroupForOptionNamed:@"flarn" allowing:@[]];
    NSArray *expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintForStandaloneOption:@"flarn" allowingOptions:@[]]
    ];
    
    XCTAssertEqualObjects(group.constraints, expectedConstraints);
    XCTAssertEqualObjects(group.allOptions, [NSSet setWithObject:@"flarn"]);
    
    group = [CLKOptionGroup standaloneGroupForOptionNamed:@"flarn" allowing:@[ @"barf" ]];
    expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintForStandaloneOption:@"flarn" allowingOptions:@[ @"barf" ]]
    ];
    
    XCTAssertEqualObjects(group.constraints, expectedConstraints);
    XCTAssertEqualObjects(group.allOptions, ([NSSet setWithObjects:@"flarn", @"barf", nil]));
    
    group = [CLKOptionGroup standaloneGroupForOptionNamed:@"flarn" allowing:@[ @"barf", @"quone" ]];
    expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintForStandaloneOption:@"flarn" allowingOptions:@[ @"barf", @"quone" ]]
    ];
    
    XCTAssertEqualObjects(group.constraints, expectedConstraints);
    XCTAssertEqualObjects(group.allOptions, ([NSSet setWithObjects:@"flarn", @"barf", @"quone", nil]));
}

- (void)testDependency
{
    CLKOptionGroup *group = [CLKOptionGroup groupForOptionNamed:@"flarn" requiringDependency:@"barf"];
    NSArray *expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"barf" causalOption:@"flarn"]
    ];
    
    XCTAssertEqualObjects(group.constraints, expectedConstraints);
    XCTAssertEqualObjects(group.allOptions, ([NSSet setWithObjects:@"flarn", @"barf", nil]));
}

@end
