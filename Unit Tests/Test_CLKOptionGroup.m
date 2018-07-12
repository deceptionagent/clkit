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

- (void)verifyGroup:(CLKOptionGroup *)group options:(NSArray<NSString *> *)options subgroups:(NSArray<CLKOptionGroup *> *)subgroups required:(BOOL)required mutexed:(BOOL)mutexed
{
    XCTAssertNotNil(group);
    XCTAssertEqualObjects(group.options, options);
    XCTAssertEqualObjects(group.subgroups, subgroups);
    XCTAssertEqual(group.required, required);
    XCTAssertEqual(group.mutexed, mutexed);
}

- (void)testInit
{
    NSArray<NSString *> *options = @[ @"flarn", @"barf" ];
    
    CLKOptionGroup *group = [CLKOptionGroup groupForOptionsNamed:options];
    [self verifyGroup:group options:options subgroups:nil required:NO mutexed:NO];
    
    group = [CLKOptionGroup groupForOptionsNamed:options required:NO];
    [self verifyGroup:group options:options subgroups:nil required:NO mutexed:NO];

    group = [CLKOptionGroup groupForOptionsNamed:options required:YES];
    [self verifyGroup:group options:options subgroups:nil required:YES mutexed:NO];

    group = [CLKOptionGroup mutexedGroupForOptionsNamed:options];
    [self verifyGroup:group options:options subgroups:nil required:NO mutexed:YES];
    
    group = [CLKOptionGroup mutexedGroupForOptionsNamed:options required:NO];
    [self verifyGroup:group options:options subgroups:nil required:NO mutexed:YES];

    group = [CLKOptionGroup mutexedGroupForOptionsNamed:options required:YES];
    [self verifyGroup:group options:options subgroups:nil required:YES mutexed:YES];
    
    CLKOptionGroup *subgroupAlpha = [CLKOptionGroup groupForOptionsNamed:@[ @"quone", @"xyzzy" ] required:NO];
    CLKOptionGroup *subgroupBravo = [CLKOptionGroup groupForOptionsNamed:@[ @"syn", @"ack" ] required:NO];
    NSArray<CLKOptionGroup *> *subgroups = @[ subgroupAlpha, subgroupBravo ];
    
    group = [CLKOptionGroup mutexedGroupWithSubgroups:subgroups];
    [self verifyGroup:group options:nil subgroups:subgroups required:NO mutexed:YES];
    
    group = [CLKOptionGroup mutexedGroupWithSubgroups:subgroups required:YES];
    [self verifyGroup:group options:nil subgroups:subgroups required:YES mutexed:YES];
}

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
    
    group = [CLKOptionGroup groupForOptionsNamed:@[ @"barf", @"flarn" ] required:YES];
    NSArray<CLKArgumentManifestConstraint *> *expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintRequiringRepresentativeForOptions:@[ @"barf", @"flarn" ]]
    ];
    
    XCTAssertEqualObjects(group.constraints, expectedConstraints);
    
    group = [CLKOptionGroup groupForOptionsNamed:@[]];
    XCTAssertEqualObjects(group.constraints, @[]);
}

- (void)testConstraints_mutexedGroup_primaryOptions
{
    CLKOptionGroup *group = [CLKOptionGroup mutexedGroupForOptionsNamed:@[ @"barf", @"flarn", @"quone" ]];
    NSArray<CLKArgumentManifestConstraint *> *expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"barf", @"flarn", @"quone" ]]
    ];
    
    XCTAssertEqualObjects(group.constraints, expectedConstraints);
    
    group = [CLKOptionGroup mutexedGroupForOptionsNamed:@[ @"barf", @"flarn" ] required:YES];
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
    
    /* two boring subgroups: required variant */
    
    group = [CLKOptionGroup mutexedGroupWithSubgroups:@[ confound, delivery ] required:YES];
    CLKArgumentManifestConstraint *requiredConstraint = [CLKArgumentManifestConstraint constraintRequiringRepresentativeForOptions:@[
        @"syn", @"ack", @"quone", @"xyzzy", @"what"
    ]];
    
    expectedConstraints = [@[ requiredConstraint ] arrayByAddingObjectsFromArray:expectedConstraints];
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
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"fatum", @"iustum", @"stultorum" ]],
        
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"fatum", @"syn" ]],
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"fatum", @"ack" ]],
        
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"iustum", @"syn" ]],
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"iustum", @"ack" ]],
        
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"stultorum", @"syn" ]],
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"stultorum", @"ack" ]],
    ];
    
    XCTAssertEqualObjects(group.constraints, expectedConstraints);
    
    /* required variant */
    
    group = [CLKOptionGroup mutexedGroupWithSubgroups:@[ mutexedSubgroup, boringGroup ] required:YES];
    CLKArgumentManifestConstraint *requiredConstraint = [CLKArgumentManifestConstraint constraintRequiringRepresentativeForOptions:@[
        @"fatum", @"iustum", @"stultorum", @"syn", @"ack"
    ]];
    
    expectedConstraints = [@[ requiredConstraint ] arrayByAddingObjectsFromArray:expectedConstraints];
    XCTAssertEqualObjects(group.constraints, expectedConstraints);
}

@end
