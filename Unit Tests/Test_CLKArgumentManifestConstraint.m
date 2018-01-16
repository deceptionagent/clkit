//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CLKArgumentManifestConstraint.h"


@interface Test_CLKArgumentManifestConstraint : XCTestCase

@end


@implementation Test_CLKArgumentManifestConstraint

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
    CLKArgumentManifestConstraint *requiredAlpha = [CLKArgumentManifestConstraint constraintForRequiredOption:@"flarn"];
    CLKArgumentManifestConstraint *requiredBravo = [CLKArgumentManifestConstraint constraintForRequiredOption:@"flarn"];
    CLKArgumentManifestConstraint *requiredCharlie = [CLKArgumentManifestConstraint constraintForRequiredOption:@"barf"];
    XCTAssertTrue([requiredAlpha isEqual:requiredBravo]);
    XCTAssertFalse([requiredAlpha isEqual:requiredCharlie]);
    
    CLKArgumentManifestConstraint *conditionallyRequiredAlpha = [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"flarn" associatedOption:@"barf"];
    CLKArgumentManifestConstraint *conditionallyRequiredBravo = [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"flarn" associatedOption:@"barf"];
    CLKArgumentManifestConstraint *conditionallyRequiredCharlie = [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"quone" associatedOption:@"barf"];
    CLKArgumentManifestConstraint *conditionallyRequiredDelta = [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"quone" associatedOption:@"xyzzy"];
    XCTAssertTrue([conditionallyRequiredAlpha isEqual:conditionallyRequiredBravo]);
    XCTAssertFalse([conditionallyRequiredAlpha isEqual:conditionallyRequiredCharlie]);
    XCTAssertFalse([conditionallyRequiredCharlie isEqual:conditionallyRequiredDelta]);
    
    CLKArgumentManifestConstraint *representativeRequiredAlpha = [CLKArgumentManifestConstraint constraintRequiringRepresentativeForOptions:@[ @"flarn", @"barf" ]];
    CLKArgumentManifestConstraint *representativeRequiredBravo = [CLKArgumentManifestConstraint constraintRequiringRepresentativeForOptions:@[ @"flarn", @"barf" ]];
    CLKArgumentManifestConstraint *representativeRequiredCharlie = [CLKArgumentManifestConstraint constraintRequiringRepresentativeForOptions:@[ @"flarn", @"quone" ]];
    XCTAssertTrue([representativeRequiredAlpha isEqual:representativeRequiredBravo]);
    XCTAssertFalse([representativeRequiredAlpha isEqual:representativeRequiredCharlie]);
    
    CLKArgumentManifestConstraint *mutexedAlpha = [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"flarn", @"barf" ]];
    CLKArgumentManifestConstraint *mutexedBravo = [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"flarn", @"barf" ]];
    CLKArgumentManifestConstraint *mutexedCharlie = [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"flarn", @"quone" ]];
    XCTAssertTrue([mutexedAlpha isEqual:mutexedBravo]);
    XCTAssertFalse([mutexedAlpha isEqual:mutexedCharlie]);
    
    CLKArgumentManifestConstraint *restrictedAlpha = [CLKArgumentManifestConstraint constraintRestrictingOccurrencesForOption:@"flarn"];
    CLKArgumentManifestConstraint *restrictedBravo = [CLKArgumentManifestConstraint constraintRestrictingOccurrencesForOption:@"flarn"];
    CLKArgumentManifestConstraint *restrictedCharlie = [CLKArgumentManifestConstraint constraintRestrictingOccurrencesForOption:@"barf"];
    XCTAssertTrue([restrictedAlpha isEqual:restrictedBravo]);
    XCTAssertFalse([restrictedAlpha isEqual:restrictedCharlie]);
    
    /* cross-type tests */
    
    NSSet *constraints = [NSSet setWithArray:@[
        requiredAlpha,
        conditionallyRequiredAlpha,
        representativeRequiredAlpha,
        mutexedAlpha,
        restrictedAlpha
    ]];
    
    for (CLKArgumentManifestConstraint *constraint in constraints) {
        NSMutableSet *otherConstraints = [[constraints mutableCopy] autorelease];
        [otherConstraints removeObject:constraint];
        for (CLKArgumentManifestConstraint *otherConstraint in otherConstraints) {
            XCTAssertNotEqualObjects(constraint, otherConstraint);
        }
    }
}

@end
