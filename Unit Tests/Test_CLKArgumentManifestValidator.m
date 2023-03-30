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

#define SET(...) [[NSOrderedSet alloc] initWithObjects:__VA_ARGS__, nil]

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

/*
    test cases can be described with a convenient dictionary form that is turned into concrete test spec objects.
    
    :? = optional key
    
    suite {
        kConstraintTypeKey : <CLKConstraintType>
        
        // occurrences counts for switch options that should be present in the manifest
        kManifestSwitchesKey :? {
            <CLKOption> : <int>
        }
        
        // argument values for parameter options that should be present in the manifest
        kManifestParametersKey :? {
            <CLKOption> : [ <str> ]
        }
        
        kSubtestsKey : [
            // a case that should pass validation
            @{
                kBandedOptionsKey :? [ <str> ]
                kSignificantOptionKey :? <str>
                kPredicatingOptionKey :? <str>
            },
            
            // a case that should not pass validation
            @{
                kBandedOptionsKey :? [ <str> ]
                kSignificantOptionKey :? <str>
                kPredicatingOptionKey :? <str>
                kErrorCodeKey : <CLKError>
                kErrorSalienceKey : [ <str> ] // the salientOptions of CLKArgumentIssue
                kErrorDescriptionKey : <str>
            }
        ]
    }
*/

static NSString * const kConstraintTypeKey     = @"constraint_type";
static NSString * const kManifestSwitchesKey   = @"manifest_switches";
static NSString * const kManifestParametersKey = @"manifest_parameters";
static NSString * const kSubtestsKey           = @"subtests";

static NSString * const kBandedOptionsKey      = @"banded_options";
static NSString * const kSignificantOptionKey  = @"significant_option";
static NSString * const kPredicatingOptionKey  = @"predicating_option";

static NSString * const kErrorCodeKey          = @"error_code";
static NSString * const kErrorSalienceKey      = @"error_salience";
static NSString * const kErrorDescriptionKey   = @"error_description";

- (void)performSubtestSuite:(NSDictionary<NSString *, id> *)suite
{
    NSParameterAssert(suite[kConstraintTypeKey] != nil);
    NSParameterAssert([suite[kSubtestsKey] count] > 0);
    
    CLKConstraintType type = [suite[kConstraintTypeKey] unsignedIntValue];
    NSDictionary<CLKOption *, NSNumber *> *switches = suite[kManifestSwitchesKey];
    NSDictionary<CLKOption *, NSArray *> *parameters = suite[kManifestParametersKey];
    CLKArgumentManifestValidator *validator = [self validatorWithSwitchOptions:switches parameterOptions:parameters];
    
    NSArray<NSDictionary *> *subtests = suite[kSubtestsKey];
    for (NSDictionary<NSString *, id> *subtest in subtests) {
        NSArray<NSString *> *band = subtest[kBandedOptionsKey];
        NSOrderedSet<NSString *> *bandSet = (band != nil ? [NSOrderedSet orderedSetWithArray:band] : nil);
        NSString *sig = subtest[kSignificantOptionKey];
        NSString *pred = subtest[kPredicatingOptionKey];
        CLKArgumentManifestConstraint *constraint = [[CLKArgumentManifestConstraint alloc] initWithType:type bandedOptions:bandSet significantOption:sig predicatingOption:pred];
        
        CLKError errorCode = [subtest[kErrorCodeKey] unsignedIntValue];
        if (errorCode == CLKErrorNoError) {
            [self verifyValidationPassForConstraint:constraint usingValidator:validator];
        } else {
            NSParameterAssert(subtest[kErrorDescriptionKey] != nil);
            NSParameterAssert([subtest[kErrorSalienceKey] count] > 0);
            NSString *desc = subtest[kErrorDescriptionKey];
            NSArray<NSString *> *salience = subtest[kErrorSalienceKey];
            [self verifyValidationFailureForConstraint:constraint usingValidator:validator code:errorCode salientOptions:salience description:desc];
        }
    }
}

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
    
    NSDictionary *suite = @{
        kConstraintTypeKey : @(CLKConstraintTypeRequired),
        kManifestParametersKey : @{ flarn : @[ @"quone" ] },
        kSubtestsKey : @[
            @{ kSignificantOptionKey : @"flarn" },
            
            @{
                kSignificantOptionKey : @"barf",
                kErrorCodeKey         : @(CLKErrorRequiredOptionNotProvided),
                kErrorSalienceKey     : @[ @"barf" ],
                kErrorDescriptionKey  : @"--barf: required option not provided"
            }
        ]
    };
    
    NSDictionary *emptyManifestSuite = @{
        kConstraintTypeKey : @(CLKConstraintTypeRequired),
        kSubtestsKey : suite[kSubtestsKey]
    };
    
    [self performSubtestSuite:suite];
    [self performSubtestSuite:emptyManifestSuite];
}

- (void)testValidateConstraint_required_predicatingOption
{
    CLKOption *barf  = [CLKOption parameterOptionWithName:@"barf" flag:@"b"];
    CLKOption *flarn = [CLKOption parameterOptionWithName:@"flarn" flag:@"f"];
    CLKOption *quone = [CLKOption optionWithName:@"quone" flag:@"q"];
    
    NSDictionary *suite = @{
        kConstraintTypeKey     : @(CLKConstraintTypeRequired),
        kManifestSwitchesKey   : @{ quone : @(1) },
        kManifestParametersKey : @{
            flarn : @[ @"confound" ],
            barf  : @[ @"delivery" ]
        },
        
        kSubtestsKey : @[
            @{
                kSignificantOptionKey : @"barf",
                kPredicatingOptionKey : @"flarn"
            },
            
            @{
                kSignificantOptionKey : @"barf",
                kPredicatingOptionKey : @"quone"
            },
            
            // the conditionally required option is present but its predicate is not
            @{
                kSignificantOptionKey : @"quone",
                kPredicatingOptionKey : @"xyzzy"
            },
            
            // neither present in the manifest
            @{
                kSignificantOptionKey : @"ack",
                kPredicatingOptionKey : @"syn"
            },
        ]
    };
    
    NSDictionary *emptyManifestSuite = @{
        kConstraintTypeKey : @(CLKConstraintTypeRequired),
        kSubtestsKey : suite[kSubtestsKey]
    };
    
    NSDictionary *errorSuite = @{
        kConstraintTypeKey     : @(CLKConstraintTypeRequired),
        kManifestSwitchesKey   : @{ quone : @(1) },
        kManifestParametersKey : @{
            flarn : @[ @"confound" ],
            barf  : @[ @"delivery" ]
        },
        
        kSubtestsKey : @[
            @{
                kSignificantOptionKey : @"xyzzy",
                kPredicatingOptionKey : @"quone",
                kErrorCodeKey         : @(CLKErrorRequiredOptionNotProvided),
                kErrorSalienceKey     : @[ @"xyzzy" ],
                kErrorDescriptionKey  : @"--xyzzy is required when using --quone"
            }
        ]
    };
    
    [self performSubtestSuite:suite];
    [self performSubtestSuite:emptyManifestSuite];
    [self performSubtestSuite:errorSuite];
}

- (void)testValidateConstraint_anyRequired
{
    CLKOption *barf  = [CLKOption parameterOptionWithName:@"barf" flag:@"b"];
    CLKOption *flarn = [CLKOption parameterOptionWithName:@"flarn" flag:@"f"];
    CLKOption *quone = [CLKOption optionWithName:@"quone" flag:@"q"];
    
    NSDictionary *suite = @{
        kConstraintTypeKey     : @(CLKConstraintTypeAnyRequired),
        kManifestSwitchesKey   : @{ quone : @(1) },
        kManifestParametersKey : @{
            barf  : @[ @"xyzzy" ],
            flarn : @[ @"confound", @"delivery" ]
        },
        
        kSubtestsKey : @[
            @{ kBandedOptionsKey : @[ @"quone", @"flarn" ]},
            @{ kBandedOptionsKey : @[ @"barf", @"flarn" ]},
            @{ kBandedOptionsKey : @[ @"quone", @"barf", @"flarn" ]},
            @{ kBandedOptionsKey : @[ @"quone", @"syn" ]},
            @{ kBandedOptionsKey : @[ @"barf", @"syn" ]}
        ]
    };
    
    NSDictionary *emptyManifestSuite = @{
        kConstraintTypeKey : @(CLKConstraintTypeAnyRequired),
        kSubtestsKey : suite[kSubtestsKey]
    };
    
    NSDictionary *errorSuite = @{
        kConstraintTypeKey     : @(CLKConstraintTypeAnyRequired),
        kManifestSwitchesKey   : @{ quone : @(1) },
        kManifestParametersKey : @{
            barf  : @[ @"xyzzy" ],
            flarn : @[ @"confound", @"delivery" ]
        },
        
        kSubtestsKey : @[
            @{
                kBandedOptionsKey    : @[ @"syn", @"ack" ],
                kErrorCodeKey        : @(CLKErrorRequiredOptionNotProvided),
                kErrorSalienceKey    : @[ @"syn", @"ack" ],
                kErrorDescriptionKey : @"one or more of the following options must be provided: --syn --ack"
            },
            
            @{
                kBandedOptionsKey    : @[ @"syn", @"ack", @"what" ],
                kErrorCodeKey        : @(CLKErrorRequiredOptionNotProvided),
                kErrorSalienceKey    : @[ @"syn", @"ack", @"what" ],
                kErrorDescriptionKey : @"one or more of the following options must be provided: --syn --ack --what"
            }
        ]
    };
    
    [self performSubtestSuite:suite];
    [self performSubtestSuite:emptyManifestSuite];
    [self performSubtestSuite:errorSuite];
}

#warning add coverage for CLKConstraintTypeAnyRequired + predicatingOption

- (void)testValidateConstraint_mutuallyExclusive
{
    CLKOption *barf  = [CLKOption parameterOptionWithName:@"barf" flag:@"b"];
    CLKOption *flarn = [CLKOption parameterOptionWithName:@"flarn" flag:@"f"];
    CLKOption *quone = [CLKOption optionWithName:@"quone" flag:@"q"];
    
    NSDictionary *suite = @{
        kConstraintTypeKey     : @(CLKConstraintTypeMutuallyExclusive),
        kManifestSwitchesKey   : @{ quone : @(1) },
        kManifestParametersKey : @{
            barf : @[ @"xyzzy" ],
            flarn : @[ @"confound", @"delivery" ]
        },
        
        kSubtestsKey : @[
            @{ kBandedOptionsKey : @[ @"syn", @"ack" ] },
            @{ kBandedOptionsKey : @[ @"syn", @"ack", @"what"] },
            @{ kBandedOptionsKey : @[ @"quone", @"xyzzy" ] },
            @{ kBandedOptionsKey : @[ @"barf", @"xyzzy" ] }
        ]
    };
    
    NSDictionary *emptyManifestSuite = @{
        kConstraintTypeKey : @(CLKConstraintTypeMutuallyExclusive),
        kSubtestsKey : suite[kSubtestsKey]
    };
    
    NSDictionary *errorSuite = @{
        kConstraintTypeKey     : @(CLKConstraintTypeMutuallyExclusive),
        kManifestSwitchesKey   : @{ quone : @(1) },
        kManifestParametersKey : @{
            barf : @[ @"xyzzy" ],
            flarn : @[ @"confound", @"delivery" ]
        },
        
        kSubtestsKey : @[
            @{
                kBandedOptionsKey    : @[ @"quone", @"barf" ],
                kErrorCodeKey        : @(CLKErrorMutuallyExclusiveOptionsPresent),
                kErrorSalienceKey    : @[ @"quone", @"barf" ],
                kErrorDescriptionKey : @"--quone --barf: mutually exclusive options encountered"
            },
            
            @{
                kBandedOptionsKey    : @[ @"quone", @"flarn" ],
                kErrorCodeKey        : @(CLKErrorMutuallyExclusiveOptionsPresent),
                kErrorSalienceKey    : @[ @"quone", @"flarn" ],
                kErrorDescriptionKey : @"--quone --flarn: mutually exclusive options encountered"
            },
            
            @{
                kBandedOptionsKey    : @[ @"barf", @"flarn" ],
                kErrorCodeKey        : @(CLKErrorMutuallyExclusiveOptionsPresent),
                kErrorSalienceKey    : @[ @"barf", @"flarn" ],
                kErrorDescriptionKey : @"--barf --flarn: mutually exclusive options encountered"
            },
            
            @{
                kBandedOptionsKey    : @[ @"quone", @"barf", @"flarn" ],
                kErrorCodeKey        : @(CLKErrorMutuallyExclusiveOptionsPresent),
                kErrorSalienceKey    : @[ @"quone", @"barf" ],
                kErrorDescriptionKey : @"--quone --barf: mutually exclusive options encountered"
            },
            
            @{
                kBandedOptionsKey    : @[ @"barf", @"flarn", @"xyzzy" ],
                kErrorCodeKey        : @(CLKErrorMutuallyExclusiveOptionsPresent),
                kErrorSalienceKey    : @[ @"barf", @"flarn" ],
                kErrorDescriptionKey : @"--barf --flarn: mutually exclusive options encountered"
            }
        ]
    };
    
    [self performSubtestSuite:suite];
    [self performSubtestSuite:emptyManifestSuite];
    [self performSubtestSuite:errorSuite];
}

- (void)testValidateConstraint_standalone
{
    CLKOption *flarn = [CLKOption optionWithName:@"flarn" flag:@"f"];
    CLKOption *barf  = [CLKOption optionWithName:@"barf" flag:@"b"];
    CLKOption *confound = [CLKOption optionWithName:@"confound" flag:@"c"];
    CLKOption *delivery = [CLKOption parameterOptionWithName:@"delivery" flag:@"d"];
    
    {
        NSDictionary *manifestSwitches = @{ flarn : @(1) };
        CLKArgumentManifestValidator *validator = [self validatorWithSwitchOptions:manifestSwitches parameterOptions:nil];
        
        CLKArgumentManifestConstraint *constraint = [[CLKArgumentManifestConstraint alloc] initWithType:CLKConstraintTypeStandalone bandedOptions:nil significantOption:@"flarn" predicatingOption:nil];
        [self verifyValidationPassForConstraint:constraint usingValidator:validator];
        
        constraint = [[CLKArgumentManifestConstraint alloc] initWithType:CLKConstraintTypeStandalone bandedOptions:[NSOrderedSet orderedSet] significantOption:@"flarn" predicatingOption:nil];
        [self verifyValidationPassForConstraint:constraint usingValidator:validator];
    }
    
    #warning need to cover manifestParameters only (no switches present)
    #warning need success where flarn is specified more than once -- standalone options can be recurrent
    #warning do we need empty manifest cases?
    
    {
        NSDictionary *manifestSwitches = @{
            flarn : @(1),
            barf : @(1)
        };
        
        NSDictionary *manifestParameters = @{
            delivery : @[ @"xyzzy" ]
        };
        
        CLKArgumentManifestValidator *validator = [self validatorWithSwitchOptions:manifestSwitches parameterOptions:manifestParameters];
        
        CLKArgumentManifestConstraint *constraint = [[CLKArgumentManifestConstraint alloc] initWithType:CLKConstraintTypeStandalone bandedOptions:nil significantOption:@"flarn" predicatingOption:nil];
        [self verifyValidationFailureForConstraint:constraint usingValidator:validator code:CLKErrorMutuallyExclusiveOptionsPresent salientOptions:@[ @"flarn" ] description:@"--flarn may not be provided with other options"];
        
        constraint = [[CLKArgumentManifestConstraint alloc] initWithType:CLKConstraintTypeStandalone bandedOptions:[NSOrderedSet orderedSet] significantOption:@"flarn" predicatingOption:nil];
        [self verifyValidationFailureForConstraint:constraint usingValidator:validator code:CLKErrorMutuallyExclusiveOptionsPresent salientOptions:@[ @"flarn" ] description:@"--flarn may not be provided with other options"];
    }
    
    {
        NSDictionary *manifestSwitches = @{
            flarn : @(1),
            barf : @(1),
            confound : @(1),
        };
        
        NSDictionary *manifestParameters = @{
            delivery : @[ @"xyzzy" ]
        };
        
        CLKArgumentManifestValidator *validator = [self validatorWithSwitchOptions:manifestSwitches parameterOptions:manifestParameters];
        
        constraint = [CLKArgumentManifestConstraint constraintForStandaloneOption:@"flarn" allowingOptions:@[ @"barf" ]];
        [self verifyValidationFailureForConstraint:constraint usingValidator:validator code:CLKErrorMutuallyExclusiveOptionsPresent salientOptions:@[ @"flarn" ] description:@"--flarn may not be provided with options other than the following: --barf"];
        
        constraint = [CLKArgumentManifestConstraint constraintForStandaloneOption:@"flarn" allowingOptions:@[ @"barf", @"confound" ]];
        [self verifyValidationFailureForConstraint:constraint usingValidator:validator code:CLKErrorMutuallyExclusiveOptionsPresent salientOptions:@[ @"flarn" ] description:@"--flarn may not be provided with options other than the following: --barf --confound"];
        
        constraint = [CLKArgumentManifestConstraint constraintForStandaloneOption:@"flarn" allowingOptions:@[ @"barf", @"confound", @"delivery" ]];
        [self verifyValidationPassForConstraint:constraint usingValidator:validator];
    }
    
    #warning error cases: need to cover manifestParameters only (no switches present)
}

- (void)testValidateConstraint_occurrencesLimited
{
    CLKOption *barf  = [CLKOption parameterOptionWithName:@"barf" flag:@"b"];
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
