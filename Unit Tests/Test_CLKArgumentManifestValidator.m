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

/*
    test cases can be described with a convenient dictionary form that is turned into
    concrete test spec objects. tests may also use these keys to construct custom
    subtest templates.
    
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
                kBandedOptionsKey     :? [ <str> ]
                kSignificantOptionKey :? <str>
                kPredicatingOptionKey :? <str>
            },
            
            // a case that should not pass validation
            @{
                kBandedOptionsKey     :? [ <str> ]
                kSignificantOptionKey :? <str>
                kPredicatingOptionKey :? <str>
                kErrorCodeKey         :  <CLKError>
                kErrorSalienceKey     :  [ <str> ] // the salientOptions of CLKArgumentIssue
                kErrorDescriptionKey  :  <str>
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

NS_ASSUME_NONNULL_BEGIN

static CLKArgumentManifestConstraint *_ConstraintFromSubtestTemplate(CLKConstraintType type, NSDictionary<NSString *, id> *subtest);

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

static CLKArgumentManifestConstraint *_ConstraintFromSubtestTemplate(CLKConstraintType type, NSDictionary<NSString *, id> *subtest)
{
    NSArray<NSString *> *band = subtest[kBandedOptionsKey];
    NSOrderedSet<NSString *> *bandSet = (band != nil ? [NSOrderedSet orderedSetWithArray:band] : nil);
    NSString *sig = subtest[kSignificantOptionKey];
    NSString *pred = subtest[kPredicatingOptionKey];
    return [[CLKArgumentManifestConstraint alloc] initWithType:type bandedOptions:bandSet significantOption:sig predicatingOption:pred];
}

@implementation Test_CLKArgumentManifestValidator

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
        CLKArgumentManifestConstraint *constraint = _ConstraintFromSubtestTemplate(type, subtest);
        CLKError errorCode = [subtest[kErrorCodeKey] unsignedIntValue];
        if (errorCode == CLKErrorNoError) {
            [self verifyValidationPassForConstraint:constraint usingValidator:validator];
        } else {
            NSParameterAssert([subtest[kErrorSalienceKey] count] > 0);
            NSParameterAssert(subtest[kErrorDescriptionKey] != nil);
            NSArray<NSString *> *salience = subtest[kErrorSalienceKey];
            NSString *desc = subtest[kErrorDescriptionKey];
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
        XCTAssertEqual(issues.count, 0UL, @"unexpected validation failure for constraints:\n%@\n\n*** issues:\n%@\n\n*** manifest:\n%@\n", spec.constraints, issues.debugDescription, validator.manifest.debugDescription);
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
    CLKOption *flarn = [CLKOption optionWithName:@"flarn" flag:@"f"];
    CLKOption *barf = [CLKOption requiredParameterOptionWithName:@"barf" flag:@"b"];
    
    NSDictionary *suite = @{
        kConstraintTypeKey : @(CLKConstraintTypeRequired),
        kManifestSwitchesKey   : @{ flarn : @(1) },
        kManifestParametersKey : @{ barf  : @[ @"bf_arg0" ] },
        kSubtestsKey : @[
            @{ kSignificantOptionKey : @"barf" },
            
            @{
                kSignificantOptionKey : @"xyzzy",
                kErrorCodeKey         : @(CLKErrorRequiredOptionNotProvided),
                kErrorSalienceKey     : @[ @"xyzzy" ],
                kErrorDescriptionKey  : @"--xyzzy: required option not provided"
            }
        ]
    };
    
    NSDictionary *emptyManifestSuite = @{
        kConstraintTypeKey : @(CLKConstraintTypeRequired),
        kSubtestsKey : @[
            @{
                kSignificantOptionKey : @"xyzzy",
                kErrorCodeKey         : @(CLKErrorRequiredOptionNotProvided),
                kErrorSalienceKey     : @[ @"xyzzy" ],
                kErrorDescriptionKey  : @"--xyzzy: required option not provided"
            }
        ]
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
            flarn : @[ @"fn_arg0" ],
            barf  : @[ @"bf_arg0" ]
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
            flarn : @[ @"fl_arg0" ],
            barf  : @[ @"bf_arg0" ]
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
            barf  : @[ @"bf_arg0" ],
            flarn : @[ @"fn_arg0", @"fn_arg1" ]
        },
        
        kSubtestsKey : @[
            @{ kBandedOptionsKey : @[ @"quone" ]},
            @{ kBandedOptionsKey : @[ @"quone", @"flarn" ]},
            @{ kBandedOptionsKey : @[ @"barf", @"flarn" ]},
            @{ kBandedOptionsKey : @[ @"quone", @"barf", @"flarn" ]},
            @{ kBandedOptionsKey : @[ @"quone", @"syn" ]},
            @{ kBandedOptionsKey : @[ @"barf", @"syn" ]}
        ]
    };
    
    NSDictionary *errorSuite = @{
        kConstraintTypeKey     : @(CLKConstraintTypeAnyRequired),
        kManifestSwitchesKey   : @{ quone : @(1) },
        kManifestParametersKey : @{
            barf  : @[ @"bf_arg0" ],
            flarn : @[ @"fn_arg0", @"fn_arg1" ]
        },
        
        kSubtestsKey : @[
            @{
                kBandedOptionsKey    : @[ @"syn" ],
                kErrorCodeKey        : @(CLKErrorRequiredOptionNotProvided),
                kErrorSalienceKey    : @[ @"syn" ],
                kErrorDescriptionKey : @"one or more of the following options must be provided: --syn"
            },
            
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
    
    NSDictionary *emptyManifestSuite = @{
        kConstraintTypeKey : @(CLKConstraintTypeAnyRequired),
        kSubtestsKey : errorSuite[kSubtestsKey]
    };
    
    [self performSubtestSuite:suite];
    [self performSubtestSuite:errorSuite];
    [self performSubtestSuite:emptyManifestSuite];
}

- (void)testValidateConstraint_anyRequired_predicatingOption
{
    CLKOption *acme  = [CLKOption parameterOptionWithName:@"acme" flag:@"a"];
    CLKOption *flarn = [CLKOption parameterOptionWithName:@"flarn" flag:@"f"];
    CLKOption *quone = [CLKOption optionWithName:@"quone" flag:@"q"];
    
    NSDictionary *suite = @{
        kConstraintTypeKey     : @(CLKConstraintTypeAnyRequired),
        kManifestSwitchesKey   : @{ quone : @(1) },
        kManifestParametersKey : @{
            acme  : @[ @"bf_arg0" ],
            flarn : @[ @"fn_arg0", @"fn_arg1" ]
        },
        
        kSubtestsKey : @[
            @{
                kBandedOptionsKey : @[ @"quone", @"syn" ],
                kPredicatingOptionKey : @"acme"
            },
            
            @{
                kBandedOptionsKey : @[ @"flarn", @"syn" ],
                kPredicatingOptionKey : @"acme"
            },
            
            @{
                kBandedOptionsKey : @[ @"flarn", @"quone" ],
                kPredicatingOptionKey : @"acme"
            }
        ]
    };
    
    NSDictionary *emptyManifestSuite = @{
        kConstraintTypeKey : @(CLKConstraintTypeAnyRequired),
        kSubtestsKey : @[
            @{
                kBandedOptionsKey : @[ @"flarn", @"quone" ],
                kPredicatingOptionKey : @"acme"
            }
        ]
    };
    
    NSDictionary *errorSuite = @{
        kConstraintTypeKey     : @(CLKConstraintTypeAnyRequired),
        kManifestSwitchesKey   : @{ quone : @(1) },
        kManifestParametersKey : @{
            acme  : @[ @"bf_arg0" ],
            flarn : @[ @"fn_arg0", @"fn_arg1" ]
        },
        
        kSubtestsKey : @[
            @{
                kBandedOptionsKey     : @[ @"syn", @"ack" ],
                kPredicatingOptionKey : @"acme",
                kErrorCodeKey         : @(CLKErrorRequiredOptionNotProvided),
                kErrorSalienceKey     : @[ @"syn", @"ack" ],
                kErrorDescriptionKey  : @"one or more of the following options must be provided when using --acme: --syn --ack"
            },
        ]
    };

    [self performSubtestSuite:suite];
    [self performSubtestSuite:emptyManifestSuite];
    [self performSubtestSuite:errorSuite];
}

- (void)testValidateConstraint_mutuallyExclusive
{
    CLKOption *barf  = [CLKOption parameterOptionWithName:@"barf" flag:@"b"];
    CLKOption *flarn = [CLKOption parameterOptionWithName:@"flarn" flag:@"f"];
    CLKOption *quone = [CLKOption optionWithName:@"quone" flag:@"q"];
    
    NSDictionary *suite = @{
        kConstraintTypeKey     : @(CLKConstraintTypeMutuallyExclusive),
        kManifestSwitchesKey   : @{ quone : @(1) },
        kManifestParametersKey : @{
            barf  : @[ @"bf_arg0" ],
            flarn : @[ @"fn_arg0", @"fn_arg1" ]
        },
        
        kSubtestsKey : @[
            @{ kBandedOptionsKey : @[ @"xyzzy", @"quone" ] },
            @{ kBandedOptionsKey : @[ @"barf", @"xyzzy" ] },
            @{ kBandedOptionsKey : @[ @"syn", @"ack" ] }
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
            barf  : @[ @"bf_arg0" ],
            flarn : @[ @"fn_arg0", @"fn_arg1" ]
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
                kErrorSalienceKey    : @[ @"quone", @"barf", @"flarn" ],
                kErrorDescriptionKey : @"--quone --barf --flarn: mutually exclusive options encountered"
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
    CLKOption *confound = [CLKOption parameterOptionWithName:@"confound" flag:@"c"];
    CLKOption *delivery = [CLKOption parameterOptionWithName:@"delivery" flag:@"d"];
    
    NSDictionary *suiteA = @{
        kConstraintTypeKey   : @(CLKConstraintTypeStandalone),
        kManifestSwitchesKey : @{ flarn : @(1) },
        kSubtestsKey : @[
            @{ kSignificantOptionKey : @"flarn" },
            
            @{
                kBandedOptionsKey     : @[],
                kSignificantOptionKey : @"flarn"
            }
        ]
    };
    
    NSDictionary *suiteB = @{
        kConstraintTypeKey     : @(CLKConstraintTypeStandalone),
        kManifestParametersKey : @{ confound : @[ @"cd_arg0" ] },
        kSubtestsKey : @[
            @{ kSignificantOptionKey : @"confound" },
            
            @{
                kBandedOptionsKey     : @[],
                kSignificantOptionKey : @"confound"
            }
        ]
    };
    
    // standalone options can be recurrent
    NSMutableDictionary *suiteA_recurrent = [suiteA mutableCopy];
    NSMutableDictionary *suiteB_recurrent = [suiteB mutableCopy];
    suiteA_recurrent[kManifestSwitchesKey]   = @{ flarn : @(7) };
    suiteB_recurrent[kManifestParametersKey] = @{ confound : @[ @"cd_arg0", @"cd_arg1" ] };
    
    // empty manifests
    NSMutableDictionary *suiteA_empty = [suiteA mutableCopy];
    NSMutableDictionary *suiteB_empty = [suiteB mutableCopy];
    suiteA_empty[kManifestSwitchesKey]   = nil;
    suiteB_empty[kManifestParametersKey] = nil;
    
    NSDictionary *suiteC = @{
        kConstraintTypeKey   : @(CLKConstraintTypeStandalone),
        kManifestSwitchesKey : @{
            flarn : @(1),
            barf  : @(7)
        },
        
        kManifestParametersKey : @{
            confound : @[ @"cd_arg0" ],
            delivery : @[ @"dy_arg0" ]
        },
        
        kSubtestsKey : @[
            @{
                kSignificantOptionKey : @"flarn",
                kErrorCodeKey         : @(CLKErrorMutuallyExclusiveOptionsPresent),
                kErrorSalienceKey     : @[ @"flarn" ],
                kErrorDescriptionKey  : @"--flarn may not be provided with other options"
            },
            
            @{
                kSignificantOptionKey : @"confound",
                kErrorCodeKey         : @(CLKErrorMutuallyExclusiveOptionsPresent),
                kErrorSalienceKey     : @[ @"confound" ],
                kErrorDescriptionKey  : @"--confound may not be provided with other options"
            },
            
            // empty whitelist
            @{
                kBandedOptionsKey     : @[],
                kSignificantOptionKey : @"flarn",
                kErrorCodeKey         : @(CLKErrorMutuallyExclusiveOptionsPresent),
                kErrorSalienceKey     : @[ @"flarn" ],
                kErrorDescriptionKey  : @"--flarn may not be provided with other options"
            },
            
            @{
                kBandedOptionsKey     : @[ @"barf" ],
                kSignificantOptionKey : @"flarn",
                kErrorCodeKey         : @(CLKErrorMutuallyExclusiveOptionsPresent),
                kErrorSalienceKey     : @[ @"flarn" ],
                kErrorDescriptionKey  : @"--flarn may not be provided with options other than the following: --barf"
            },
            
            @{
                kBandedOptionsKey     : @[ @"delivery" ],
                kSignificantOptionKey : @"confound",
                kErrorCodeKey         : @(CLKErrorMutuallyExclusiveOptionsPresent),
                kErrorSalienceKey     : @[ @"confound" ],
                kErrorDescriptionKey  : @"--confound may not be provided with options other than the following: --delivery"
            },
            
            @{
                kBandedOptionsKey     : @[ @"barf", @"confound" ],
                kSignificantOptionKey : @"flarn",
                kErrorCodeKey         : @(CLKErrorMutuallyExclusiveOptionsPresent),
                kErrorSalienceKey     : @[ @"flarn" ],
                kErrorDescriptionKey  : @"--flarn may not be provided with options other than the following: --barf --confound"
            },
            
            @{
                kBandedOptionsKey     : @[ @"barf", @"confound", @"delivery" ],
                kSignificantOptionKey : @"flarn",
            }
        ]
    };
    
    [self performSubtestSuite:suiteA];
    [self performSubtestSuite:suiteA_recurrent];
    [self performSubtestSuite:suiteA_empty];
    [self performSubtestSuite:suiteB];
    [self performSubtestSuite:suiteB_recurrent];
    [self performSubtestSuite:suiteB_empty];
    [self performSubtestSuite:suiteC];
}

- (void)testValidateConstraint_occurrencesLimited
{
    CLKOption *barf  = [CLKOption optionWithName:@"barf" flag:@"b"];
    CLKOption *flarn = [CLKOption optionWithName:@"flarn" flag:@"f"];
    CLKOption *quone = [CLKOption parameterOptionWithName:@"quone" flag:@"q"];
    CLKOption *xyzzy = [CLKOption parameterOptionWithName:@"xyzzy" flag:@"x"];
    
    NSDictionary *suite = @{
        kConstraintTypeKey   : @(CLKConstraintTypeOccurrencesLimited),
        kManifestSwitchesKey : @{
            flarn : @(1),
            barf  : @(2)
        },
        
        kManifestParametersKey : @{
            quone : @[ @"qe_arg0"],
            xyzzy : @[ @"xy_arg0", @"xy_arg1" ]
        },
        
        kSubtestsKey : @[
            @{ kSignificantOptionKey : @"flarn" },
            @{ kSignificantOptionKey : @"thrud" },
            @{ kSignificantOptionKey : @"acme"  }, // not in the manifest
            
            @{
                kSignificantOptionKey : @"barf",
                kErrorCodeKey         : @(CLKErrorTooManyOccurrencesOfOption),
                kErrorSalienceKey     : @[ @"barf" ],
                kErrorDescriptionKey  : @"--barf may not be provided more than once"
            },
            
            @{
                kSignificantOptionKey : @"xyzzy",
                kErrorCodeKey         : @(CLKErrorTooManyOccurrencesOfOption),
                kErrorSalienceKey     : @[ @"xyzzy" ],
                kErrorDescriptionKey  : @"--xyzzy may not be provided more than once"
            }
        ]
    };
    
    [self performSubtestSuite:suite];
}

- (void)testMultipleConstraints
{
    CLKOption *confound = [CLKOption optionWithName:@"confound" flag:nil];
    CLKOption *delivery = [CLKOption optionWithName:@"delivery" flag:nil];
    CLKOption *acme = [CLKOption parameterOptionWithName:@"acme" flag:nil];
    CLKOption *station = [CLKOption parameterOptionWithName:@"station" flag:nil];
    CLKOption *thrud = [CLKOption parameterOptionWithName:@"thrud" flag:nil];
    
    NSDictionary<CLKOption *, NSNumber *> *manifestSwitches = @{
        confound : @(1),
        delivery : @(7)
    };
    
    NSDictionary<CLKOption *, NSArray *> *manifestParameters = @{
        acme    : @[ @"!" ],
        station : @[ @"@", @"&" ], // violates occurence limit
        thrud   : @[ @"#" ]
    };
    
    NSArray<NSDictionary *> *baseConstraintSpecs = @[
        @{
            kConstraintTypeKey    : @(CLKConstraintTypeRequired),
            kSignificantOptionKey : @"xyzzy",
            kErrorCodeKey         : @(CLKErrorRequiredOptionNotProvided),
            kErrorSalienceKey     : @[ @"xyzzy" ],
            kErrorDescriptionKey  : @"--xyzzy: required option not provided"
        },
        
        @{
            kConstraintTypeKey    : @(CLKConstraintTypeRequired),
            kSignificantOptionKey : @"xyzzy",
            kPredicatingOptionKey : @"confound",
            kErrorCodeKey         : @(CLKErrorRequiredOptionNotProvided),
            kErrorSalienceKey     : @[ @"xyzzy" ],
            kErrorDescriptionKey  : @"--xyzzy is required when using --confound"
        },
        
        @{
            kConstraintTypeKey   : @(CLKConstraintTypeAnyRequired),
            kBandedOptionsKey    : @[ @"xyzzy", @"quone" ],
            kErrorCodeKey        : @(CLKErrorRequiredOptionNotProvided),
            kErrorSalienceKey    : @[ @"xyzzy", @"quone" ],
            kErrorDescriptionKey : @"one or more of the following options must be provided: --xyzzy --quone"
        },
        
        @{
            kConstraintTypeKey    : @(CLKConstraintTypeAnyRequired),
            kBandedOptionsKey     : @[ @"xyzzy", @"quone" ],
            kPredicatingOptionKey : @"confound",
            kErrorCodeKey         : @(CLKErrorRequiredOptionNotProvided),
            kErrorSalienceKey     : @[ @"xyzzy", @"quone" ],
            kErrorDescriptionKey  : @"one or more of the following options must be provided when using --confound: --xyzzy --quone"
        },

        @{
            kConstraintTypeKey   : @(CLKConstraintTypeMutuallyExclusive),
            kBandedOptionsKey    : @[ @"confound", @"station" ],
            kErrorCodeKey        : @(CLKErrorMutuallyExclusiveOptionsPresent),
            kErrorSalienceKey    : @[ @"confound", @"station" ],
            kErrorDescriptionKey : @"--confound --station: mutually exclusive options encountered"
        },
        
        @{
            kConstraintTypeKey    : @(CLKConstraintTypeStandalone),
            kSignificantOptionKey : @"acme",
            kErrorCodeKey         : @(CLKErrorMutuallyExclusiveOptionsPresent),
            kErrorSalienceKey     : @[ @"acme" ],
            kErrorDescriptionKey  : @"--acme may not be provided with other options"
        },
        
        @{
            kConstraintTypeKey    : @(CLKConstraintTypeOccurrencesLimited),
            kSignificantOptionKey : @"station",
            kErrorCodeKey         : @(CLKErrorTooManyOccurrencesOfOption),
            kErrorSalienceKey     : @[ @"station" ],
            kErrorDescriptionKey  : @"--station may not be provided more than once"
        }
    ];
    
    NSArray<NSDictionary *> *redundantConstraintSpecs = [baseConstraintSpecs arrayByAddingObjectsFromArray:baseConstraintSpecs];
    NSMutableArray<CLKArgumentManifestConstraint *> *constraints = [[NSMutableArray alloc] init];
    for (NSDictionary<NSString *, id> *spec in redundantConstraintSpecs) {
        NSAssert(spec[kConstraintTypeKey] != nil, @"missing constraint type in subtest spec");
        CLKConstraintType type = [spec[kConstraintTypeKey] unsignedIntValue];
        CLKArgumentManifestConstraint *constraint = _ConstraintFromSubtestTemplate(type, spec);
        [constraints addObject:constraint];
    }
    
    NSMutableArray<CLKArgumentIssue *> *expectedIssues = [[NSMutableArray alloc] init];
    for (NSDictionary<NSString *, id> *spec in baseConstraintSpecs) {
        NSAssert(spec[kErrorCodeKey] != nil, @"missing error code in subtest spec");
        NSAssert(spec[kErrorDescriptionKey] != nil, @"missing error description in subtest spec");
        NSAssert([spec[kErrorSalienceKey] count] > 0, @"missing or empty error salience in subtest spec");
        CLKError code = [spec[kErrorCodeKey] unsignedIntValue];
        NSArray<NSString *> *salience = spec[kErrorSalienceKey];
        NSString *desc = spec[kErrorDescriptionKey];
        NSError *error = [NSError clk_CLKErrorWithCode:code description:@"%@", desc];
        CLKArgumentIssue *issue = [CLKArgumentIssue issueWithError:error salientOptions:salience];
        [expectedIssues addObject:issue];
    }
    
    CLKArgumentManifestValidator *validator = [self validatorWithSwitchOptions:manifestSwitches parameterOptions:manifestParameters];
    ConstraintValidationSpec *spec = [ConstraintValidationSpec specWithConstraints:constraints issues:expectedIssues];
    [self evaluateSpec:spec usingValidator:validator];
}

@end
