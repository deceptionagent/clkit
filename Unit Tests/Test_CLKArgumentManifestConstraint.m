//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CLKArgumentManifestConstraint.h"

@interface Test_CLKArgumentManifestConstraint : XCTestCase

@end

@implementation Test_CLKArgumentManifestConstraint

- (void)testDescription
{
    CLKArgumentManifestConstraint *constraint = [CLKArgumentManifestConstraint constraintForRequiredOption:@"flarn"];
    NSString *expectedDescription = [NSString stringWithFormat:@"<CLKArgumentManifestConstraint: %p> { required | options: [ flarn ] | auxOptions: [ (null) ] }", constraint];
    XCTAssertEqualObjects(constraint.description, expectedDescription);
    
    constraint = [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"flarn" causalOption:@"barf"];
    expectedDescription = [NSString stringWithFormat:@"<CLKArgumentManifestConstraint: %p> { conditionally required | options: [ flarn ] | auxOptions: [ barf ] }", constraint];
    XCTAssertEqualObjects(constraint.description, expectedDescription);

    constraint = [CLKArgumentManifestConstraint constraintRequiringRepresentationForOptions:@[ @"flarn", @"barf", @"quone" ]];
    expectedDescription = [NSString stringWithFormat:@"<CLKArgumentManifestConstraint: %p> { representation required | options: [ flarn, barf, quone ] | auxOptions: [ (null) ] }", constraint];
    XCTAssertEqualObjects(constraint.description, expectedDescription);
    
    constraint = [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"flarn", @"barf" ]];
    expectedDescription = [NSString stringWithFormat:@"<CLKArgumentManifestConstraint: %p> { mutually exclusive | options: [ flarn, barf ] | auxOptions: [ (null) ] }", constraint];
    XCTAssertEqualObjects(constraint.description, expectedDescription);
    
    constraint = [CLKArgumentManifestConstraint constraintForStandaloneOption:@"flarn" allowingOptions:nil];
    expectedDescription = [NSString stringWithFormat:@"<CLKArgumentManifestConstraint: %p> { standalone | options: [ flarn ] | auxOptions: [ (null) ] }", constraint];
    XCTAssertEqualObjects(constraint.description, expectedDescription);
    
    constraint = [CLKArgumentManifestConstraint constraintForStandaloneOption:@"flarn" allowingOptions:@[ @"barf", @"quone", ]];
    expectedDescription = [NSString stringWithFormat:@"<CLKArgumentManifestConstraint: %p> { standalone | options: [ flarn ] | auxOptions: [ barf, quone ] }", constraint];
    XCTAssertEqualObjects(constraint.description, expectedDescription);
    
    constraint = [CLKArgumentManifestConstraint constraintLimitingOccurrencesForOption:@"flarn"];
    expectedDescription = [NSString stringWithFormat:@"<CLKArgumentManifestConstraint: %p> { occurrences limited | options: [ flarn ] | auxOptions: [ (null) ] }", constraint];
    XCTAssertEqualObjects(constraint.description, expectedDescription);
}

- (void)testRequired
{
    CLKArgumentManifestConstraint *constraint = [CLKArgumentManifestConstraint constraintForRequiredOption:@"flarn"];
    XCTAssertNotNil(constraint);
    XCTAssertEqual(constraint.type, CLKConstraintTypeRequired);
    XCTAssertEqualObjects(constraint.options, [NSOrderedSet orderedSetWithObject:@"flarn"]);
    XCTAssertNil(constraint.auxOptions);
}

- (void)testConditionallyRequired
{
    CLKArgumentManifestConstraint *constraint = [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"flarn" causalOption:@"barf"];
    XCTAssertNotNil(constraint);
    XCTAssertEqual(constraint.type, CLKConstraintTypeConditionallyRequired);
    XCTAssertEqualObjects(constraint.options, [NSOrderedSet orderedSetWithObject:@"flarn"]);
    XCTAssertEqualObjects(constraint.auxOptions, [NSOrderedSet orderedSetWithObject:@"barf"]);
}

- (void)testRepresentationRequired
{
    CLKArgumentManifestConstraint *constraint = [CLKArgumentManifestConstraint constraintRequiringRepresentationForOptions:@[ @"flarn", @"barf" ]];
    XCTAssertNotNil(constraint);
    XCTAssertEqual(constraint.type, CLKConstraintTypeRepresentationRequired);
    XCTAssertEqualObjects(constraint.options, ([NSOrderedSet orderedSetWithObjects:@"flarn", @"barf", nil]));
    XCTAssertNil(constraint.auxOptions);
}

- (void)testMutuallyExclusive
{
    CLKArgumentManifestConstraint *constraint = [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"flarn", @"barf" ]];
    XCTAssertNotNil(constraint);
    XCTAssertEqual(constraint.type, CLKConstraintTypeMutuallyExclusive);
    XCTAssertEqualObjects(constraint.options, ([NSOrderedSet orderedSetWithObjects:@"flarn", @"barf", nil]));
    XCTAssertNil(constraint.auxOptions);
}

- (void)testStandalone
{
    CLKArgumentManifestConstraint *constraint = [CLKArgumentManifestConstraint constraintForStandaloneOption:@"flarn" allowingOptions:nil];
    XCTAssertNotNil(constraint);
    XCTAssertEqual(constraint.type, CLKConstraintTypeStandalone);
    XCTAssertEqualObjects(constraint.options, [NSOrderedSet orderedSetWithObject:@"flarn"]);
    XCTAssertNil(constraint.auxOptions);
    
    constraint = [CLKArgumentManifestConstraint constraintForStandaloneOption:@"flarn" allowingOptions:@[ @"barf", @"quone" ]];
    XCTAssertEqual(constraint.type, CLKConstraintTypeStandalone);
    XCTAssertEqualObjects(constraint.options, [NSOrderedSet orderedSetWithObject:@"flarn"]);
    XCTAssertEqualObjects(constraint.auxOptions, ([NSOrderedSet orderedSetWithObjects:@"barf", @"quone", nil]));
}

- (void)testOccurrencesLimited
{
    CLKArgumentManifestConstraint *constraint = [CLKArgumentManifestConstraint constraintLimitingOccurrencesForOption:@"flarn"];
    XCTAssertNotNil(constraint);
    XCTAssertEqual(constraint.type, CLKConstraintTypeOccurrencesLimited);
    XCTAssertEqualObjects(constraint.options, [NSOrderedSet orderedSetWithObject:@"flarn"]);
    XCTAssertNil(constraint.auxOptions);
}

- (void)testEquality
{
    #define ASSERT_EQUAL_CONSTRAINTS(c1, c2) \
        XCTAssertTrue([c1 isEqual:c2], @"%@ :: %@", c1, c2);
    
    #define ASSERT_NOT_EQUAL_CONSTRAINTS(c1, c2) \
        XCTAssertFalse([c1 isEqual:c2], @"%@ :: %@", c1, c2);
    
    CLKArgumentManifestConstraint *requiredAlpha = [CLKArgumentManifestConstraint constraintForRequiredOption:@"flarn"];
    CLKArgumentManifestConstraint *requiredAlpha_clone = [CLKArgumentManifestConstraint constraintForRequiredOption:@"flarn"];
    CLKArgumentManifestConstraint *requiredBravo = [CLKArgumentManifestConstraint constraintForRequiredOption:@"barf"];
    ASSERT_EQUAL_CONSTRAINTS(requiredAlpha, requiredAlpha);
    ASSERT_EQUAL_CONSTRAINTS(requiredAlpha, requiredAlpha_clone);
    ASSERT_NOT_EQUAL_CONSTRAINTS(requiredAlpha, requiredBravo);
    
    CLKArgumentManifestConstraint *conditionallyRequiredAlpha = [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"flarn" causalOption:@"barf"];
    CLKArgumentManifestConstraint *conditionallyRequiredAlpha_clone = [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"flarn" causalOption:@"barf"];
    CLKArgumentManifestConstraint *conditionallyRequiredBravo = [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"quone" causalOption:@"barf"];
    CLKArgumentManifestConstraint *conditionallyRequiredCharlie = [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"quone" causalOption:@"xyzzy"];
    ASSERT_EQUAL_CONSTRAINTS(conditionallyRequiredAlpha, conditionallyRequiredAlpha);
    ASSERT_EQUAL_CONSTRAINTS(conditionallyRequiredAlpha, conditionallyRequiredAlpha_clone);
    ASSERT_NOT_EQUAL_CONSTRAINTS(conditionallyRequiredAlpha, conditionallyRequiredBravo);
    ASSERT_NOT_EQUAL_CONSTRAINTS(conditionallyRequiredBravo, conditionallyRequiredCharlie);
    
    CLKArgumentManifestConstraint *representationRequiredAlpha = [CLKArgumentManifestConstraint constraintRequiringRepresentationForOptions:@[ @"flarn", @"barf" ]];
    CLKArgumentManifestConstraint *representationRequiredAlpha_clone = [CLKArgumentManifestConstraint constraintRequiringRepresentationForOptions:@[ @"flarn", @"barf" ]];
    CLKArgumentManifestConstraint *representationRequiredBravo = [CLKArgumentManifestConstraint constraintRequiringRepresentationForOptions:@[ @"flarn", @"quone" ]];
    ASSERT_EQUAL_CONSTRAINTS(representationRequiredAlpha, representationRequiredAlpha);
    ASSERT_EQUAL_CONSTRAINTS(representationRequiredAlpha, representationRequiredAlpha_clone);
    ASSERT_NOT_EQUAL_CONSTRAINTS(representationRequiredAlpha, representationRequiredBravo);
    
    CLKArgumentManifestConstraint *mutexedAlpha = [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"flarn", @"barf" ]];
    CLKArgumentManifestConstraint *mutexedAlpha_clone = [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"flarn", @"barf" ]];
    CLKArgumentManifestConstraint *mutexedBravo = [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"flarn", @"quone" ]];
    ASSERT_EQUAL_CONSTRAINTS(mutexedAlpha, mutexedAlpha);
    ASSERT_EQUAL_CONSTRAINTS(mutexedAlpha, mutexedAlpha_clone);
    ASSERT_NOT_EQUAL_CONSTRAINTS(mutexedAlpha, mutexedBravo);
    
    CLKArgumentManifestConstraint *limitedAlpha = [CLKArgumentManifestConstraint constraintLimitingOccurrencesForOption:@"flarn"];
    CLKArgumentManifestConstraint *limitedAlpha_clone = [CLKArgumentManifestConstraint constraintLimitingOccurrencesForOption:@"flarn"];
    CLKArgumentManifestConstraint *limitedBravo = [CLKArgumentManifestConstraint constraintLimitingOccurrencesForOption:@"barf"];
    ASSERT_EQUAL_CONSTRAINTS(limitedAlpha, limitedAlpha);
    ASSERT_EQUAL_CONSTRAINTS(limitedAlpha, limitedAlpha_clone);
    ASSERT_NOT_EQUAL_CONSTRAINTS(limitedAlpha, limitedBravo);
    
    CLKArgumentManifestConstraint *standaloneAlpha = [CLKArgumentManifestConstraint constraintForStandaloneOption:@"flarn" allowingOptions:nil];
    CLKArgumentManifestConstraint *standaloneAlpha_clone = [CLKArgumentManifestConstraint constraintForStandaloneOption:@"flarn" allowingOptions:nil];
    CLKArgumentManifestConstraint *standaloneBravo = [CLKArgumentManifestConstraint constraintForStandaloneOption:@"flarn" allowingOptions:@[ @"barf" ]];
    CLKArgumentManifestConstraint *standaloneCharlie = [CLKArgumentManifestConstraint constraintForStandaloneOption:@"quone" allowingOptions:nil];
    ASSERT_EQUAL_CONSTRAINTS(standaloneAlpha, standaloneAlpha);
    ASSERT_EQUAL_CONSTRAINTS(standaloneAlpha, standaloneAlpha_clone);
    ASSERT_NOT_EQUAL_CONSTRAINTS(standaloneAlpha, standaloneBravo);
    ASSERT_NOT_EQUAL_CONSTRAINTS(standaloneAlpha, standaloneCharlie);
    
    /* cross-type tests */
    
    NSArray *constraints = @[
        requiredAlpha,
        conditionallyRequiredAlpha,
        representationRequiredAlpha,
        mutexedAlpha,
        limitedAlpha,
        standaloneAlpha
    ];
    
    // check each constraint against each constraint that succeeds it in the list.
    // when we're done, we will have exhausted the comparison space.
    for (NSUInteger i = 0 ; i < constraints.count ; i++) {
        CLKArgumentManifestConstraint *alpha = constraints[i];
        for (NSUInteger r = i + 1 ; r < constraints.count ; r++) {
            CLKArgumentManifestConstraint *bravo = constraints[r];
            XCTAssertFalse([alpha isEqualToConstraint:bravo], @"%@ :: %@", alpha, bravo);
        }
    }
    
    /* misc */
    
    XCTAssertNotEqualObjects(requiredAlpha, nil);
    XCTAssertNotEqualObjects(requiredAlpha, @"not a constraint");
}

- (void)testCollectionSupport_set
{
    NSArray *constraints = @[
        [CLKArgumentManifestConstraint constraintForRequiredOption:@"flarn"],
        [CLKArgumentManifestConstraint constraintForRequiredOption:@"barf"],
        [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"flarn" causalOption:@"barf"],
        [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"barf" causalOption:@"flarn"],
        [CLKArgumentManifestConstraint constraintRequiringRepresentationForOptions:@[ @"flarn", @"barf" ]],
        [CLKArgumentManifestConstraint constraintRequiringRepresentationForOptions:@[ @"quone", @"xyzzy" ]],
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"flarn", @"barf" ]],
        [CLKArgumentManifestConstraint constraintForStandaloneOption:@"flarn" allowingOptions:nil],
        [CLKArgumentManifestConstraint constraintForStandaloneOption:@"flarn" allowingOptions:@[ @"barf" ]],
        [CLKArgumentManifestConstraint constraintLimitingOccurrencesForOption:@"flarn"],
    ];
    
    // redundant constraints should be deduplicated
    NSArray *constraintClones = @[
        [CLKArgumentManifestConstraint constraintForRequiredOption:@"flarn"],
        [CLKArgumentManifestConstraint constraintForRequiredOption:@"barf"],
        [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"flarn" causalOption:@"barf"],
        [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"barf" causalOption:@"flarn"],
        [CLKArgumentManifestConstraint constraintRequiringRepresentationForOptions:@[ @"flarn", @"barf" ]],
        [CLKArgumentManifestConstraint constraintRequiringRepresentationForOptions:@[ @"quone", @"xyzzy" ]],
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"flarn", @"barf" ]],
        [CLKArgumentManifestConstraint constraintForStandaloneOption:@"flarn" allowingOptions:nil],
        [CLKArgumentManifestConstraint constraintForStandaloneOption:@"flarn" allowingOptions:@[ @"barf" ]],
        [CLKArgumentManifestConstraint constraintLimitingOccurrencesForOption:@"flarn"]
    ];
    
    NSSet *expectedConstraintSet = [NSSet setWithArray:constraints];
    NSArray *redundantConstraints = [constraints arrayByAddingObjectsFromArray:constraintClones];
    NSSet *constraintSet = [NSSet setWithArray:redundantConstraints];
    XCTAssertEqualObjects(constraintSet, expectedConstraintSet);
    
    for (NSUInteger i = 0 ; i < constraints.count ; i++) {
        CLKArgumentManifestConstraint *constraint = constraints[i];
        CLKArgumentManifestConstraint *clone = constraintClones[i];
        XCTAssertTrue([constraintSet containsObject:constraint]);
        XCTAssertTrue([constraintSet containsObject:clone]);
    }
}

@end
