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
    CLKOptionGroup *group = [CLKOptionGroup mutexedGroupForOptionsNamed:@[ @"flarn", @"barf" ]];
    XCTAssertEqualObjects(group.allOptions, (@[ @"flarn", @"barf" ]));
    
    CLKOptionGroup *subgroupAlpha = [CLKOptionGroup groupForOptionsNamed:@[ @"quone", @"xyzzy" ]];
    CLKOptionGroup *subgroupBravo = [CLKOptionGroup groupForOptionsNamed:@[ @"syn", @"ack" ]];
    NSArray<CLKOptionGroup *> *subgroups = @[ subgroupAlpha, subgroupBravo ];
    
    group = [CLKOptionGroup mutexedGroupWithSubgroups:subgroups];
    XCTAssertEqualObjects(group.allOptions, (@[ @"quone", @"xyzzy", @"syn", @"ack" ]));
    
    group = [CLKOptionGroup mutexedGroupWithSubgroups:@[ subgroupAlpha ]];
    XCTAssertEqualObjects(group.allOptions, (@[ @"quone", @"xyzzy" ]));
    
    CLKOptionGroup *subgroupCharlie = [CLKOptionGroup groupForOptionsNamed:@[]];
    group = [CLKOptionGroup mutexedGroupWithSubgroups:@[ subgroupCharlie ]];
    XCTAssertEqualObjects(group.allOptions, @[]);
    
    group = [CLKOptionGroup mutexedGroupWithSubgroups:@[]];
    XCTAssertEqualObjects(group.allOptions, @[]);
}

- (void)testConstraints_boringGroup
{
    CLKOptionGroup *group = [CLKOptionGroup groupForOptionsNamed:@[ @"barf", @"flarn" ]];
    XCTAssertEqualObjects(group.constraints, @[]);
    
    group = [CLKOptionGroup groupForOptionsNamed:@[ @"barf", @"flarn" ] required:NO mutexed:NO];
    XCTAssertEqualObjects(group.constraints, @[]);
    
    group = [CLKOptionGroup groupForOptionsNamed:@[]];
    XCTAssertEqualObjects(group.constraints, @[]);
}

- (void)testConstraints_requiredGroup
{
    NSArray<CLKArgumentManifestConstraint *> *expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintRequiringRepresentativeForOptions:@[ @"barf", @"flarn" ]]
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
        [CLKArgumentManifestConstraint constraintRequiringRepresentativeForOptions:@[ @"barf", @"flarn" ]],
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"barf", @"flarn" ]]
    ];
    
    XCTAssertEqualObjects(group.constraints, expectedConstraints);
    
    group = [CLKOptionGroup mutexedGroupForOptionsNamed:@[]];
    XCTAssertEqualObjects(group.constraints, @[]);
}

- (void)testConstraints_mutexedGroup_subgroups_sanityChecks
{
    CLKOptionGroup *group = [CLKOptionGroup mutexedGroupWithSubgroups:@[]];
    XCTAssertEqualObjects(group.constraints, @[]);
    
    CLKOptionGroup *confound = [CLKOptionGroup groupForOptionsNamed:@[ @"syn", @"ack" ]];
    group = [CLKOptionGroup mutexedGroupWithSubgroups:@[ confound ]];
    XCTAssertEqualObjects(group.constraints, @[]);
}

- (void)testConstraints_mutexedGroup_subgroups_onlyBoringSubgroups
{
    CLKOptionGroup *confound = [CLKOptionGroup groupForOptionsNamed:@[ @"syn", @"ack" ]];
    CLKOptionGroup *delivery = [CLKOptionGroup groupForOptionsNamed:@[ @"quone", @"xyzzy", @"what" ]];
    CLKOptionGroup *thrud = [CLKOptionGroup groupForOptionsNamed:@[ @"thrud" ]];
    
    /* two boring subgroups */
    
    CLKOptionGroup *group = [CLKOptionGroup mutexedGroupWithSubgroups:@[ confound, delivery ]];
    NSArray *expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"syn", @"quone" ]],
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"syn", @"xyzzy" ]],
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"syn", @"what" ]],
        
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"ack", @"quone" ]],
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"ack", @"xyzzy" ]],
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"ack", @"what" ]]
    ];
    
    XCTAssertEqualObjects(group.constraints, expectedConstraints);
    
    /* three boring subgroups */
    
    group = [CLKOptionGroup mutexedGroupWithSubgroups:@[ confound, delivery, thrud ]];
    expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"syn", @"quone" ]],
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"syn", @"xyzzy" ]],
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"syn", @"what" ]],
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"syn", @"thrud" ]],
        
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"ack", @"quone" ]],
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"ack", @"xyzzy" ]],
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"ack", @"what" ]],
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"ack", @"thrud" ]],
        
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"quone", @"thrud" ]],
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"xyzzy", @"thrud" ]],
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"what", @"thrud" ]]
    ];
    
    XCTAssertEqualObjects(group.constraints, expectedConstraints);
}

- (void)testConstraints_mutexedGroup_subgroups_withMutexedSubgroup
{
    CLKOptionGroup *mutexedSubgroup = [CLKOptionGroup mutexedGroupForOptionsNamed:@[ @"fatum", @"iustum", @"stultorum" ]];
    CLKOptionGroup *boringGroup = [CLKOptionGroup groupForOptionsNamed:@[ @"syn", @"ack" ]];
    
    CLKOptionGroup *group = [CLKOptionGroup mutexedGroupWithSubgroups:@[ mutexedSubgroup, boringGroup ]];
    NSArray *expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"fatum", @"syn" ]],
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"fatum", @"ack" ]],
        
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"iustum", @"syn" ]],
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"iustum", @"ack" ]],
        
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"stultorum", @"syn" ]],
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"stultorum", @"ack" ]],
        
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"fatum", @"iustum", @"stultorum" ]],
    ];
    
    XCTAssertEqualObjects(group.constraints, expectedConstraints);
}

@end
