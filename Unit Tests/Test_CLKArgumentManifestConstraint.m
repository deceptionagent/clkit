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
    NSString *expectedDescription = [NSString stringWithFormat:@"<CLKArgumentManifestConstraint: %p> { required | primary: flarn | associated: (null) | linked: [ (null) ] }", constraint];
    XCTAssertEqualObjects(constraint.description, expectedDescription);
    
    constraint = [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"flarn" associatedOption:@"barf"];
    expectedDescription = [NSString stringWithFormat:@"<CLKArgumentManifestConstraint: %p> { conditionally required | primary: flarn | associated: barf | linked: [ (null) ] }", constraint];
    XCTAssertEqualObjects(constraint.description, expectedDescription);

    constraint = [CLKArgumentManifestConstraint constraintRequiringRepresentativeForOptions:@[ @"flarn", @"barf", @"quone" ]];
    expectedDescription = [NSString stringWithFormat:@"<CLKArgumentManifestConstraint: %p> { representative required | primary: (null) | associated: (null) | linked: [ flarn, barf, quone ] }", constraint];
    XCTAssertEqualObjects(constraint.description, expectedDescription);
    
    constraint = [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"flarn", @"barf" ]];
    expectedDescription = [NSString stringWithFormat:@"<CLKArgumentManifestConstraint: %p> { mutually exclusive | primary: (null) | associated: (null) | linked: [ flarn, barf ] }", constraint];
    XCTAssertEqualObjects(constraint.description, expectedDescription);
    
    constraint = [CLKArgumentManifestConstraint constraintForStandaloneOption:@"flarn" allowingOptions:nil];
    expectedDescription = [NSString stringWithFormat:@"<CLKArgumentManifestConstraint: %p> { standalone | primary: flarn | associated: (null) | linked: [ (null) ] }", constraint];
    XCTAssertEqualObjects(constraint.description, expectedDescription);
    
    constraint = [CLKArgumentManifestConstraint constraintForStandaloneOption:@"flarn" allowingOptions:@[ @"barf", @"quone", ]];
    expectedDescription = [NSString stringWithFormat:@"<CLKArgumentManifestConstraint: %p> { standalone | primary: flarn | associated: (null) | linked: [ barf, quone ] }", constraint];
    XCTAssertEqualObjects(constraint.description, expectedDescription);
    
    constraint = [CLKArgumentManifestConstraint constraintLimitingOccurrencesForOption:@"flarn"];
    expectedDescription = [NSString stringWithFormat:@"<CLKArgumentManifestConstraint: %p> { occurrences limited | primary: flarn | associated: (null) | linked: [ (null) ] }", constraint];
    XCTAssertEqualObjects(constraint.description, expectedDescription);
}

- (void)testRequired
{
    CLKArgumentManifestConstraint *constraint = [CLKArgumentManifestConstraint constraintForRequiredOption:@"flarn"];
    XCTAssertEqual(constraint.type, CLKConstraintTypeRequired);
    XCTAssertEqualObjects(constraint.option, @"flarn");
    XCTAssertNil(constraint.associatedOption);
    XCTAssertNil(constraint.linkedOptions);
}

- (void)testConditionallyRequired
{
    CLKArgumentManifestConstraint *constraint = [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"flarn" associatedOption:@"barf"];
    XCTAssertEqual(constraint.type, CLKConstraintTypeConditionallyRequired);
    XCTAssertEqualObjects(constraint.option, @"flarn");
    XCTAssertEqualObjects(constraint.associatedOption, @"barf");
    XCTAssertNil(constraint.linkedOptions);
}

- (void)testRepresentativeRequired
{
    CLKArgumentManifestConstraint *constraint = [CLKArgumentManifestConstraint constraintRequiringRepresentativeForOptions:@[ @"flarn", @"barf" ]];
    XCTAssertEqual(constraint.type, CLKConstraintTypeRepresentativeRequired);
    XCTAssertNil(constraint.option);
    XCTAssertNil(constraint.associatedOption);
    XCTAssertEqualObjects(constraint.linkedOptions, (@[ @"flarn", @"barf" ]));
}

- (void)testMutuallyExclusive
{
    CLKArgumentManifestConstraint *constraint = [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"flarn", @"barf" ]];
    XCTAssertEqual(constraint.type, CLKConstraintTypeMutuallyExclusive);
    XCTAssertNil(constraint.option);
    XCTAssertNil(constraint.associatedOption);
    XCTAssertEqualObjects(constraint.linkedOptions, (@[ @"flarn", @"barf" ]));
}

- (void)testStandalone
{
    CLKArgumentManifestConstraint *constraint = [CLKArgumentManifestConstraint constraintForStandaloneOption:@"flarn" allowingOptions:nil];
    XCTAssertEqual(constraint.type, CLKConstraintTypeStandalone);
    XCTAssertEqualObjects(constraint.option, @"flarn");
    XCTAssertNil(constraint.associatedOption);
    XCTAssertNil(constraint.linkedOptions);

    constraint = [CLKArgumentManifestConstraint constraintForStandaloneOption:@"flarn" allowingOptions:@[ @"barf", @"quone" ]];
    XCTAssertEqual(constraint.type, CLKConstraintTypeStandalone);
    XCTAssertEqualObjects(constraint.option, @"flarn");
    XCTAssertNil(constraint.associatedOption);
    XCTAssertEqualObjects(constraint.linkedOptions, (@[ @"barf", @"quone" ]));
}

- (void)testOccurrencesLimited
{
    CLKArgumentManifestConstraint *constraint = [CLKArgumentManifestConstraint constraintLimitingOccurrencesForOption:@"flarn"];
    XCTAssertEqual(constraint.type, CLKConstraintTypeOccurrencesLimited);
    XCTAssertEqualObjects(constraint.option, @"flarn");
    XCTAssertNil(constraint.associatedOption);
    XCTAssertNil(constraint.linkedOptions);
}

- (void)testEquality
{
    #define ASSERT_EQUAL_CONSTRAINTS(c1, c2) \
        XCTAssertEqualObjects(c1, c2); \
        XCTAssertTrue([c1 isEqualToConstraint:c2], @"%@ :: %@", c1, c2);
    
    #define ASSERT_NOT_EQUAL_CONSTRAINTS(c1, c2) \
        XCTAssertNotEqualObjects(c1, c2); \
        XCTAssertFalse([c1 isEqualToConstraint:c2], @"%@ :: %@", c1, c2);
    
    CLKArgumentManifestConstraint *requiredAlpha = [CLKArgumentManifestConstraint constraintForRequiredOption:@"flarn"];
    CLKArgumentManifestConstraint *requiredBravo = [CLKArgumentManifestConstraint constraintForRequiredOption:@"flarn"];
    CLKArgumentManifestConstraint *requiredCharlie = [CLKArgumentManifestConstraint constraintForRequiredOption:@"barf"];
    ASSERT_EQUAL_CONSTRAINTS(requiredAlpha, requiredAlpha);
    ASSERT_EQUAL_CONSTRAINTS(requiredAlpha, requiredBravo);
    ASSERT_NOT_EQUAL_CONSTRAINTS(requiredAlpha, requiredCharlie);
    
    CLKArgumentManifestConstraint *conditionallyRequiredAlpha = [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"flarn" associatedOption:@"barf"];
    CLKArgumentManifestConstraint *conditionallyRequiredBravo = [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"flarn" associatedOption:@"barf"];
    CLKArgumentManifestConstraint *conditionallyRequiredCharlie = [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"quone" associatedOption:@"barf"];
    CLKArgumentManifestConstraint *conditionallyRequiredDelta = [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"quone" associatedOption:@"xyzzy"];
    ASSERT_EQUAL_CONSTRAINTS(conditionallyRequiredAlpha, conditionallyRequiredAlpha);
    ASSERT_EQUAL_CONSTRAINTS(conditionallyRequiredAlpha, conditionallyRequiredBravo);
    ASSERT_NOT_EQUAL_CONSTRAINTS(conditionallyRequiredAlpha, conditionallyRequiredCharlie);
    ASSERT_NOT_EQUAL_CONSTRAINTS(conditionallyRequiredCharlie, conditionallyRequiredDelta);
    
    CLKArgumentManifestConstraint *representativeRequiredAlpha = [CLKArgumentManifestConstraint constraintRequiringRepresentativeForOptions:@[ @"flarn", @"barf" ]];
    CLKArgumentManifestConstraint *representativeRequiredBravo = [CLKArgumentManifestConstraint constraintRequiringRepresentativeForOptions:@[ @"flarn", @"barf" ]];
    CLKArgumentManifestConstraint *representativeRequiredCharlie = [CLKArgumentManifestConstraint constraintRequiringRepresentativeForOptions:@[ @"flarn", @"quone" ]];
    ASSERT_EQUAL_CONSTRAINTS(representativeRequiredAlpha, representativeRequiredAlpha);
    ASSERT_EQUAL_CONSTRAINTS(representativeRequiredAlpha, representativeRequiredBravo);
    ASSERT_NOT_EQUAL_CONSTRAINTS(representativeRequiredAlpha, representativeRequiredCharlie);
    
    CLKArgumentManifestConstraint *mutexedAlpha = [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"flarn", @"barf" ]];
    CLKArgumentManifestConstraint *mutexedBravo = [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"flarn", @"barf" ]];
    CLKArgumentManifestConstraint *mutexedCharlie = [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"flarn", @"quone" ]];
    ASSERT_EQUAL_CONSTRAINTS(mutexedAlpha, mutexedAlpha);
    ASSERT_EQUAL_CONSTRAINTS(mutexedAlpha, mutexedBravo);
    ASSERT_NOT_EQUAL_CONSTRAINTS(mutexedAlpha, mutexedCharlie);
    
    CLKArgumentManifestConstraint *limitedAlpha = [CLKArgumentManifestConstraint constraintLimitingOccurrencesForOption:@"flarn"];
    CLKArgumentManifestConstraint *limitedBravo = [CLKArgumentManifestConstraint constraintLimitingOccurrencesForOption:@"flarn"];
    CLKArgumentManifestConstraint *limitedCharlie = [CLKArgumentManifestConstraint constraintLimitingOccurrencesForOption:@"barf"];
    ASSERT_EQUAL_CONSTRAINTS(limitedAlpha, limitedAlpha);
    ASSERT_EQUAL_CONSTRAINTS(limitedAlpha, limitedBravo);
    ASSERT_NOT_EQUAL_CONSTRAINTS(limitedAlpha, limitedCharlie);
    
    /* cross-type tests */
    
    NSArray *constraints = @[
        requiredAlpha,
        conditionallyRequiredAlpha,
        representativeRequiredAlpha,
        mutexedAlpha,
        limitedAlpha
    ];
    
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
        [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"flarn" associatedOption:@"barf"],
        [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"barf" associatedOption:@"flarn"],
        [CLKArgumentManifestConstraint constraintRequiringRepresentativeForOptions:@[ @"flarn", @"barf" ]],
        [CLKArgumentManifestConstraint constraintRequiringRepresentativeForOptions:@[ @"quone", @"xyzzy" ]],
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"flarn", @"barf" ]],
        [CLKArgumentManifestConstraint constraintForStandaloneOption:@"flarn" allowingOptions:nil],
        [CLKArgumentManifestConstraint constraintForStandaloneOption:@"flarn" allowingOptions:@[ @"barf" ]],
        [CLKArgumentManifestConstraint constraintLimitingOccurrencesForOption:@"flarn"],
    ];
    
    // redundant constraints should be deduplicated
    NSArray *constraintClones = @[
        [CLKArgumentManifestConstraint constraintForRequiredOption:@"flarn"],
        [CLKArgumentManifestConstraint constraintForRequiredOption:@"barf"],
        [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"flarn" associatedOption:@"barf"],
        [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"barf" associatedOption:@"flarn"],
        [CLKArgumentManifestConstraint constraintRequiringRepresentativeForOptions:@[ @"flarn", @"barf" ]],
        [CLKArgumentManifestConstraint constraintRequiringRepresentativeForOptions:@[ @"quone", @"xyzzy" ]],
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
