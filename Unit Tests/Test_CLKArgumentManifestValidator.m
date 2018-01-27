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
#import "XCTestCase+CLKAdditions.h"


NS_ASSUME_NONNULL_BEGIN

@interface Test_CLKArgumentManifestValidator : XCTestCase

- (void)verifyValidationPassForConstraint:(CLKArgumentManifestConstraint *)constraint validator:(CLKArgumentManifestValidator *)validator;
- (void)verifyValidationFaliureForConstraint:(CLKArgumentManifestConstraint *)constraint validator:(CLKArgumentManifestValidator *)validator code:(NSUInteger)code description:(NSString *)description;

@end

NS_ASSUME_NONNULL_END


@implementation Test_CLKArgumentManifestValidator

- (void)verifyValidationPassForConstraint:(CLKArgumentManifestConstraint *)constraint validator:(CLKArgumentManifestValidator *)validator
{
    NSError *error = nil;
    XCTAssertTrue([validator validateConstraints:@[ constraint ] error:&error]);
    XCTAssertNil(error);
}

- (void)verifyValidationFaliureForConstraint:(CLKArgumentManifestConstraint *)constraint validator:(CLKArgumentManifestValidator *)validator code:(NSUInteger)code description:(NSString *)description
{
    NSError *error = nil;
    XCTAssertFalse([validator validateConstraints:@[ constraint ] error:&error]);
    [self verifyCLKError:error code:code description:description];
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
    [self verifyValidationFaliureForConstraint:constraint validator:validator code:CLKErrorRequiredOptionNotProvided description:@"--barf: required option not provided"];
    [self verifyValidationFaliureForConstraint:constraint validator:emptyValidator code:CLKErrorRequiredOptionNotProvided description:@"--barf: required option not provided"];
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
    [self verifyValidationFaliureForConstraint:constraint validator:validator code:CLKErrorRequiredOptionNotProvided description:@"--xyzzy is required when using --quone"];
    
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
    [self verifyValidationFaliureForConstraint:constraint validator:validator code:CLKErrorTooManyOccurrencesOfOption description:@"--flarn may not be provided more than once"];
    
    constraint = [CLKArgumentManifestConstraint constraintRestrictingOccurrencesForOption:@"quone"];
    [self verifyValidationPassForConstraint:constraint validator:validator];
    
    constraint = [CLKArgumentManifestConstraint constraintRestrictingOccurrencesForOption:@"xyzzy"];
    [self verifyValidationFaliureForConstraint:constraint validator:validator code:CLKErrorTooManyOccurrencesOfOption description:@"--xyzzy may not be provided more than once"];
    
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
    [self verifyValidationFaliureForConstraint:constraint validator:validator code:CLKErrorRequiredOptionNotProvided description:@"one or more of the following options must be provided: --syn, --ack"];
    [self verifyValidationFaliureForConstraint:constraint validator:emptyValidator code:CLKErrorRequiredOptionNotProvided description:@"one or more of the following options must be provided: --syn, --ack"];
    
    constraint = [CLKArgumentManifestConstraint constraintRequiringRepresentativeForOptions:@[ @"syn", @"ack", @"what" ]];
    [self verifyValidationFaliureForConstraint:constraint validator:validator code:CLKErrorRequiredOptionNotProvided description:@"one or more of the following options must be provided: --syn, --ack, --what"];
    [self verifyValidationFaliureForConstraint:constraint validator:emptyValidator code:CLKErrorRequiredOptionNotProvided description:@"one or more of the following options must be provided: --syn, --ack, --what"];
}

@end
