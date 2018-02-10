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
    
    group = [CLKOptionGroup mutexedGroupForOptionsNamed:options subgroups:nil required:NO];
    [self verifyGroup:group options:options subgroups:nil required:NO mutexed:YES];
    
    CLKOptionGroup *subgroupAlpha = [CLKOptionGroup groupForOptionsNamed:@[ @"quone", @"xyzzy" ] required:NO];
    CLKOptionGroup *subgroupBravo = [CLKOptionGroup groupForOptionsNamed:@[ @"syn", @"ack" ] required:NO];
    NSArray<CLKOptionGroup *> *subgroups = @[ subgroupAlpha, subgroupBravo ];
    
    group = [CLKOptionGroup mutexedGroupForOptionsNamed:options subgroups:subgroups required:YES];
    [self verifyGroup:group options:options subgroups:subgroups required:YES mutexed:YES];
    
    group = [CLKOptionGroup mutexedGroupForOptionsNamed:nil subgroups:subgroups required:YES];
    [self verifyGroup:group options:nil subgroups:subgroups required:YES mutexed:YES];
}

- (void)test_allOptions
{
    CLKOptionGroup *subgroupAlpha = [CLKOptionGroup groupForOptionsNamed:@[ @"quone", @"xyzzy" ]];
    CLKOptionGroup *subgroupBravo = [CLKOptionGroup groupForOptionsNamed:@[ @"syn", @"ack" ]];
    NSArray<CLKOptionGroup *> *subgroups = @[ subgroupAlpha, subgroupBravo ];
    CLKOptionGroup *group = [CLKOptionGroup mutexedGroupForOptionsNamed:@[ @"flarn", @"barf" ] subgroups:subgroups required:NO];
    XCTAssertEqualObjects(group.allOptions, (@[ @"flarn", @"barf", @"quone", @"xyzzy", @"syn", @"ack", ]));
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
}

- (void)testConstraints_mutexedGroup
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
}

- (void)testConstraints_mutexedGroup_subgroups
{
    CLKOptionGroup *confound = [CLKOptionGroup groupForOptionsNamed:@[ @"syn", @"ack" ]];
    CLKOptionGroup *delivery = [CLKOptionGroup groupForOptionsNamed:@[ @"quone", @"xyzzy" ]];
    
    CLKOptionGroup *group = [CLKOptionGroup mutexedGroupForOptionsNamed:@[ @"barf", @"flarn" ] subgroups:@[ confound ] required:NO];
    NSArray<CLKArgumentManifestConstraint *> *expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"barf", @"flarn" ]],
        
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"barf", @"syn" ]],
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"barf", @"ack" ]],
        
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"flarn", @"syn" ]],
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"flarn", @"ack" ]],
    ];
    
    XCTAssertEqualObjects(group.constraints, expectedConstraints);
    
    // above constraints + rep-req constraint
    group = [CLKOptionGroup mutexedGroupForOptionsNamed:@[ @"barf", @"flarn" ] subgroups:@[ confound ] required:YES];
    CLKArgumentManifestConstraint *requiredConstraint = [CLKArgumentManifestConstraint constraintRequiringRepresentativeForOptions:@[
        @"barf", @"flarn", @"syn", @"ack"
    ]];
    
    expectedConstraints = [@[ requiredConstraint ] arrayByAddingObjectsFromArray:expectedConstraints];
    XCTAssertEqualObjects(group.constraints, expectedConstraints);
    
    group = [CLKOptionGroup mutexedGroupForOptionsNamed:@[ @"barf", @"flarn" ] subgroups:@[ confound, delivery ] required:NO];
    expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"barf", @"flarn" ]],
        
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"barf", @"syn" ]],
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"barf", @"ack" ]],
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"barf", @"quone" ]],
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"barf", @"xyzzy" ]],
        
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"flarn", @"syn" ]],
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"flarn", @"ack" ]],
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"flarn", @"quone" ]],
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"flarn", @"xyzzy" ]],

        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"syn", @"quone" ]],
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"syn", @"xyzzy" ]],
        
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"ack", @"quone" ]],
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"ack", @"xyzzy" ]],
    ];
    
    XCTAssertEqualObjects(group.constraints, expectedConstraints);
    
    // above constraints + rep-req constraint
    group = [CLKOptionGroup mutexedGroupForOptionsNamed:@[ @"barf", @"flarn" ] subgroups:@[ confound, delivery ] required:YES];
    requiredConstraint = [CLKArgumentManifestConstraint constraintRequiringRepresentativeForOptions:@[
        @"barf", @"flarn", @"syn", @"ack", @"quone", @"xyzzy"
    ]];
    
    expectedConstraints = [@[ requiredConstraint ] arrayByAddingObjectsFromArray:expectedConstraints];
    XCTAssertEqualObjects(group.constraints, expectedConstraints);
    
    group = [CLKOptionGroup mutexedGroupForOptionsNamed:nil subgroups:@[ confound ] required:NO];
    XCTAssertEqualObjects(group.constraints, @[]);
    
    group = [CLKOptionGroup mutexedGroupForOptionsNamed:nil subgroups:@[ confound, delivery ] required:NO];
    expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"syn", @"quone" ]],
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"syn", @"xyzzy" ]],
        
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"ack", @"quone" ]],
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"ack", @"xyzzy" ]],
    ];
    
    XCTAssertEqualObjects(group.constraints, expectedConstraints);
    
    // above constraints + rep-req constraint
    group = [CLKOptionGroup mutexedGroupForOptionsNamed:nil subgroups:@[ confound, delivery ] required:YES];
    requiredConstraint = [CLKArgumentManifestConstraint constraintRequiringRepresentativeForOptions:@[
        @"syn", @"ack", @"quone", @"xyzzy"
    ]];
    
    expectedConstraints = [@[ requiredConstraint ] arrayByAddingObjectsFromArray:expectedConstraints];
    XCTAssertEqualObjects(group.constraints, expectedConstraints);
}

@end
