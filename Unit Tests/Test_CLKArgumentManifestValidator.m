//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CLKArgumentManifest.h"
#import "CLKArgumentManifest_Private.h"
#import "CLKArgumentManifestValidator.h"
#import "CLKError.h"
#import "CLKOption.h"
#import "XCTestCase+CLKAdditions.h"


@interface Test_CLKArgumentManifestValidator : XCTestCase

@end


@implementation Test_CLKArgumentManifestValidator

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
    CLKOption *optionalOption = [CLKOption optionWithName:@"opt" flag:@"o" required:NO];
    CLKOption *requiredOption = [CLKOption optionWithName:@"req" flag:@"r" required:YES];
    CLKOption *freeOption = [CLKOption freeOptionWithName:@"free" flag:@"f"];
    
    CLKArgumentManifest *manifest = [CLKArgumentManifest manifest];
    CLKArgumentManifestValidator *validator = [[[CLKArgumentManifestValidator alloc] initWithManifest:manifest] autorelease];
    
    NSError *error = nil;
    XCTAssertTrue([validator validateOption:optionalOption error:&error]);
    XCTAssertNil(error);
    
    error = nil;
    XCTAssertFalse([validator validateOption:requiredOption error:&error]);
    [self verifyCLKError:error code:CLKErrorRequiredOptionNotProvided description:@"--req: required option not provided"];
    
    error = nil;
    XCTAssertTrue([validator validateOption:freeOption error:&error]);
    XCTAssertNil(error);
}

- (void)testValidateOption
{
    CLKOption *alpha = [CLKOption optionWithName:@"alpha" flag:@"a" required:NO]; // present
    CLKOption *bravo = [CLKOption optionWithName:@"bravo" flag:@"b" required:NO]; // missing
    CLKOption *charlie = [CLKOption optionWithName:@"charlie" flag:@"c" required:YES]; // present
    CLKOption *delta = [CLKOption optionWithName:@"delta" flag:@"d" required:YES]; // missing
    CLKOption *echo = [CLKOption freeOptionWithName:@"echo" flag:@"e"]; // present
    CLKOption *foxtrot = [CLKOption freeOptionWithName:@"foxtrot" flag:@"f"]; // missing
    
    CLKArgumentManifest *manifest = [CLKArgumentManifest manifest];
    [manifest accumulateArgument:@"flarn" forOption:alpha];
    [manifest accumulateArgument:@"flarn" forOption:charlie];
    [manifest accumulateFreeOption:echo];
    
    CLKArgumentManifestValidator *validator = [[[CLKArgumentManifestValidator alloc] initWithManifest:manifest] autorelease];
    
    /* not required */
    
    NSError *error = nil;
    XCTAssertTrue([validator validateOption:alpha error:&error]);
    XCTAssertNil(error);

    error = nil;
    XCTAssertTrue([validator validateOption:bravo error:&error]);
    XCTAssertNil(error);
    
    /* required */
    
    error = nil;
    XCTAssertTrue([validator validateOption:charlie error:&error]);
    XCTAssertNil(error);
    
    error = nil;
    XCTAssertFalse([validator validateOption:delta error:&error]);
    [self verifyCLKError:error code:CLKErrorRequiredOptionNotProvided description:@"--delta: required option not provided"];
    
    XCTAssertFalse([validator validateOption:delta error:nil]);
    
    /* free (not required) */
    
    error = nil;
    XCTAssertTrue([validator validateOption:echo error:&error]);
    XCTAssertNil(error);
    
    error = nil;
    XCTAssertTrue([validator validateOption:foxtrot error:&error]);
    XCTAssertNil(error);
}

@end
