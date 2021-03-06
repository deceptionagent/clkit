//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CLKArgumentIssue.h"
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

- (void)verifyValidationFailureForConstraint:(CLKArgumentManifestConstraint *)constraint
                              usingValidator:(CLKArgumentManifestValidator *)validator
                                        code:(CLKError)code
                              salientOptions:(NSArray<NSString *> *)salientOptions
                                 description:(NSString *)description;

- (void)evaluateSpec:(ConstraintValidationSpec *)spec usingValidator:(CLKArgumentManifestValidator *)validator;

@end

NS_ASSUME_NONNULL_END

@implementation Test_CLKArgumentManifestValidator

- (void)verifyValidationPassForConstraint:(CLKArgumentManifestConstraint *)constraint usingValidator:(CLKArgumentManifestValidator *)validator
{
    ConstraintValidationSpec *spec = [ConstraintValidationSpec specWithConstraints:@[ constraint ] issues:nil];
    [self evaluateSpec:spec usingValidator:validator];
}

- (void)verifyValidationFailureForConstraint:(CLKArgumentManifestConstraint *)constraint
                              usingValidator:(CLKArgumentManifestValidator *)validator
                                        code:(CLKError)code
                              salientOptions:(NSArray<NSString *> *)salientOptions
                                 description:(NSString *)description
{
    NSError *error = [NSError clk_CLKErrorWithCode:code description:@"%@", description];
    CLKArgumentIssue *issue = [CLKArgumentIssue issueWithError:error salientOptions:salientOptions];
    ConstraintValidationSpec *spec = [ConstraintValidationSpec specWithConstraints:@[ constraint ] issues:@[ issue ]];
    [self evaluateSpec:spec usingValidator:validator];
}

- (void)evaluateSpec:(ConstraintValidationSpec *)spec usingValidator:(CLKArgumentManifestValidator *)validator
{
    NSMutableArray<CLKArgumentIssue *> *issues = [NSMutableArray array];
    [validator validateConstraints:spec.constraints issueHandler:^(CLKArgumentIssue *issue) {
        [issues addObject:issue];
    }];
    
    if (spec.shouldPass) {
        XCTAssertEqual(issues.count, 0UL, @"unexpected validation failure for constraints:\n%@\n\n*** issues:\n%@\n\n*** manifest:\n%@\n", spec.constraints, issues, validator.manifest.debugDescription);
    } else {
        XCTAssertTrue([issues isEqualToArray:spec.issues], @"unsatisfied issues match: %@ is not equal to %@\nconstraints:\n%@\n\n*** manifest:\n%@\n", issues.debugDescription, spec.issues.debugDescription, spec.constraints, validator.manifest.debugDescription);
    }
}

#pragma mark -

- (void)testInit
{
    CLKOptionRegistry *registry = [CLKOptionRegistry registryWithOptions:@[]];
    CLKArgumentManifest *manifest = [[CLKArgumentManifest alloc] initWithOptionRegistry:registry];
    CLKArgumentManifestValidator *validator = [[CLKArgumentManifestValidator alloc] initWithManifest:manifest];
    XCTAssertNotNil(validator);
    XCTAssertEqual(validator.manifest, manifest);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    XCTAssertThrows([[CLKArgumentManifestValidator alloc] initWithManifest:nil]);
#pragma clang diagnostic pop
}

- (void)testValidateConstraint_required
{
    CLKOption *flarn = [CLKOption requiredParameterOptionWithName:@"flarn" flag:@"f"];
    CLKArgumentManifestValidator *validator = [self validatorWithSwitchOptions:nil parameterOptions:@{ flarn : @[ @"quone" ] }];
    
    CLKArgumentManifestConstraint *constraint = [CLKArgumentManifestConstraint constraintForRequiredOption:@"flarn"];
    [self verifyValidationPassForConstraint:constraint usingValidator:validator];
    
    CLKArgumentManifestValidator *emptyValidator = [self validatorWithSwitchOptions:nil parameterOptions:nil];
    constraint = [CLKArgumentManifestConstraint constraintForRequiredOption:@"barf"];
    [self verifyValidationFailureForConstraint:constraint usingValidator:validator code:CLKErrorRequiredOptionNotProvided salientOptions:@[ @"barf" ] description:@"--barf: required option not provided"];
    [self verifyValidationFailureForConstraint:constraint usingValidator:emptyValidator code:CLKErrorRequiredOptionNotProvided salientOptions:@[ @"barf" ] description:@"--barf: required option not provided"];
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
    
    CLKArgumentManifestConstraint *constraint = [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"barf" causalOption:@"flarn"];
    [self verifyValidationPassForConstraint:constraint usingValidator:validator];
    
    constraint = [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"barf" causalOption:@"quone"];
    [self verifyValidationPassForConstraint:constraint usingValidator:validator];
    
    constraint = [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"xyzzy" causalOption:@"quone"];
    [self verifyValidationFailureForConstraint:constraint usingValidator:validator code:CLKErrorRequiredOptionNotProvided salientOptions:@[ @"xyzzy" ] description:@"--xyzzy is required when using --quone"];
    
    constraint = [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"quone" causalOption:@"xyzzy"];
    [self verifyValidationPassForConstraint:constraint usingValidator:validator];
    [self verifyValidationPassForConstraint:constraint usingValidator:emptyValidator];
    
    // neither present in the manifest
    constraint = [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"ack" causalOption:@"syn"];
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
    [self verifyValidationFailureForConstraint:constraint usingValidator:validator code:CLKErrorTooManyOccurrencesOfOption salientOptions:@[ @"flarn" ] description:@"--flarn may not be provided more than once"];
    
    constraint = [CLKArgumentManifestConstraint constraintLimitingOccurrencesForOption:@"quone"];
    [self verifyValidationPassForConstraint:constraint usingValidator:validator];
    
    constraint = [CLKArgumentManifestConstraint constraintLimitingOccurrencesForOption:@"xyzzy"];
    [self verifyValidationFailureForConstraint:constraint usingValidator:validator code:CLKErrorTooManyOccurrencesOfOption salientOptions:@[ @"xyzzy" ] description:@"--xyzzy may not be provided more than once"];
    
    // not present in the manifest
    constraint = [CLKArgumentManifestConstraint constraintLimitingOccurrencesForOption:@"aeon"];
    [self verifyValidationPassForConstraint:constraint usingValidator:validator];
    [self verifyValidationPassForConstraint:constraint usingValidator:emptyValidator];
}

- (void)testValidateConstraint_representationRequired
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
    
    CLKArgumentManifestConstraint *constraint = [CLKArgumentManifestConstraint constraintRequiringRepresentationForOptions:@[ @"quone", @"flarn" ]];
    [self verifyValidationPassForConstraint:constraint usingValidator:validator];
    
    constraint = [CLKArgumentManifestConstraint constraintRequiringRepresentationForOptions:@[ @"barf", @"flarn" ]];
    [self verifyValidationPassForConstraint:constraint usingValidator:validator];
    
    constraint = [CLKArgumentManifestConstraint constraintRequiringRepresentationForOptions:@[ @"quone", @"barf", @"flarn" ]];
    [self verifyValidationPassForConstraint:constraint usingValidator:validator];
    
    constraint = [CLKArgumentManifestConstraint constraintRequiringRepresentationForOptions:@[ @"quone", @"syn" ]];
    [self verifyValidationPassForConstraint:constraint usingValidator:validator];
    
    constraint = [CLKArgumentManifestConstraint constraintRequiringRepresentationForOptions:@[ @"barf", @"syn" ]];
    [self verifyValidationPassForConstraint:constraint usingValidator:validator];
    
    constraint = [CLKArgumentManifestConstraint constraintRequiringRepresentationForOptions:@[ @"syn", @"ack" ]];
    [self verifyValidationFailureForConstraint:constraint usingValidator:validator code:CLKErrorRequiredOptionNotProvided salientOptions:@[ @"syn", @"ack" ] description:@"one or more of the following options must be provided: --syn --ack"];
    [self verifyValidationFailureForConstraint:constraint usingValidator:emptyValidator code:CLKErrorRequiredOptionNotProvided salientOptions:@[ @"syn", @"ack" ] description:@"one or more of the following options must be provided: --syn --ack"];
    
    constraint = [CLKArgumentManifestConstraint constraintRequiringRepresentationForOptions:@[ @"syn", @"ack", @"what" ]];
    [self verifyValidationFailureForConstraint:constraint usingValidator:validator code:CLKErrorRequiredOptionNotProvided salientOptions:@[ @"syn", @"ack", @"what" ] description:@"one or more of the following options must be provided: --syn --ack --what"];
    [self verifyValidationFailureForConstraint:constraint usingValidator:emptyValidator code:CLKErrorRequiredOptionNotProvided salientOptions:@[ @"syn", @"ack", @"what" ] description:@"one or more of the following options must be provided: --syn --ack --what"];
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
    [self verifyValidationFailureForConstraint:constraint usingValidator:validator code:CLKErrorMutuallyExclusiveOptionsPresent salientOptions:@[ @"quone", @"barf" ] description:@"--quone --barf: mutually exclusive options encountered"];
    
    constraint = [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"quone", @"flarn" ]];
    [self verifyValidationFailureForConstraint:constraint usingValidator:validator code:CLKErrorMutuallyExclusiveOptionsPresent salientOptions:@[ @"quone", @"flarn"] description:@"--quone --flarn: mutually exclusive options encountered"];
    
    constraint = [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"barf", @"flarn" ]];
    [self verifyValidationFailureForConstraint:constraint usingValidator:validator code:CLKErrorMutuallyExclusiveOptionsPresent salientOptions:@[ @"barf", @"flarn" ] description:@"--barf --flarn: mutually exclusive options encountered"];
    
    constraint = [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"quone", @"barf", @"flarn" ]];
    [self verifyValidationFailureForConstraint:constraint usingValidator:validator code:CLKErrorMutuallyExclusiveOptionsPresent salientOptions:@[ @"quone", @"barf", @"flarn" ] description:@"--quone --barf --flarn: mutually exclusive options encountered"];
    
    constraint = [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"barf", @"flarn", @"xyzzy" ]];
    [self verifyValidationFailureForConstraint:constraint usingValidator:validator code:CLKErrorMutuallyExclusiveOptionsPresent salientOptions:@[ @"barf", @"flarn" ] description:@"--barf --flarn: mutually exclusive options encountered"];
}

- (void)testValidateConstraint_standalone
{
    CLKOption *flarn = [CLKOption optionWithName:@"flarn" flag:@"f"];
    CLKOption *barf = [CLKOption optionWithName:@"barf" flag:@"b"];
    CLKOption *confound = [CLKOption optionWithName:@"confound" flag:@"c"];
    CLKOption *delivery = [CLKOption parameterOptionWithName:@"delivery" flag:@"d"];
    
    NSDictionary *switchOptions = @{
        flarn : @(1)
    };
    
    CLKArgumentManifestValidator *validator = [self validatorWithSwitchOptions:switchOptions parameterOptions:nil];
    CLKArgumentManifestConstraint *constraint = [CLKArgumentManifestConstraint constraintForStandaloneOption:@"flarn" allowingOptions:nil];
    [self verifyValidationPassForConstraint:constraint usingValidator:validator];
    
    constraint = [CLKArgumentManifestConstraint constraintForStandaloneOption:@"flarn" allowingOptions:@[]];
    [self verifyValidationPassForConstraint:constraint usingValidator:validator];
    
    switchOptions = @{
        flarn : @(1),
        barf : @(1)
    };
    
    NSDictionary *parameterOptions = @{
        delivery : @[ @"xyzzy" ]
    };
    
    validator = [self validatorWithSwitchOptions:switchOptions parameterOptions:parameterOptions];
    constraint = [CLKArgumentManifestConstraint constraintForStandaloneOption:@"flarn" allowingOptions:nil];
    [self verifyValidationFailureForConstraint:constraint usingValidator:validator code:CLKErrorMutuallyExclusiveOptionsPresent salientOptions:@[ @"flarn" ] description:@"--flarn may not be provided with other options"];
    
    validator = [self validatorWithSwitchOptions:switchOptions parameterOptions:parameterOptions];
    constraint = [CLKArgumentManifestConstraint constraintForStandaloneOption:@"flarn" allowingOptions:@[]];
    [self verifyValidationFailureForConstraint:constraint usingValidator:validator code:CLKErrorMutuallyExclusiveOptionsPresent salientOptions:@[ @"flarn" ] description:@"--flarn may not be provided with other options"];
    
    switchOptions = @{
        flarn : @(1),
        barf : @(1),
        confound : @(1),
    };
    
    validator = [self validatorWithSwitchOptions:switchOptions parameterOptions:parameterOptions];
    constraint = [CLKArgumentManifestConstraint constraintForStandaloneOption:@"flarn" allowingOptions:@[ @"barf" ]];
    [self verifyValidationFailureForConstraint:constraint usingValidator:validator code:CLKErrorMutuallyExclusiveOptionsPresent salientOptions:@[ @"flarn" ] description:@"--flarn may not be provided with options other than the following: --barf"];
    
    constraint = [CLKArgumentManifestConstraint constraintForStandaloneOption:@"flarn" allowingOptions:@[ @"barf", @"confound" ]];
    [self verifyValidationFailureForConstraint:constraint usingValidator:validator code:CLKErrorMutuallyExclusiveOptionsPresent salientOptions:@[ @"flarn" ] description:@"--flarn may not be provided with options other than the following: --barf --confound"];
    
    constraint = [CLKArgumentManifestConstraint constraintForStandaloneOption:@"flarn" allowingOptions:@[ @"barf", @"confound", @"delivery" ]];
    [self verifyValidationPassForConstraint:constraint usingValidator:validator];
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
        [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"syn" causalOption:@"ack"],
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"confound_alt", @"delivery_alt" ]],
        [CLKArgumentManifestConstraint constraintRequiringRepresentationForOptions:@[ @"quone", @"xyzzy" ]],
        [CLKArgumentManifestConstraint constraintForStandaloneOption:@"thrud" allowingOptions:nil],
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"acme", @"station" ]], // passing constraint, no associated error
        [CLKArgumentManifestConstraint constraintForStandaloneOption:@"thrud_alt" allowingOptions:nil],
        [CLKArgumentManifestConstraint constraintRequiringRepresentationForOptions:@[ @"quone_alt", @"xyzzy_alt" ]],
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"confound", @"delivery" ]],
        [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"syn_alt" causalOption:@"ack_alt"],
        [CLKArgumentManifestConstraint constraintLimitingOccurrencesForOption:@"thrud"],
        [CLKArgumentManifestConstraint constraintForRequiredOption:@"flarn_alt"],
        
        // redundant constraints should be deduplicated
        [CLKArgumentManifestConstraint constraintForRequiredOption:@"flarn"],
        [CLKArgumentManifestConstraint constraintLimitingOccurrencesForOption:@"thrud_alt"],
        [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"syn" causalOption:@"ack"],
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"confound_alt", @"delivery_alt" ]],
        [CLKArgumentManifestConstraint constraintRequiringRepresentationForOptions:@[ @"quone", @"xyzzy" ]],
        [CLKArgumentManifestConstraint constraintForStandaloneOption:@"thrud" allowingOptions:nil],
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"acme", @"station" ]], // passing constraint, no associated error
        [CLKArgumentManifestConstraint constraintForStandaloneOption:@"thrud_alt" allowingOptions:nil],
        [CLKArgumentManifestConstraint constraintRequiringRepresentationForOptions:@[ @"quone_alt", @"xyzzy_alt" ]],
        [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ @"confound", @"delivery" ]],
        [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"syn_alt" causalOption:@"ack_alt"],
        [CLKArgumentManifestConstraint constraintLimitingOccurrencesForOption:@"thrud"],
        [CLKArgumentManifestConstraint constraintForRequiredOption:@"flarn_alt"]
    ];
    
    #define ISSUE(error, options) \
        [CLKArgumentIssue issueWithError:error salientOptions:options]
    
    NSArray<CLKArgumentIssue *> *issues = @[
        ISSUE([NSError clk_CLKErrorWithCode:CLKErrorRequiredOptionNotProvided description:@"--flarn: required option not provided"], @[ @"flarn" ]),
        ISSUE([NSError clk_CLKErrorWithCode:CLKErrorTooManyOccurrencesOfOption description:@"--thrud_alt may not be provided more than once"], @[ @"thrud_alt" ]),
        ISSUE([NSError clk_CLKErrorWithCode:CLKErrorRequiredOptionNotProvided description:@"--syn is required when using --ack"], @[ @"syn" ]),
        ISSUE([NSError clk_CLKErrorWithCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--confound_alt --delivery_alt: mutually exclusive options encountered"], (@[ @"confound_alt", @"delivery_alt" ])),
        ISSUE([NSError clk_CLKErrorWithCode:CLKErrorRequiredOptionNotProvided description:@"one or more of the following options must be provided: --quone --xyzzy"], (@[ @"quone", @"xyzzy" ])),
        ISSUE([NSError clk_CLKErrorWithCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--thrud may not be provided with other options"], @[ @"thrud" ]),
        // no error for acme/station constraint
        ISSUE([NSError clk_CLKErrorWithCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--thrud_alt may not be provided with other options"], @[ @"thrud_alt" ]),
        ISSUE([NSError clk_CLKErrorWithCode:CLKErrorRequiredOptionNotProvided description:@"one or more of the following options must be provided: --quone_alt --xyzzy_alt"], (@[ @"quone_alt", @"xyzzy_alt" ])),
        ISSUE([NSError clk_CLKErrorWithCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--confound --delivery: mutually exclusive options encountered"], (@[ @"confound", @"delivery" ])),
        ISSUE([NSError clk_CLKErrorWithCode:CLKErrorRequiredOptionNotProvided description:@"--syn_alt is required when using --ack_alt"], @[ @"syn_alt" ]),
        ISSUE([NSError clk_CLKErrorWithCode:CLKErrorTooManyOccurrencesOfOption description:@"--thrud may not be provided more than once"], @[ @"thrud" ]),
        ISSUE([NSError clk_CLKErrorWithCode:CLKErrorRequiredOptionNotProvided description:@"--flarn_alt: required option not provided"], @[ @"flarn_alt" ])
    ];
    
    CLKArgumentManifestValidator *validator = [self validatorWithSwitchOptions:switchOptions parameterOptions:parameterOptions];
    ConstraintValidationSpec *spec = [ConstraintValidationSpec specWithConstraints:constraints issues:issues];
    [self evaluateSpec:spec usingValidator:validator];
}

@end
