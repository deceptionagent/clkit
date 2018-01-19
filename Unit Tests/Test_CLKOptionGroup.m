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
    CLKOption *barf  = [CLKOption parameterOptionWithName:@"barf" flag:@"b"];
    CLKOption *flarn = [CLKOption parameterOptionWithName:@"flarn" flag:@"f"];
    
    CLKOptionGroup *group = [CLKOptionGroup mutexedGroupWithOptions:@[ barf, flarn ] required:NO];
    NSArray<CLKArgumentManifestConstraint *> *expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"barf", @"flarn" ]]
    ];
    
    XCTAssertEqualObjects(group.constraints, expectedConstraints);
    
    group = [CLKOptionGroup mutexedGroupWithOptions:@[ barf, flarn ] required:YES];
    expectedConstraints = @[
        [CLKArgumentManifestConstraint constraintRequiringRepresentativeForOptions:@[ @"barf", @"flarn" ]],
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"barf", @"flarn" ]]
    ];
    
    XCTAssertEqualObjects(group.constraints, expectedConstraints);
    
#warning test subgroups
//    CLKOption *quone = [CLKOption parameterOptionWithName:@"quone" flag:@"q"];
//    CLKOption *xyzzy = [CLKOption parameterOptionWithName:@"xyzzy" flag:@"x"];
//    CLKOption *confound = [CLKOption parameterOptionWithName:@"confound" flag:@"c"];
//    CLKOption *delivery = [CLKOption parameterOptionWithName:@"delivery" flag:@"c"];
}

@end
