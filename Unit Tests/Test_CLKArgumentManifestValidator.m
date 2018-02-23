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
#import "CLKOptionRegistry.h"
#import "ConstraintValidationSpec.h"
#import "NSError+CLKAdditions.h"
#import "XCTestCase+CLKAdditions.h"


NS_ASSUME_NONNULL_BEGIN

@interface Test_CLKArgumentManifestValidator : XCTestCase

- (void)verifyValidationPassForConstraint:(CLKArgumentManifestConstraint *)constraint usingValidator:(CLKArgumentManifestValidator *)validator;
- (void)verifyValidationFailureForConstraint:(CLKArgumentManifestConstraint *)constraint usingValidator:(CLKArgumentManifestValidator *)validator code:(NSUInteger)code description:(NSString *)description;
- (void)evaluateSpec:(ConstraintValidationSpec *)spec usingValidator:(CLKArgumentManifestValidator *)validator;

@end

NS_ASSUME_NONNULL_END


@implementation Test_CLKArgumentManifestValidator

- (void)verifyValidationPassForConstraint:(CLKArgumentManifestConstraint *)constraint usingValidator:(CLKArgumentManifestValidator *)validator
{
    ConstraintValidationSpec *spec = [ConstraintValidationSpec specWithConstraints:@[ constraint ] errors:nil];
    [self evaluateSpec:spec usingValidator:validator];
}

- (void)verifyValidationFailureForConstraint:(CLKArgumentManifestConstraint *)constraint usingValidator:(CLKArgumentManifestValidator *)validator code:(NSUInteger)code description:(NSString *)description
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
    CLKOptionRegistry *registry = [CLKOptionRegistry registryWithOptions:@[]];
    CLKArgumentManifest *manifest = [[[CLKArgumentManifest alloc] initWithOptionRegistry:registry] autorelease];
    CLKArgumentManifestValidator *validator = [[[CLKArgumentManifestValidator alloc] initWithManifest:manifest] autorelease];
    XCTAssertNotNil(validator);
    XCTAssertEqual(validator.manifest, manifest);
    
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
    [self verifyValidationPassForConstraint:constraint usingValidator:validator];
    
    constraint = [CLKArgumentManifestConstraint constraintForRequiredOption:@"barf"];
    [self verifyValidationFailureForConstraint:constraint usingValidator:validator code:CLKErrorRequiredOptionNotProvided description:@"--barf: required option not provided"];
    [self verifyValidationFailureForConstraint:constraint usingValidator:emptyValidator code:CLKErrorRequiredOptionNotProvided description:@"--barf: required option not provided"];
}

- (void)testValidateConstraint_conditionallyRequired
{
    CLKOption *barf = [CLKOption parameterOptionWithName:@"barf" flag:@"b"];
    CLKOption *flarn = [CLKOption parameterOptionWithName:@"flarn" flag:@"f"];
    CLKOption *quone = [CLKOption optionWithName:@"quone" flag:@"q"];
    
    NSDictionary *switchOptions = @{
        quone : @(1)
    };
    
    NSDictionary *parameterOptions = @{
        flarn : @[ @"confound" ],
        barf : @[ @"delivery" ]
    };
    
    CLKArgumentManifestValidator *validator = [self validatorWithSwitchOptions:switchOptions parameterOptions:parameterOptions];
    CLKArgumentManifestValidator *emptyValidator = [self validatorWithSwitchOptions:nil parameterOptions:nil];
    
    CLKArgumentManifestConstraint *constraint = [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"barf" associatedOption:@"flarn"];
    [self verifyValidationPassForConstraint:constraint usingValidator:validator];
    
    constraint = [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"barf" associatedOption:@"quone"];
    [self verifyValidationPassForConstraint:constraint usingValidator:validator];
    
    constraint = [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"xyzzy" associatedOption:@"quone"];
    [self verifyValidationFailureForConstraint:constraint usingValidator:validator code:CLKErrorRequiredOptionNotProvided description:@"--xyzzy is required when using --quone"];
    
    constraint = [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"quone" associatedOption:@"xyzzy"];
    [self verifyValidationPassForConstraint:constraint usingValidator:validator];
    [self verifyValidationPassForConstraint:constraint usingValidator:emptyValidator];
    
    // neither present in the manifest
    constraint = [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"ack" associatedOption:@"syn"];
    [self verifyValidationPassForConstraint:constraint usingValidator:validator];
    [self verifyValidationPassForConstraint:constraint usingValidator:emptyValidator];
}

- (void)testValidateConstraint_occurrencesLimited
{
    CLKOption *barf = [CLKOption parameterOptionWithName:@"barf" flag:@"b"];
    CLKOption *flarn = [CLKOption parameterOptionWithName:@"flarn" flag:@"f"];
    CLKOption *quone = [CLKOption optionWithName:@"quone" flag:@"q"];
    CLKOption *xyzzy = [CLKOption optionWithName:@"xyzzy" flag:@"x"];
    
    NSDictionary *switchOptions = @{
        quone : @(1),
        xyzzy : @(2)
    };
    
    NSDictionary *parameterOptions = @{
        barf : @[ @"thrud" ],
        flarn : @[ @"confound", @"delivery" ]
    };
    
    CLKArgumentManifestValidator *validator = [self validatorWithSwitchOptions:switchOptions parameterOptions:parameterOptions];
    CLKArgumentManifestValidator *emptyValidator = [self validatorWithSwitchOptions:nil parameterOptions:nil];
    
    CLKArgumentManifestConstraint *constraint = [CLKArgumentManifestConstraint constraintLimitingOccurrencesForOption:@"barf"];
    [self verifyValidationPassForConstraint:constraint usingValidator:validator];

    constraint = [CLKArgumentManifestConstraint constraintLimitingOccurrencesForOption:@"flarn"];
    [self verifyValidationFailureForConstraint:constraint usingValidator:validator code:CLKErrorTooManyOccurrencesOfOption description:@"--flarn may not be provided more than once"];
    
    constraint = [CLKArgumentManifestConstraint constraintLimitingOccurrencesForOption:@"quone"];
    [self verifyValidationPassForConstraint:constraint usingValidator:validator];
    
    constraint = [CLKArgumentManifestConstraint constraintLimitingOccurrencesForOption:@"xyzzy"];
    [self verifyValidationFailureForConstraint:constraint usingValidator:validator code:CLKErrorTooManyOccurrencesOfOption description:@"--xyzzy may not be provided more than once"];
    
    // not present in the manifest
    constraint = [CLKArgumentManifestConstraint constraintLimitingOccurrencesForOption:@"aeon"];
    [self verifyValidationPassForConstraint:constraint usingValidator:validator];
    [self verifyValidationPassForConstraint:constraint usingValidator:emptyValidator];
}

- (void)testValidateConstraint_representativeRequired
{
    CLKOption *barf = [CLKOption parameterOptionWithName:@"barf" flag:@"b"];
    CLKOption *flarn = [CLKOption parameterOptionWithName:@"flarn" flag:@"f"];
    CLKOption *quone = [CLKOption optionWithName:@"quone" flag:@"q"];
    
    NSDictionary *switchOptions = @{
        quone : @(1)
    };
    
    NSDictionary *parameterOptions = @{
        barf : @[ @"xyzzy" ],
        flarn : @[ @"confound", @"delivery" ]
    };
    
    CLKArgumentManifestValidator *validator = [self validatorWithSwitchOptions:switchOptions parameterOptions:parameterOptions];
    CLKArgumentManifestValidator *emptyValidator = [self validatorWithSwitchOptions:nil parameterOptions:nil];
    
    CLKArgumentManifestConstraint *constraint = [CLKArgumentManifestConstraint constraintRequiringRepresentativeForOptions:@[ @"quone", @"flarn" ]];
    [self verifyValidationPassForConstraint:constraint usingValidator:validator];
    
    constraint = [CLKArgumentManifestConstraint constraintRequiringRepresentativeForOptions:@[ @"barf", @"flarn" ]];
    [self verifyValidationPassForConstraint:constraint usingValidator:validator];
    
    constraint = [CLKArgumentManifestConstraint constraintRequiringRepresentativeForOptions:@[ @"quone", @"barf", @"flarn" ]];
    [self verifyValidationPassForConstraint:constraint usingValidator:validator];
    
    constraint = [CLKArgumentManifestConstraint constraintRequiringRepresentativeForOptions:@[ @"quone", @"syn" ]];
    [self verifyValidationPassForConstraint:constraint usingValidator:validator];
    
    constraint = [CLKArgumentManifestConstraint constraintRequiringRepresentativeForOptions:@[ @"barf", @"syn" ]];
    [self verifyValidationPassForConstraint:constraint usingValidator:validator];
    
    constraint = [CLKArgumentManifestConstraint constraintRequiringRepresentativeForOptions:@[ @"syn", @"ack" ]];
    [self verifyValidationFailureForConstraint:constraint usingValidator:validator code:CLKErrorRequiredOptionNotProvided description:@"one or more of the following options must be provided: --syn --ack"];
    [self verifyValidationFailureForConstraint:constraint usingValidator:emptyValidator code:CLKErrorRequiredOptionNotProvided description:@"one or more of the following options must be provided: --syn --ack"];
    
    constraint = [CLKArgumentManifestConstraint constraintRequiringRepresentativeForOptions:@[ @"syn", @"ack", @"what" ]];
    [self verifyValidationFailureForConstraint:constraint usingValidator:validator code:CLKErrorRequiredOptionNotProvided description:@"one or more of the following options must be provided: --syn --ack --what"];
    [self verifyValidationFailureForConstraint:constraint usingValidator:emptyValidator code:CLKErrorRequiredOptionNotProvided description:@"one or more of the following options must be provided: --syn --ack --what"];
}

- (void)testValidateConstraint_mutuallyExclusive
{
    CLKOption *barf = [CLKOption parameterOptionWithName:@"barf" flag:@"b"];
    CLKOption *flarn = [CLKOption parameterOptionWithName:@"flarn" flag:@"f"];
    CLKOption *quone = [CLKOption optionWithName:@"quone" flag:@"q"];
    
    NSDictionary *switchOptions = @{
        quone : @(1)
    };
    
    NSDictionary *parameterOptions = @{
        barf : @[ @"xyzzy" ],
        flarn : @[ @"confound", @"delivery" ]
    };
    
    CLKArgumentManifestValidator *validator = [self validatorWithSwitchOptions:switchOptions parameterOptions:parameterOptions];
    CLKArgumentManifestValidator *emptyValidator = [self validatorWithSwitchOptions:nil parameterOptions:nil];
    
    CLKArgumentManifestConstraint *constraint = [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"syn", @"ack" ]];
    [self verifyValidationPassForConstraint:constraint usingValidator:validator];
    [self verifyValidationPassForConstraint:constraint usingValidator:emptyValidator];
    
    constraint = [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"syn", @"ack", @"what" ]];
    [self verifyValidationPassForConstraint:constraint usingValidator:validator];
    [self verifyValidationPassForConstraint:constraint usingValidator:emptyValidator];
    
    constraint = [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"quone", @"xyzzy" ]];
    [self verifyValidationPassForConstraint:constraint usingValidator:validator];
    [self verifyValidationPassForConstraint:constraint usingValidator:emptyValidator];
    
    constraint = [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"barf", @"xyzzy" ]];
    [self verifyValidationPassForConstraint:constraint usingValidator:validator];
    [self verifyValidationPassForConstraint:constraint usingValidator:emptyValidator];
    
    constraint = [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"quone", @"barf" ]];
    [self verifyValidationFailureForConstraint:constraint usingValidator:validator code:CLKErrorMutuallyExclusiveOptionsPresent description:@"--quone --barf: mutually exclusive options encountered"];
    
    constraint = [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"quone", @"flarn" ]];
    [self verifyValidationFailureForConstraint:constraint usingValidator:validator code:CLKErrorMutuallyExclusiveOptionsPresent description:@"--quone --flarn: mutually exclusive options encountered"];
    
    constraint = [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"barf", @"flarn" ]];
    [self verifyValidationFailureForConstraint:constraint usingValidator:validator code:CLKErrorMutuallyExclusiveOptionsPresent description:@"--barf --flarn: mutually exclusive options encountered"];
    
    constraint = [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"quone", @"barf", @"flarn" ]];
    [self verifyValidationFailureForConstraint:constraint usingValidator:validator code:CLKErrorMutuallyExclusiveOptionsPresent description:@"--quone --barf --flarn: mutually exclusive options encountered"];
    
    constraint = [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"barf", @"flarn", @"xyzzy" ]];
    [self verifyValidationFailureForConstraint:constraint usingValidator:validator code:CLKErrorMutuallyExclusiveOptionsPresent description:@"--barf --flarn: mutually exclusive options encountered"];
}

- (void)testMultipleConstraints
{
    CLKOption *thrud = [CLKOption parameterOptionWithName:@"thrud" flag:nil];
    CLKOption *thrud_alt = [CLKOption optionWithName:@"thrud_alt" flag:nil];
    CLKOption *ack = [CLKOption parameterOptionWithName:@"ack" flag:nil];
    CLKOption *ack_alt = [CLKOption optionWithName:@"ack_alt" flag:nil];
    CLKOption *confound = [CLKOption parameterOptionWithName:@"confound" flag:nil];
    CLKOption *confound_alt = [CLKOption parameterOptionWithName:@"confound_alt" flag:nil];
    CLKOption *delivery = [CLKOption optionWithName:@"delivery" flag:nil];
    CLKOption *delivery_alt = [CLKOption optionWithName:@"delivery_alt" flag:nil];
    CLKOption *acme = [CLKOption optionWithName:@"acme" flag:nil];
    
    NSDictionary<CLKOption *, NSNumber *> *switchOptions = @{
        thrud_alt : @(2),
        ack_alt : @(1),
        delivery : @(7),
        delivery_alt : @(10),
        acme : @(7)
    };
    
    NSDictionary<CLKOption *, NSArray *> *parameterOptions = @{
        thrud : @[ @"#", @"#"],
        ack : @[ @"!" ],
        confound : @[ @"?" ],
        confound_alt : @[ @"?" ]
    };
    
    NSArray<CLKArgumentManifestConstraint *> *constraints = @[
        [CLKArgumentManifestConstraint constraintForRequiredOption:@"flarn"],
        [CLKArgumentManifestConstraint constraintLimitingOccurrencesForOption:@"thrud_alt"],
        [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"syn" associatedOption:@"ack"],
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"confound_alt", @"delivery_alt" ]],
        [CLKArgumentManifestConstraint constraintRequiringRepresentativeForOptions:@[ @"quone", @"xyzzy" ]],
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"acme", @"station" ]], // passing constraint, no associated error
        [CLKArgumentManifestConstraint constraintRequiringRepresentativeForOptions:@[ @"quone_alt", @"xyzzy_alt" ]],
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"confound", @"delivery" ]],
        [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"syn_alt" associatedOption:@"ack_alt"],
        [CLKArgumentManifestConstraint constraintLimitingOccurrencesForOption:@"thrud"],
        [CLKArgumentManifestConstraint constraintForRequiredOption:@"flarn_alt"]
    ];
    
    // verify redundant constraints are deduplicated
    constraints = [constraints arrayByAddingObjectsFromArray:constraints];
    
    NSArray<NSError *> *errors = @[
        [NSError clk_CLKErrorWithCode:CLKErrorRequiredOptionNotProvided description:@"--flarn: required option not provided"],
        [NSError clk_CLKErrorWithCode:CLKErrorTooManyOccurrencesOfOption description:@"--thrud_alt may not be provided more than once"],
        [NSError clk_CLKErrorWithCode:CLKErrorRequiredOptionNotProvided description:@"--syn is required when using --ack"],
        [NSError clk_CLKErrorWithCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--confound_alt --delivery_alt: mutually exclusive options encountered"],
        [NSError clk_CLKErrorWithCode:CLKErrorRequiredOptionNotProvided description:@"one or more of the following options must be provided: --quone --xyzzy"],
        // no error for acme/station constraint
        [NSError clk_CLKErrorWithCode:CLKErrorRequiredOptionNotProvided description:@"one or more of the following options must be provided: --quone_alt --xyzzy_alt"],
        [NSError clk_CLKErrorWithCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--confound --delivery: mutually exclusive options encountered"],
        [NSError clk_CLKErrorWithCode:CLKErrorRequiredOptionNotProvided description:@"--syn_alt is required when using --ack_alt"],
        [NSError clk_CLKErrorWithCode:CLKErrorTooManyOccurrencesOfOption description:@"--thrud may not be provided more than once"],
        [NSError clk_CLKErrorWithCode:CLKErrorRequiredOptionNotProvided description:@"--flarn_alt: required option not provided"],
    ];
    
    CLKArgumentManifestValidator *validator = [self validatorWithSwitchOptions:switchOptions parameterOptions:parameterOptions];
    ConstraintValidationSpec *spec = [ConstraintValidationSpec specWithConstraints:constraints errors:errors];
    [self evaluateSpec:spec usingValidator:validator];
}

@end
