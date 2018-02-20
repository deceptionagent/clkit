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

    constraint = [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"flarn", @"barf" ]];
    expectedDescription = [NSString stringWithFormat:@"<CLKArgumentManifestConstraint: %p> { mutually exclusive | primary: (null) | associated: (null) | linked: [ flarn, barf ] }", constraint];
    XCTAssertEqualObjects(constraint.description, expectedDescription);
    
    constraint = [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"flarn", @"barf", @"quone" ]];
    expectedDescription = [NSString stringWithFormat:@"<CLKArgumentManifestConstraint: %p> { mutually exclusive | primary: (null) | associated: (null) | linked: [ flarn, barf, quone ] }", constraint];
    XCTAssertEqualObjects(constraint.description, expectedDescription);

    constraint = [CLKArgumentManifestConstraint constraintRestrictingOccurrencesForOption:@"flarn"];
    expectedDescription = [NSString stringWithFormat:@"<CLKArgumentManifestConstraint: %p> { occurrences restricted | primary: flarn | associated: (null) | linked: [ (null) ] }", constraint];
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

- (void)testOccurrencesRestricted
{
    CLKArgumentManifestConstraint *constraint = [CLKArgumentManifestConstraint constraintRestrictingOccurrencesForOption:@"flarn"];
    XCTAssertEqual(constraint.type, CLKConstraintTypeOccurrencesRestricted);
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
    
    CLKArgumentManifestConstraint *restrictedAlpha = [CLKArgumentManifestConstraint constraintRestrictingOccurrencesForOption:@"flarn"];
    CLKArgumentManifestConstraint *restrictedBravo = [CLKArgumentManifestConstraint constraintRestrictingOccurrencesForOption:@"flarn"];
    CLKArgumentManifestConstraint *restrictedCharlie = [CLKArgumentManifestConstraint constraintRestrictingOccurrencesForOption:@"barf"];
    ASSERT_EQUAL_CONSTRAINTS(restrictedAlpha, restrictedAlpha);
    ASSERT_EQUAL_CONSTRAINTS(restrictedAlpha, restrictedBravo);
    ASSERT_NOT_EQUAL_CONSTRAINTS(restrictedAlpha, restrictedCharlie);
    
    /* cross-type tests */
    
    NSArray *constraints = @[
        requiredAlpha,
        conditionallyRequiredAlpha,
        representativeRequiredAlpha,
        mutexedAlpha,
        restrictedAlpha
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

@end
