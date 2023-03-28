//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CLKArgumentManifestConstraint.h"

#define SET(...) [[NSOrderedSet alloc] initWithObjects:__VA_ARGS__, nil]

@interface Test_CLKArgumentManifestConstraint : XCTestCase

- (NSArray<CLKArgumentManifestConstraint *> *)constraintMatrix;

@end

@implementation Test_CLKArgumentManifestConstraint

- (NSArray<CLKArgumentManifestConstraint *> *)constraintMatrix
{
    NSArray *bands = @[
        [NSNull null],
        @[],
        @[ @"band_A_0" ],
        @[ @"band_B_0", @"band_B_1" ],
    ];
    
    NSArray *significants = @[
        [NSNull null],
        @"significant_A",
        @"significant_B",
    ];
    
    NSArray *predicates = @[
        [NSNull null],
        @"predicating_A",
        @"predicating_B",
    ];
    
    #define IS_NSNULL(obj) (obj == [NSNull null])
    NSMutableArray<CLKArgumentManifestConstraint *> *constraints = [[NSMutableArray alloc] init];
    for (id band_ in bands) {
        NSOrderedSet *bandSet = (IS_NSNULL(band_) ? nil : [NSOrderedSet orderedSetWithArray:band_]);
        for (id sig_ in significants) {
            NSString *sig = (IS_NSNULL(sig_) ? nil : sig_);
            for (id pred_ in predicates) {
                NSString *pred = (IS_NSNULL(pred_) ? nil : pred_);
                CLKArgumentManifestConstraint *a = [[CLKArgumentManifestConstraint alloc] initWithType:CLKConstraintTypeRequired bandedOptions:bandSet significantOption:sig predicatingOption:pred];
                CLKArgumentManifestConstraint *b = [[CLKArgumentManifestConstraint alloc] initWithType:CLKConstraintTypeAnyRequired bandedOptions:bandSet significantOption:sig predicatingOption:pred];
                CLKArgumentManifestConstraint *c = [[CLKArgumentManifestConstraint alloc] initWithType:CLKConstraintTypeMutuallyExclusive bandedOptions:bandSet significantOption:sig predicatingOption:pred];
                CLKArgumentManifestConstraint *d = [[CLKArgumentManifestConstraint alloc] initWithType:CLKConstraintTypeStandalone bandedOptions:bandSet significantOption:sig predicatingOption:pred];
                CLKArgumentManifestConstraint *e = [[CLKArgumentManifestConstraint alloc] initWithType:CLKConstraintTypeOccurrencesLimited bandedOptions:bandSet significantOption:sig predicatingOption:pred];
                [constraints addObject:a];
                [constraints addObject:b];
                [constraints addObject:c];
                [constraints addObject:d];
                [constraints addObject:e];
            }
        }
    }
    
    return constraints;
}

#pragma mark -

- (void)testDescription
{
    CLKArgumentManifestConstraint *constraint = [[CLKArgumentManifestConstraint alloc] initWithType:CLKConstraintTypeRequired bandedOptions:nil significantOption:@"flarn" predicatingOption:nil];
    NSString *expectation = [NSString stringWithFormat:@"<CLKArgumentManifestConstraint: %p> { required | banded: (nil) | significant: flarn | predicating: nil }", constraint];
    XCTAssertEqualObjects(constraint.description, expectation);
    
    constraint = [[CLKArgumentManifestConstraint alloc] initWithType:CLKConstraintTypeAnyRequired bandedOptions:SET(@"station") significantOption:nil predicatingOption:@"flarn"];
    expectation = [NSString stringWithFormat:@"<CLKArgumentManifestConstraint: %p> { any-required | banded: station | significant: nil | predicating: flarn }", constraint];
    XCTAssertEqualObjects(constraint.description, expectation);
    
    constraint = [[CLKArgumentManifestConstraint alloc] initWithType:CLKConstraintTypeAnyRequired bandedOptions:SET(@"acme", @"station") significantOption:@"barf" predicatingOption:@"flarn"];
    expectation = [NSString stringWithFormat:@"<CLKArgumentManifestConstraint: %p> { any-required | banded: acme, station | significant: barf | predicating: flarn }", constraint];
    XCTAssertEqualObjects(constraint.description, expectation);
    
    constraint = [[CLKArgumentManifestConstraint alloc] initWithType:CLKConstraintTypeMutuallyExclusive bandedOptions:SET(@"acme", @"station", @"spline") significantOption:nil predicatingOption:nil];
    expectation = [NSString stringWithFormat:@"<CLKArgumentManifestConstraint: %p> { mutex | banded: acme, station, spline | significant: nil | predicating: nil }", constraint];
    XCTAssertEqualObjects(constraint.description, expectation);
    
    constraint = [[CLKArgumentManifestConstraint alloc] initWithType:CLKConstraintTypeStandalone bandedOptions:nil significantOption:@"flarn" predicatingOption:nil];
    expectation = [NSString stringWithFormat:@"<CLKArgumentManifestConstraint: %p> { standalone | banded: (nil) | significant: flarn | predicating: nil }", constraint];
    XCTAssertEqualObjects(constraint.description, expectation);
    
    constraint = [[CLKArgumentManifestConstraint alloc] initWithType:CLKConstraintTypeOccurrencesLimited bandedOptions:nil significantOption:@"flarn" predicatingOption:nil];
    expectation = [NSString stringWithFormat:@"<CLKArgumentManifestConstraint: %p> { limit | banded: (nil) | significant: flarn | predicating: nil }", constraint];
    XCTAssertEqualObjects(constraint.description, expectation);
    
    /* these aren't really valid constraints but being able to see the debug description is useful */
    
    constraint = [[CLKArgumentManifestConstraint alloc] initWithType:CLKConstraintTypeOccurrencesLimited bandedOptions:nil significantOption:nil predicatingOption:@"flarn"];
    expectation = [NSString stringWithFormat:@"<CLKArgumentManifestConstraint: %p> { limit | banded: (nil) | significant: nil | predicating: flarn }", constraint];
    XCTAssertEqualObjects(constraint.description, expectation);
    
    constraint = [[CLKArgumentManifestConstraint alloc] initWithType:CLKConstraintTypeOccurrencesLimited bandedOptions:nil significantOption:nil predicatingOption:nil];
    expectation = [NSString stringWithFormat:@"<CLKArgumentManifestConstraint: %p> { limit | banded: (nil) | significant: nil | predicating: nil }", constraint];
    XCTAssertEqualObjects(constraint.description, expectation);
}

- (void)testEquality
{
    NSArray<CLKArgumentManifestConstraint *> *constraints = [self constraintMatrix];
    NSArray<CLKArgumentManifestConstraint *> *constraintClones = [self constraintMatrix];
    NSUInteger count = constraints.count;
    
    for (NSUInteger i = 0 ; i < count ; i++) {
        CLKArgumentManifestConstraint *constraint = constraints[i];
        CLKArgumentManifestConstraint *clone = constraintClones[i];
        XCTAssertEqualObjects(constraint, clone);
        XCTAssertEqual(constraint.hash, clone.hash);
    }
    
    // check each option against each option that succeeds it in the list.
    // when we're done, we will have exhausted the comparison space.
    for (NSUInteger i = 0 ; i < count ; i++) {
        CLKArgumentManifestConstraint *alpha = constraints[i];
        for (NSUInteger r = i + 1 ; r < count ; r++) {
            CLKArgumentManifestConstraint *bravo = constraints[r];
            XCTAssertNotEqualObjects(alpha, bravo);
        }
    }
    
    /* misc */
    
    CLKArgumentManifestConstraint *constraint = [[CLKArgumentManifestConstraint alloc] initWithType:CLKConstraintTypeRequired bandedOptions:nil significantOption:@"canary" predicatingOption:nil];
    XCTAssertFalse([constraint isEqual:nil]);
    XCTAssertNotEqualObjects(constraint, @"not a constraint");
}

- (void)testCollectionSupport_set
{
    NSArray<CLKArgumentManifestConstraint *> *constraints = [self constraintMatrix];
    NSArray<CLKArgumentManifestConstraint *> *constraintClones = [self constraintMatrix];
    
    NSSet *expectedSet = [NSSet setWithArray:constraints];
    NSArray *redundantList = [constraints arrayByAddingObjectsFromArray:constraintClones];
    NSSet *deduplicatedSet = [NSSet setWithArray:redundantList];
    XCTAssertEqualObjects(deduplicatedSet, expectedSet);
    
    for (NSUInteger i = 0 ; i < constraints.count ; i++) {
        CLKArgumentManifestConstraint *constraint = constraints[i];
        CLKArgumentManifestConstraint *clone = constraintClones[i];
        XCTAssertTrue([deduplicatedSet containsObject:constraint]);
        XCTAssertTrue([deduplicatedSet containsObject:clone]);
    }
}

@end
