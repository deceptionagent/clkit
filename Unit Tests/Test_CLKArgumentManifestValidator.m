//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CLKArgumentManifest.h"
#import "CLKArgumentManifest_Private.h"
#import "CLKArgumentManifestValidator.h"
#import "CLKError.h"
#import "CLKOption.h"
#import "CLKOption_Private.h"
#import "XCTestCase+CLKAdditions.h"


NS_ASSUME_NONNULL_BEGIN

@interface Test_CLKArgumentManifestValidator : XCTestCase

- (CLKArgumentManifest *)manifestWithSwitchOptions:(nullable NSDictionary<CLKOption *, NSNumber *> *)switchOptions parameterOptions:(nullable NSDictionary<CLKOption *, NSArray *> *)parameterOptions;
- (CLKArgumentManifestValidator *)validatorWithSwitchOptions:(nullable NSDictionary<CLKOption *, NSNumber *> *)switchOptions parameterOptions:(nullable NSDictionary<CLKOption *, id> *)parameterOptions;
- (void)verifyValidationPassForOption:(CLKOption *)option validator:(CLKArgumentManifestValidator *)validator;

@end

NS_ASSUME_NONNULL_END


@interface ManifestValidationSpec : NSObject


@end

@implementation Test_CLKArgumentManifestValidator

- (CLKArgumentManifest *)manifestWithSwitchOptions:(NSDictionary<CLKOption *, NSNumber *> *)switchOptions parameterOptions:(NSDictionary<CLKOption *, NSArray *> *)parameterOptions
{
    CLKArgumentManifest *manifest = [CLKArgumentManifest manifest];
    
    [switchOptions enumerateKeysAndObjectsUsingBlock:^(CLKOption *option, NSNumber *count, __unused BOOL *outStop) {
        int i;
        for (i = 0 ; i < count.intValue ; i++) {
            [manifest accumulateSwitchOption:option];
        }
    }];

    [parameterOptions enumerateKeysAndObjectsUsingBlock:^(CLKOption *option, NSArray *arguments, __unused BOOL *outStop) {
        for (id argument in arguments) {
            [manifest accumulateArgument:argument forParameterOption:option];
        }
    }];
    
    return manifest;
}

- (CLKArgumentManifestValidator *)validatorWithSwitchOptions:(NSDictionary<CLKOption *, NSNumber *> *)switchOptions parameterOptions:(NSDictionary<CLKOption *, NSArray *> *)parameterOptions
{
    CLKArgumentManifest *manifest = [self manifestWithSwitchOptions:switchOptions parameterOptions:parameterOptions];
    return [[[CLKArgumentManifestValidator alloc] initWithManifest:manifest] autorelease];
}

- (void)verifyValidationPassForOption:(CLKOption *)option validator:(CLKArgumentManifestValidator *)validator
{
    NSError *error = nil;
    XCTAssertTrue([validator validateOption:option error:&error]);
    XCTAssertNil(error);
}

#pragma mark -

- (void)testInit
{
    CLKArgumentManifest *manifest = [CLKArgumentManifest manifest];
    CLKArgumentManifestValidator *validator = [[[CLKArgumentManifestValidator alloc] initWithManifest:manifest] autorelease];
    XCTAssertNotNil(validator);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    XCTAssertThrows([[[CLKArgumentManifestValidator alloc] initWithManifest:nil] autorelease]);
#pragma clang diagnostic pop
}

- (void)testValidateOptions_mixed_emptyManifest
{
    CLKOption *optional = [CLKOption parameterOptionWithName:@"opt" flag:@"o" required:NO];
    CLKOption *required = [CLKOption parameterOptionWithName:@"req" flag:@"r" required:YES];
    CLKOption *optionalSwitch = [CLKOption optionWithName:@"optionalSwitch" flag:@"s"];
    
    CLKArgumentManifest *manifest = [CLKArgumentManifest manifest];
    CLKArgumentManifestValidator *validator = [[[CLKArgumentManifestValidator alloc] initWithManifest:manifest] autorelease];
    
    [self verifyValidationPassForOption:optional validator:validator];
    
    NSError *error = nil;
    XCTAssertFalse([validator validateOption:required error:&error]);
    [self verifyCLKError:error code:CLKErrorRequiredOptionNotProvided description:@"--req: required option not provided"];
    
    [self verifyValidationPassForOption:optionalSwitch validator:validator];
}

- (void)testValidateOption_required
{
    CLKOption *alpha = [CLKOption parameterOptionWithName:@"alpha" flag:@"a" required:NO]; // supplied
    CLKOption *bravo = [CLKOption parameterOptionWithName:@"bravo" flag:@"b" required:NO]; // missing
    CLKOption *charlie = [CLKOption parameterOptionWithName:@"charlie" flag:@"c" required:YES]; // supplied
    CLKOption *delta = [CLKOption parameterOptionWithName:@"delta" flag:@"d" required:YES]; // missing
    CLKOption *echo = [CLKOption optionWithName:@"echo" flag:@"e"]; // supplied
    CLKOption *foxtrot = [CLKOption optionWithName:@"foxtrot" flag:@"f"]; // missing
    
    NSDictionary *suppliedParameterOptions = @{
        alpha : @[ @"flarn" ],
        charlie : @[ @"barf" ]
    };
    
    CLKArgumentManifestValidator *validator = [self validatorWithSwitchOptions:@{ echo : @(1) } parameterOptions:suppliedParameterOptions];
    [self verifyValidationPassForOption:alpha validator:validator];
    [self verifyValidationPassForOption:bravo validator:validator];
    [self verifyValidationPassForOption:charlie validator:validator];
    
    NSError *error = nil;
    XCTAssertFalse([validator validateOption:delta error:&error]);
    [self verifyCLKError:error code:CLKErrorRequiredOptionNotProvided description:@"--delta: required option not provided"];
    XCTAssertFalse([validator validateOption:delta error:nil]);
    
    [self verifyValidationPassForOption:echo validator:validator];
    [self verifyValidationPassForOption:foxtrot validator:validator];
}

- (void)testValidateOption_dependencies
{
    CLKOption *alpha = [CLKOption parameterOptionWithName:@"alpha" flag:@"a"];
    CLKOption *bravo = [CLKOption parameterOptionWithName:@"bravo" flag:@"b"];
    CLKOption *charlie = [CLKOption optionWithName:@"charlie" flag:@"c" dependencies:@[ alpha, bravo ]];
    
    CLKArgumentManifestValidator *validator = [self validatorWithSwitchOptions:nil parameterOptions:nil];
    [self verifyValidationPassForOption:charlie validator:validator];
    
    validator = [self validatorWithSwitchOptions:nil parameterOptions:@{ alpha : @[ @"flarn" ] }];
    [self verifyValidationPassForOption:charlie validator:validator];
    
    validator = [self validatorWithSwitchOptions:@{ charlie : @(1) } parameterOptions:nil];
    NSError *error = nil;
    XCTAssertFalse([validator validateOption:charlie error:&error]);
    [self verifyCLKError:error code:CLKErrorRequiredOptionNotProvided description:@"--alpha is required when using --charlie"];
    
    validator = [self validatorWithSwitchOptions:@{ charlie : @(1) } parameterOptions:@{ alpha : @[ @"flarn" ] }];
    error = nil;
    XCTAssertFalse([validator validateOption:charlie error:&error]);
    [self verifyCLKError:error code:CLKErrorRequiredOptionNotProvided description:@"--bravo is required when using --charlie"];
    
    validator = [self validatorWithSwitchOptions:@{ charlie : @(1) } parameterOptions:@{ bravo : @[ @"flarn" ] }];
    error = nil;
    XCTAssertFalse([validator validateOption:charlie error:&error]);
    [self verifyCLKError:error code:CLKErrorRequiredOptionNotProvided description:@"--alpha is required when using --charlie"];
}

@end
