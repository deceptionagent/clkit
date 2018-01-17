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


@interface Test_CLKArgumentManifestValidator : XCTestCase

@end


@implementation Test_CLKArgumentManifestValidator

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
    
    NSError *error = nil;
    CLKArgumentManifestConstraint *constraint = [CLKArgumentManifestConstraint constraintForRequiredOption:@"flarn"];
    XCTAssertTrue([validator validateConstraints:@[ constraint ] error:&error]);
    XCTAssertNil(error);
    
    constraint = [CLKArgumentManifestConstraint constraintForRequiredOption:@"barf"];
    XCTAssertFalse([validator validateConstraints:@[ constraint ] error:&error]);
    [self verifyCLKError:error code:CLKErrorRequiredOptionNotProvided description:@"--barf: required option not provided"];
}

- (void)testValidateConstraint_conditionallyRequired
{
    CLKOption *barf = [CLKOption parameterOptionWithName:@"barf" flag:@"b"];
    CLKOption *flarn = [CLKOption parameterOptionWithName:@"flarn" flag:@"f"];
    CLKOption *quone = [CLKOption optionWithName:@"quone" flag:@"q"];
    
    NSDictionary *parameterContents = @{
        flarn : @[ @"confound" ],
        barf : @[ @"delivery" ]
    };
    
    CLKArgumentManifestValidator *validator = [self validatorWithSwitchOptions:@{ quone : @(1) } parameterOptions:parameterContents];
    
    NSError *error = nil;
    CLKArgumentManifestConstraint *constraint = [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"barf" associatedOption:@"flarn"];
    XCTAssertTrue([validator validateConstraints:@[ constraint ] error:&error]);
    XCTAssertNil(error);
    
    error = nil;
    constraint = [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"barf" associatedOption:@"quone"];
    XCTAssertTrue([validator validateConstraints:@[ constraint ] error:&error]);
    XCTAssertNil(error);
    
    error = nil;
    constraint = [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"xyzzy" associatedOption:@"quone"];
    XCTAssertFalse([validator validateConstraints:@[ constraint ] error:&error]);
    [self verifyCLKError:error code:CLKErrorRequiredOptionNotProvided description:@"--xyzzy is required when using --quone"];
    
    error = nil;
    constraint = [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:@"ack" associatedOption:@"syn"];
    XCTAssertTrue([validator validateConstraints:@[ constraint ] error:&error]);
    XCTAssertNil(error);
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
    
    NSError *error = nil;
    CLKArgumentManifestConstraint *constraint = [CLKArgumentManifestConstraint constraintRestrictingOccurrencesForOption:@"barf"];
    XCTAssertTrue([validator validateConstraints:@[ constraint ] error:&error]);
    XCTAssertNil(error);
    
    error = nil;
    constraint = [CLKArgumentManifestConstraint constraintRestrictingOccurrencesForOption:@"flarn"];
    XCTAssertFalse([validator validateConstraints:@[ constraint ] error:&error]);
    [self verifyCLKError:error code:CLKErrorTooManyOccurrencesOfOption description:@"--flarn may not be provided more than once"];
    
    error = nil;
    constraint = [CLKArgumentManifestConstraint constraintRestrictingOccurrencesForOption:@"quone"];
    XCTAssertTrue([validator validateConstraints:@[ constraint ] error:&error]);
    XCTAssertNil(error);
    
    error = nil;
    constraint = [CLKArgumentManifestConstraint constraintRestrictingOccurrencesForOption:@"xyzzy"];
    XCTAssertFalse([validator validateConstraints:@[ constraint ] error:&error]);
    [self verifyCLKError:error code:CLKErrorTooManyOccurrencesOfOption description:@"--xyzzy may not be provided more than once"];
    
    error = nil;
    constraint = [CLKArgumentManifestConstraint constraintRestrictingOccurrencesForOption:@"aeon"];
    XCTAssertTrue([validator validateConstraints:@[ constraint ] error:&error]);
    XCTAssertNil(error);
}

@end
