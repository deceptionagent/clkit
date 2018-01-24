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

- (void)verifyGroup:(CLKOptionGroup *)group options:(NSArray<CLKOption *> *)options subgroups:(NSArray<CLKOptionGroup *> *)subgroups required:(BOOL)required mutexed:(BOOL)mutexed
{
    XCTAssertNotNil(group);
    XCTAssertEqualObjects(group.options, options);
    XCTAssertEqualObjects(group.subgroups, subgroups);
    XCTAssertEqual(group.required, required);
    XCTAssertEqual(group.mutexed, mutexed);
}

- (void)testInit
{
    NSArray *options = @[
        [CLKOption optionWithName:@"flarn" flag:@"f"],
        [CLKOption optionWithName:@"barf" flag:@"b"],
    ];
    
    CLKOptionGroup *group = [CLKOptionGroup groupWithOptions:options required:NO];
    [self verifyGroup:group options:options subgroups:nil required:NO mutexed:NO];

    group = [CLKOptionGroup groupWithOptions:options required:YES];
    [self verifyGroup:group options:options subgroups:nil required:YES mutexed:NO];
    
    group = [CLKOptionGroup mutexedGroupWithOptions:options required:NO];
    [self verifyGroup:group options:options subgroups:nil required:NO mutexed:YES];
    
    group = [CLKOptionGroup mutexedGroupWithOptions:options required:YES];
    [self verifyGroup:group options:options subgroups:nil required:YES mutexed:YES];
    
    group = [CLKOptionGroup mutexedGroupWithOptions:options subgroups:nil required:NO];
    [self verifyGroup:group options:options subgroups:nil required:NO mutexed:YES];
    
    CLKOptionGroup *subgroupAlpha = [CLKOptionGroup groupWithOptions:options required:NO];
    CLKOptionGroup *subgroupBravo = [CLKOptionGroup groupWithOptions:options required:NO];
    NSArray *subgroups = @[ subgroupAlpha, subgroupBravo ];
    
    group = [CLKOptionGroup mutexedGroupWithOptions:options subgroups:subgroups required:YES];
    [self verifyGroup:group options:options subgroups:subgroups required:YES mutexed:YES];
    
    group = [CLKOptionGroup mutexedGroupWithOptions:nil subgroups:subgroups required:YES];
    [self verifyGroup:group options:nil subgroups:subgroups required:YES mutexed:YES];
}

- (void)testConstraints_boringGroup
{
    CLKOption *barf  = [CLKOption parameterOptionWithName:@"barf" flag:@"b"];
    CLKOption *flarn = [CLKOption parameterOptionWithName:@"flarn" flag:@"f"];
    
    CLKOptionGroup *group = [CLKOptionGroup groupWithOptions:@[ barf, flarn ] required:NO];
    XCTAssertEqualObjects(group.constraints, @[]);
    
    group = [CLKOptionGroup groupWithOptions:@[ barf, flarn ] required:YES];
    NSArray<CLKArgumentManifestConstraint *> *expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintRequiringRepresentativeForOptions:@[ @"barf", @"flarn" ]]
    ];
    
    XCTAssertEqualObjects(group.constraints, expectedConstraints);
}

- (void)testConstraints_mutexedGroup
{
    CLKOption *barf  = [CLKOption optionWithName:@"barf" flag:@"b"];
    CLKOption *flarn = [CLKOption optionWithName:@"flarn" flag:@"f"];
    CLKOption *quone = [CLKOption optionWithName:@"quone" flag:@"q"];

    CLKOptionGroup *group = [CLKOptionGroup mutexedGroupWithOptions:@[ barf, flarn, quone ] required:NO];
    NSArray<CLKArgumentManifestConstraint *> *expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"barf", @"flarn", @"quone" ]]
    ];
    
    XCTAssertEqualObjects(group.constraints, expectedConstraints);
    
    group = [CLKOptionGroup mutexedGroupWithOptions:@[ barf, flarn ] required:YES];
    expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintRequiringRepresentativeForOptions:@[ @"barf", @"flarn" ]],
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"barf", @"flarn" ]]
    ];
    
    XCTAssertEqualObjects(group.constraints, expectedConstraints);
}

- (void)testConstraints_mutexedGroup_subgroups
{
    CLKOption *barf  = [CLKOption optionWithName:@"barf" flag:@"b"];
    CLKOption *flarn = [CLKOption optionWithName:@"flarn" flag:@"f"];
    CLKOption *syn  = [CLKOption optionWithName:@"syn" flag:@"s"];
    CLKOption *ack = [CLKOption optionWithName:@"ack" flag:@"a"];
    CLKOption *quone = [CLKOption parameterOptionWithName:@"quone" flag:@"q"];
    CLKOption *xyzzy = [CLKOption parameterOptionWithName:@"xyzzy" flag:@"x"];
    CLKOptionGroup *confound = [CLKOptionGroup groupWithOptions:@[ syn, ack ] required:NO];
    CLKOptionGroup *delivery = [CLKOptionGroup groupWithOptions:@[ quone, xyzzy ] required:NO];
    
    CLKOptionGroup *group = [CLKOptionGroup mutexedGroupWithOptions:@[ barf, flarn ] subgroups:@[ confound ] required:NO];
    NSArray<CLKArgumentManifestConstraint *> *expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"barf", @"flarn" ]],
        
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"barf", @"syn" ]],
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"barf", @"ack" ]],
        
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"flarn", @"syn" ]],
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"flarn", @"ack" ]],
    ];
    
    XCTAssertEqualObjects(group.constraints, expectedConstraints);
    
    group = [CLKOptionGroup mutexedGroupWithOptions:@[ barf, flarn ] subgroups:@[ confound ] required:YES];
    CLKArgumentManifestConstraint *requiredConstraint = [CLKArgumentManifestConstraint constraintRequiringRepresentativeForOptions:@[
        @"barf", @"flarn", @"syn", @"ack"
    ]];
    
    expectedConstraints = [@[ requiredConstraint ] arrayByAddingObjectsFromArray:expectedConstraints];
    XCTAssertEqualObjects(group.constraints, expectedConstraints);
    
    group = [CLKOptionGroup mutexedGroupWithOptions:@[ barf, flarn ] subgroups:@[ confound, delivery ] required:NO];
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
    
    group = [CLKOptionGroup mutexedGroupWithOptions:@[ barf, flarn ] subgroups:@[ confound, delivery ] required:YES];
    requiredConstraint = [CLKArgumentManifestConstraint constraintRequiringRepresentativeForOptions:@[
        @"barf", @"flarn", @"syn", @"ack", @"quone", @"xyzzy"
    ]];
    
    expectedConstraints = [@[ requiredConstraint ] arrayByAddingObjectsFromArray:expectedConstraints];
    XCTAssertEqualObjects(group.constraints, expectedConstraints);

    group = [CLKOptionGroup mutexedGroupWithOptions:nil subgroups:@[ confound ] required:NO];
    XCTAssertEqualObjects(group.constraints, @[]);
    
    group = [CLKOptionGroup mutexedGroupWithOptions:nil subgroups:@[ confound, delivery ] required:NO];
    expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"syn", @"quone" ]],
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"syn", @"xyzzy" ]],
        
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"ack", @"quone" ]],
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"ack", @"xyzzy" ]],
    ];
    
    XCTAssertEqualObjects(group.constraints, expectedConstraints);

    group = [CLKOptionGroup mutexedGroupWithOptions:nil subgroups:@[ confound, delivery ] required:YES];
    requiredConstraint = [CLKArgumentManifestConstraint constraintRequiringRepresentativeForOptions:@[
        @"syn", @"ack", @"quone", @"xyzzy"
    ]];
    
    expectedConstraints = [@[ requiredConstraint ] arrayByAddingObjectsFromArray:expectedConstraints];
    XCTAssertEqualObjects(group.constraints, expectedConstraints);
}

@end
