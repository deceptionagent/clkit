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


@interface Test_CLKArgumentManifestValidator : XCTestCase

- (void)performValidationWithSuppliedOptions:(nullable NSArray<CLKOption *> *)suppliedOptions missingOptions:(nullable NSArray<CLKOption *> *)missingOptions;

@end


@implementation Test_CLKArgumentManifestValidator

- (void)performValidationWithSuppliedOptions:(NSArray<CLKOption *> *)suppliedOptions missingOptions:(NSArray<CLKOption *> *)missingOptions
{
    CLKArgumentManifest *manifest = [CLKArgumentManifest manifest];
    for (CLKOption *option in suppliedOptions) {
        if (option.type == CLKOptionTypeParameter) {
            [manifest accumulateArgument:@"flarn" forParameterOption:option];
        } else {
            [manifest accumulateSwitchOption:option];
        }
    }
    
    CLKArgumentManifestValidator *validator = [[[CLKArgumentManifestValidator alloc] initWithManifest:manifest] autorelease];
    
    for (CLKOption *option in suppliedOptions) {
        printf("*** validating supplied option: %s\n", option.description.UTF8String);
        NSError *error = nil;
        BOOL result = [validator validateOption:option error:&error];
        XCTAssertTrue(result);
        XCTAssertNil(error);
    }
    
    for (CLKOption *option in missingOptions) {
        printf("*** validating missing option: %s\n", option.description.UTF8String);
        NSError *error = nil;
        BOOL result = [validator validateOption:option error:&error];
        if (option.required) {
            XCTAssertFalse(result);
            NSString *desc = [NSString stringWithFormat:@"--%@: required option not provided", option.name];
            [self verifyCLKError:error code:CLKErrorRequiredOptionNotProvided description:desc];
        } else {
            XCTAssertTrue(result);
            XCTAssertNil(error);
        }
    }
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

- (void)testValidateOption_emptyManifest
{
    NSArray *suppliedOptions = @[
        [CLKOption parameterOptionWithName:@"opt" flag:@"o" required:NO],
        [CLKOption parameterOptionWithName:@"req" flag:@"r" required:YES],
        [CLKOption optionWithName:@"switch" flag:@"f"]
    ];
    
    [self performValidationWithSuppliedOptions:suppliedOptions missingOptions:nil];
}

- (void)testValidateOption
{
    NSArray *suppliedOptions = @[
        [CLKOption parameterOptionWithName:@"alpha" flag:@"a" required:NO],
        [CLKOption parameterOptionWithName:@"charlie" flag:@"c" required:YES],
        [CLKOption optionWithName:@"echo" flag:@"e"]
    ];
    
    NSArray *missingOptions = @[
        [CLKOption parameterOptionWithName:@"bravo" flag:@"b" required:NO],
        [CLKOption parameterOptionWithName:@"xxx" flag:@"d" required:YES],
        [CLKOption optionWithName:@"foxtrot" flag:@"f"]
    ];
    
    [self performValidationWithSuppliedOptions:suppliedOptions missingOptions:missingOptions];
}

@end
