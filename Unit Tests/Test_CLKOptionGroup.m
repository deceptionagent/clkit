//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CLKArgumentManifestConstraint.h"
#import "CLKOption.h"
#import "CLKOptionGroup.h"
#import "CLKOptionGroup_Private.h"


@interface Test_CLKOptionGroup : XCTestCase

@end

@implementation Test_CLKOptionGroup

- (void)test_allOptions
{
    CLKOptionGroup *group = [CLKOptionGroup requiredGroupForOptionsNamed:@[ @"flarn", @"barf" ]];
    XCTAssertEqualObjects(group.allOptions, (@[ @"flarn", @"barf" ]));
    
    group = [CLKOptionGroup mutexedGroupForOptionsNamed:@[ @"flarn", @"barf" ]];
    XCTAssertEqualObjects(group.allOptions, (@[ @"flarn", @"barf" ]));
    
    group = [CLKOptionGroup groupForOptionsNamed:@[ @"flarn", @"barf" ] required:NO mutexed:NO];
    XCTAssertEqualObjects(group.allOptions, (@[ @"flarn", @"barf" ]));
    
    group = [CLKOptionGroup standaloneGroupForOptionNamed:@"flarn" allowing:@[ @"barf" ]];
    XCTAssertEqualObjects(group.allOptions, (@[ @"flarn", @"barf" ]));
}

- (void)testConstraints_inertGroup
{
    NSArray<CLKArgumentManifestConstraint *> *expectedConstraints = @[
        [CLKArgumentManifestConstraint inactiveConstraintForOptions:@[ @"barf", @"flarn" ]]
    ];
    
    CLKOptionGroup *group = [CLKOptionGroup groupForOptionsNamed:@[ @"barf", @"flarn" ] required:NO mutexed:NO];
    XCTAssertEqualObjects(group.constraints, expectedConstraints);
    
    group = [CLKOptionGroup groupForOptionsNamed:@[] required:NO mutexed:NO];
    XCTAssertEqualObjects(group.constraints, @[]);
}

- (void)testConstraints_requiredGroup
{
    NSArray<CLKArgumentManifestConstraint *> *expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintRequiringRepresentationForOptions:@[ @"barf", @"flarn" ]]
    ];
    
    CLKOptionGroup *group = [CLKOptionGroup requiredGroupForOptionsNamed:@[ @"barf", @"flarn" ]];
    XCTAssertEqualObjects(group.constraints, expectedConstraints);
    
    group = [CLKOptionGroup groupForOptionsNamed:@[ @"barf", @"flarn" ] required:YES mutexed:NO];
    XCTAssertEqualObjects(group.constraints, expectedConstraints);
}

- (void)testConstraints_mutexedGroup
{
    CLKOptionGroup *group = [CLKOptionGroup mutexedGroupForOptionsNamed:@[ @"barf", @"flarn", @"quone" ]];
    NSArray<CLKArgumentManifestConstraint *> *expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"barf", @"flarn", @"quone" ]]
    ];
    
    XCTAssertEqualObjects(group.constraints, expectedConstraints);
    
    group = [CLKOptionGroup groupForOptionsNamed:@[ @"barf", @"flarn" ] required:NO mutexed:YES];
    expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"barf", @"flarn" ]]
    ];
    
    XCTAssertEqualObjects(group.constraints, expectedConstraints);
    
    group = [CLKOptionGroup groupForOptionsNamed:@[ @"barf", @"flarn" ] required:YES mutexed:YES];
    expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintRequiringRepresentationForOptions:@[ @"barf", @"flarn" ]],
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"barf", @"flarn" ]]
    ];
    
    XCTAssertEqualObjects(group.constraints, expectedConstraints);
    
    group = [CLKOptionGroup mutexedGroupForOptionsNamed:@[]];
    XCTAssertEqualObjects(group.constraints, @[]);
}

- (void)testConstraints_standalone
{
    CLKOptionGroup *group = [CLKOptionGroup standaloneGroupForOptionNamed:@"flarn" allowing:@[]];
    NSArray *expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintForStandaloneOption:@"flarn" allowingOptions:@[]]
    ];
    
    XCTAssertEqualObjects(group.constraints, expectedConstraints);
    
    group = [CLKOptionGroup standaloneGroupForOptionNamed:@"flarn" allowing:@[ @"barf" ]];
    expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintForStandaloneOption:@"flarn" allowingOptions:@[ @"barf" ]]
    ];
    
    XCTAssertEqualObjects(group.constraints, expectedConstraints);
    
    group = [CLKOptionGroup standaloneGroupForOptionNamed:@"flarn" allowing:@[ @"barf", @"quone" ]];
    expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintForStandaloneOption:@"flarn" allowingOptions:@[ @"barf", @"quone" ]]
    ];
    
    XCTAssertEqualObjects(group.constraints, expectedConstraints);
}

@end
