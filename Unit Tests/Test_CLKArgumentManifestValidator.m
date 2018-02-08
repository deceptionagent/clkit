//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CLKArgumentManifest.h"
#import "CLKArgumentManifest_Private.h"
#import "CLKArgumentManifestConstraint.h"
#import "CLKArgumentManifestValidator.h"
#import "CLKError.h"
#import "CLKOption.h"
#import "ConstraintValidationSpec.h"
#import "NSError+CLKAdditions.h"
#import "XCTestCase+CLKAdditions.h"


NS_ASSUME_NONNULL_BEGIN

@interface Test_CLKArgumentManifestValidator : XCTestCase

- (void)verifyValidationPassForConstraint:(CLKArgumentManifestConstraint *)constraint validator:(CLKArgumentManifestValidator *)validator;
- (void)verifyValidationFailureForConstraint:(CLKArgumentManifestConstraint *)constraint validator:(CLKArgumentManifestValidator *)validator code:(NSUInteger)code description:(NSString *)description;
- (void)evaluateSpec:(ConstraintValidationSpec *)spec usingValidator:(CLKArgumentManifestValidator *)validator;

@end

NS_ASSUME_NONNULL_END


@implementation Test_CLKArgumentManifestValidator

- (void)verifyValidationPassForConstraint:(CLKArgumentManifestConstraint *)constraint validator:(CLKArgumentManifestValidator *)validator
{
    ConstraintValidationSpec *spec = [ConstraintValidationSpec specWithConstraints:@[ constraint ] errors:nil];
    [self evaluateSpec:spec usingValidator:validator];
}

- (void)verifyValidationFailureForConstraint:(CLKArgumentManifestConstraint *)constraint validator:(CLKArgumentManifestValidator *)validator code:(NSUInteger)code description:(NSString *)description
{
    NSError *error = [NSError clk_CLKErrorWithCode:code description:@"%@", description];
    ConstraintValidationSpec *spec = [ConstraintValidationSpec specWithConstraints:@[ constraint ] errors:@[ error ]];
    [self evaluateSpec:spec usingValidator:validator];
}

- (void)evaluateSpec:(ConstraintValidationSpec *)spec usingValidator:(CLKArgumentManifestValidator *)validator
{
    NSMutableArray<NSError *> *errors = [NSMutableArray array];
    [validator validateConstraints:spec.constraints issueHandler:^(NSError *error) {
        [errors addObject:error];
    }];
    
    if (spec.shouldPass) {
        XCTAssertEqual(errors.count, 0, @"unexpected validation failure for constraints:\n%@\n\n*** errors:\n%@\n\n*** manifest:\n%@\n", spec.constraints, errors, validator.manifest.debugDescription);
    } else {
        XCTAssertEqualObjects(spec.errors, errors, @"unsatisfied error match for constraints:\n%@\n\n*** manifest:\n%@\n", spec.constraints, validator.manifest.debugDescription);
    }
}

#pragma mark -

- (void)testInit
{
    CLKArgumentManifest *manifest = [[[CLKArgumentManifest alloc] init] autorelease];
    CLKArgumentManifestValidator *validator = [[[CLKArgumentManifestValidator alloc] initWithManifest:manifest] autorelease];
    XCTAssertNotNil(validator);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    XCTAssertThrows([[[CLKArgumentManifestValidator alloc] initWithManifest:nil] autorelease]);
#pragma clang diagnostic pop
}

- (void)testValidateConstraint_required
{
    CLKOption *flarn = [CLKOption parameterOptionWithName:@"flarn" flag:@"f" required:YES];
    CLKArgumentManifestValidator *validator = [self validatorWithSwitchOptions:nil parameterOptions:@{ flarn : @[ @"quone" ] }];
    CLKArgumentManifestValidator *emptyValidator = [self validatorWithSwitchOptions:nil parameterOptions:nil];
    
    CLKArgumentManifestConstraint *constraint = [CLKArgumentManifestConstraint constraintForRequiredOption:@"flarn"];
    [self verifyValidationPassForConstraint:constraint validator:validator];
    
    constraint = [CLKArgumentManifestConstraint constraintForRequiredOption:@"barf"];
    [self verifyValidationFailureForConstraint:constraint validator:validator code:CLKErrorRequiredOptionNotProvided description:@"--barf: required option not provided"];
    [self verifyValidationFailureForConstraint:constraint validator:emptyValidator code:CLKErrorRequiredOptionNotProvided description:@"--barf: required option not provided"];
}

- (void)testValidateConstraint_conditionallyRequired
{
    CLKOption *barf = [CLKOption parameterOptionWithName:@"barf" flag:@"b"];
    CLKOption *flarn = [CLKOption parameterOptionWithName:@"flarn" flag:@"f"];
    CLKOption *quone = [CLKOption optionWithName:@"quone" flag:@"q"];
    
    NSDictionary *switchContents = @{
        quone : @(1)
    };
    
    NSDictionary *parameterContents = @{
        flarn : @[ @"confound" ],
        barf : @[ @"delivery" ]
    };
    
    CLKArgumentManifestValidator *validator = [self validatorWithSwitchOptions:switchContents parameterOptions:parameterContents];
    CLKArgumentManifestValidator *emptyValidator = [self validatorWithSwitchOptions:nil parameterOptions:nil];
    
    CLKArgumentManifestConstraint *constraint = [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"barf" associatedOption:@"flarn"];
    [self verifyValidationPassForConstraint:constraint validator:validator];

    constraint = [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"barf" associatedOption:@"quone"];
    [self verifyValidationPassForConstraint:constraint validator:validator];
    
    constraint = [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"xyzzy" associatedOption:@"quone"];
    [self verifyValidationFailureForConstraint:constraint validator:validator code:CLKErrorRequiredOptionNotProvided description:@"--xyzzy is required when using --quone"];
    
    constraint = [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"quone" associatedOption:@"xyzzy"];
    [self verifyValidationPassForConstraint:constraint validator:validator];
    [self verifyValidationPassForConstraint:constraint validator:emptyValidator];
    
    // neither present in the manifest
    constraint = [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"ack" associatedOption:@"syn"];
    [self verifyValidationPassForConstraint:constraint validator:validator];
    [self verifyValidationPassForConstraint:constraint validator:emptyValidator];
}

- (void)testValidateConstraint_occurrencesRestricted
{
    CLKOption *barf = [CLKOption parameterOptionWithName:@"barf" flag:@"b"];
    CLKOption *flarn = [CLKOption parameterOptionWithName:@"flarn" flag:@"f"];
    CLKOption *quone = [CLKOption optionWithName:@"quone" flag:@"q"];
    CLKOption *xyzzy = [CLKOption optionWithName:@"xyzzy" flag:@"x"];
    
    NSDictionary *switchContents = @{
        quone : @(1),
        xyzzy : @(2)
    };
    
    NSDictionary *parameterContents = @{
        barf : @[ @"thrud" ],
        flarn : @[ @"confound", @"delivery" ]
    };
    
    CLKArgumentManifestValidator *validator = [self validatorWithSwitchOptions:switchContents parameterOptions:parameterContents];
    CLKArgumentManifestValidator *emptyValidator = [self validatorWithSwitchOptions:nil parameterOptions:nil];
    
    CLKArgumentManifestConstraint *constraint = [CLKArgumentManifestConstraint constraintRestrictingOccurrencesForOption:@"barf"];
    [self verifyValidationPassForConstraint:constraint validator:validator];

    constraint = [CLKArgumentManifestConstraint constraintRestrictingOccurrencesForOption:@"flarn"];
    [self verifyValidationFailureForConstraint:constraint validator:validator code:CLKErrorTooManyOccurrencesOfOption description:@"--flarn may not be provided more than once"];
    
    constraint = [CLKArgumentManifestConstraint constraintRestrictingOccurrencesForOption:@"quone"];
    [self verifyValidationPassForConstraint:constraint validator:validator];
    
    constraint = [CLKArgumentManifestConstraint constraintRestrictingOccurrencesForOption:@"xyzzy"];
    [self verifyValidationFailureForConstraint:constraint validator:validator code:CLKErrorTooManyOccurrencesOfOption description:@"--xyzzy may not be provided more than once"];
    
    // not present in the manifest
    constraint = [CLKArgumentManifestConstraint constraintRestrictingOccurrencesForOption:@"aeon"];
    [self verifyValidationPassForConstraint:constraint validator:validator];
    [self verifyValidationPassForConstraint:constraint validator:emptyValidator];
}

- (void)testValidateConstraint_representativeRequired
{
    CLKOption *barf = [CLKOption parameterOptionWithName:@"barf" flag:@"b"];
    CLKOption *flarn = [CLKOption parameterOptionWithName:@"flarn" flag:@"f"];
    CLKOption *quone = [CLKOption optionWithName:@"quone" flag:@"q"];
    
    NSDictionary *switchContents = @{
        quone : @(1)
    };
    
    NSDictionary *parameterContents = @{
        barf : @[ @"xyzzy" ],
        flarn : @[ @"confound", @"delivery" ]
    };
    
    CLKArgumentManifestValidator *validator = [self validatorWithSwitchOptions:switchContents parameterOptions:parameterContents];
    CLKArgumentManifestValidator *emptyValidator = [self validatorWithSwitchOptions:nil parameterOptions:nil];
    
    CLKArgumentManifestConstraint *constraint = [CLKArgumentManifestConstraint constraintRequiringRepresentativeForOptions:@[ @"quone", @"flarn" ]];
    [self verifyValidationPassForConstraint:constraint validator:validator];
    
    constraint = [CLKArgumentManifestConstraint constraintRequiringRepresentativeForOptions:@[ @"barf", @"flarn" ]];
    [self verifyValidationPassForConstraint:constraint validator:validator];
    
    constraint = [CLKArgumentManifestConstraint constraintRequiringRepresentativeForOptions:@[ @"quone", @"barf", @"flarn" ]];
    [self verifyValidationPassForConstraint:constraint validator:validator];
    
    constraint = [CLKArgumentManifestConstraint constraintRequiringRepresentativeForOptions:@[ @"quone", @"syn" ]];
    [self verifyValidationPassForConstraint:constraint validator:validator];
    
    constraint = [CLKArgumentManifestConstraint constraintRequiringRepresentativeForOptions:@[ @"barf", @"syn" ]];
    [self verifyValidationPassForConstraint:constraint validator:validator];
    
    constraint = [CLKArgumentManifestConstraint constraintRequiringRepresentativeForOptions:@[ @"syn", @"ack" ]];
    [self verifyValidationFailureForConstraint:constraint validator:validator code:CLKErrorRequiredOptionNotProvided description:@"one or more of the following options must be provided: --syn --ack"];
    [self verifyValidationFailureForConstraint:constraint validator:emptyValidator code:CLKErrorRequiredOptionNotProvided description:@"one or more of the following options must be provided: --syn --ack"];
    
    constraint = [CLKArgumentManifestConstraint constraintRequiringRepresentativeForOptions:@[ @"syn", @"ack", @"what" ]];
    [self verifyValidationFailureForConstraint:constraint validator:validator code:CLKErrorRequiredOptionNotProvided description:@"one or more of the following options must be provided: --syn --ack --what"];
    [self verifyValidationFailureForConstraint:constraint validator:emptyValidator code:CLKErrorRequiredOptionNotProvided description:@"one or more of the following options must be provided: --syn --ack --what"];
}

- (void)testValidateConstraint_mutuallyExclusive
{
    CLKOption *barf = [CLKOption parameterOptionWithName:@"barf" flag:@"b"];
    CLKOption *flarn = [CLKOption parameterOptionWithName:@"flarn" flag:@"f"];
    CLKOption *quone = [CLKOption optionWithName:@"quone" flag:@"q"];
    
    NSDictionary *switchContents = @{
        quone : @(1)
    };
    
    NSDictionary *parameterContents = @{
        barf : @[ @"xyzzy" ],
        flarn : @[ @"confound", @"delivery" ]
    };
    
    CLKArgumentManifestValidator *validator = [self validatorWithSwitchOptions:switchContents parameterOptions:parameterContents];
    CLKArgumentManifestValidator *emptyValidator = [self validatorWithSwitchOptions:nil parameterOptions:nil];
    
    CLKArgumentManifestConstraint *constraint = [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"syn", @"ack" ]];
    [self verifyValidationPassForConstraint:constraint validator:validator];
    [self verifyValidationPassForConstraint:constraint validator:emptyValidator];
    
    constraint = [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"syn", @"ack", @"what" ]];
    [self verifyValidationPassForConstraint:constraint validator:validator];
    [self verifyValidationPassForConstraint:constraint validator:emptyValidator];
    
    constraint = [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"quone", @"xyzzy" ]];
    [self verifyValidationPassForConstraint:constraint validator:validator];
    [self verifyValidationPassForConstraint:constraint validator:emptyValidator];
    
    constraint = [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"barf", @"xyzzy" ]];
    [self verifyValidationPassForConstraint:constraint validator:validator];
    [self verifyValidationPassForConstraint:constraint validator:emptyValidator];
    
    constraint = [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"quone", @"barf" ]];
    [self verifyValidationFailureForConstraint:constraint validator:validator code:CLKErrorMutuallyExclusiveOptionsPresent description:@"--quone --barf: mutually exclusive options encountered"];
    
    constraint = [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"quone", @"flarn" ]];
    [self verifyValidationFailureForConstraint:constraint validator:validator code:CLKErrorMutuallyExclusiveOptionsPresent description:@"--quone --flarn: mutually exclusive options encountered"];
    
    constraint = [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"barf", @"flarn" ]];
    [self verifyValidationFailureForConstraint:constraint validator:validator code:CLKErrorMutuallyExclusiveOptionsPresent description:@"--barf --flarn: mutually exclusive options encountered"];
    
    constraint = [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"quone", @"barf", @"flarn" ]];
    [self verifyValidationFailureForConstraint:constraint validator:validator code:CLKErrorMutuallyExclusiveOptionsPresent description:@"--quone --barf --flarn: mutually exclusive options encountered"];
    
    constraint = [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"barf", @"flarn", @"xyzzy" ]];
    [self verifyValidationFailureForConstraint:constraint validator:validator code:CLKErrorMutuallyExclusiveOptionsPresent description:@"--barf --flarn: mutually exclusive options encountered"];
}

#warning add multi-issue tests

@end
