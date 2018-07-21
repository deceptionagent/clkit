//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <sysexits.h>

#import "CLKCommandResult.h"
#import "CLKArgumentManifest_Private.h"
#import "CLKOption.h"
#import "CLKVerb.h"
#import "CLKVerbDepot.h"
#import "StuntVerb.h"
#import "NSError+CLKAdditions.h"
#import "XCTestCase+CLKAdditions.h"


NS_ASSUME_NONNULL_BEGIN

@interface Test_CLKVerbDepot : XCTestCase

- (void)_performDispatchTestWithDepot:(CLKVerbDepot *)depot expectedResult:(CLKCommandResult *)expectedResult;
- (void)_performDispatchTestWithDepot:(CLKVerbDepot *)depot expectedVerb:(NSString *)expectedVerb expectedManifest:(CLKArgumentManifest *)expectedManifest;

@end

NS_ASSUME_NONNULL_END


@implementation Test_CLKVerbDepot

- (void)_performDispatchTestWithDepot:(CLKVerbDepot *)depot expectedResult:(CLKCommandResult *)expectedResult
{
    CLKCommandResult *result = [depot dispatchVerb];
    XCTAssertNotNil(result);
    XCTAssertEqual(result.exitStatus, expectedResult.exitStatus);
    XCTAssertEqualObjects(result.errors, expectedResult.errors);
    XCTAssertNil(result.userInfo);
}

- (void)_performDispatchTestWithDepot:(CLKVerbDepot *)depot expectedVerb:(NSString *)expectedVerb expectedManifest:(CLKArgumentManifest *)expectedManifest
{
    CLKCommandResult *result = [depot dispatchVerb];
    XCTAssertNotNil(result);
    XCTAssertEqual(result.exitStatus, 0);
    XCTAssertNil(result.errors);
    XCTAssertEqualObjects(result.userInfo[@"verb"], expectedVerb);
    
    CLKArgumentManifest *manifest = result.userInfo[@"manifest"];
    XCTAssertEqualObjects(manifest.optionManifest, expectedManifest.optionManifest);
    XCTAssertEqualObjects(manifest.positionalArguments, expectedManifest.positionalArguments);
}

#pragma mark -

- (void)testInit
{
    NSArray *argv = @[ @"flarn", @"--barf" ];
    NSArray *verbs = @[
        [StuntVerb flarnVerb],
        [StuntVerb quoneVerb]
    ];
    
    CLKVerbDepot *depot = [[[CLKVerbDepot alloc] initWithArgumentVector:argv verbs:verbs] autorelease];
    XCTAssertNotNil(depot);
    
    depot = [[[CLKVerbDepot alloc] initWithArgumentVector:@[] verbs:verbs] autorelease];
    XCTAssertNotNil(depot);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    XCTAssertThrows([[[CLKVerbDepot alloc] initWithArgumentVector:nil verbs:verbs] autorelease]);
    XCTAssertThrows([[[CLKVerbDepot alloc] initWithArgumentVector:argv verbs:nil] autorelease]);
    XCTAssertThrows([[[CLKVerbDepot alloc] initWithArgumentVector:argv verbs:@[]] autorelease]);
#pragma clang diagnostic pop
}

- (void)testInit_collisionGuard
{
    NSArray *argv = @[ @"flarn", @"--barf" ];
    NSArray *verbs = @[
        [StuntVerb flarnVerb],
        [StuntVerb quoneVerb],
        [StuntVerb flarnVerb]
    ];
    
    XCTAssertThrows([[[CLKVerbDepot alloc] initWithArgumentVector:argv verbs:verbs] autorelease]);
    
/* [future: when case-insensitive lookup is implemented] */
//
//    verbs = @[
//        [[[StuntVerb alloc] initWithName:@"flarn" help:@"" pubilc:YES options:nil optionGroups:nil] autorelease],
//        [[[StuntVerb alloc] initWithName:@"FLARN" help:@"" pubilc:YES options:nil optionGroups:nil] autorelease],
//    ];
//
//    XCTAssertThrows([[[CLKVerbDepot alloc] initWithArgumentVector:argv verbs:verbs] autorelease]);
}

- (void)test_dispatchVerb_emptyArgumentVector
{
    NSArray *verbs = @[ [StuntVerb flarnVerb] ];
    NSError *expectedError = [NSError clk_CLKErrorWithCode:CLKErrorNoVerbSpecified description:@"No verb specified."];
    CLKCommandResult *expectedResult = [CLKCommandResult resultWithExitStatus:EX_USAGE errors:@[ expectedError ]];
    
    CLKVerbDepot *depot = [[[CLKVerbDepot alloc] initWithArgumentVector:@[] verbs:verbs] autorelease];
    [self _performDispatchTestWithDepot:depot expectedResult:expectedResult];
}

- (void)test_dispatchVerb_unrecognizedVerb
{
    NSArray *verbs = @[ [StuntVerb flarnVerb] ];
    NSError *expectedError = [NSError clk_CLKErrorWithCode:CLKErrorUnrecognizedVerb description:@"barf: Unrecognized verb."];
    CLKCommandResult *expectedResult = [CLKCommandResult resultWithExitStatus:EX_USAGE errors:@[ expectedError ]];
    
    CLKVerbDepot *depot = [[[CLKVerbDepot alloc] initWithArgumentVector:@[ @"barf" ] verbs:verbs] autorelease];
    [self _performDispatchTestWithDepot:depot expectedResult:expectedResult];
    
    depot = [[[CLKVerbDepot alloc] initWithArgumentVector:@[ @"barf", @"--quone" ] verbs:verbs] autorelease];
    [self _performDispatchTestWithDepot:depot expectedResult:expectedResult];

    expectedError = [NSError clk_CLKErrorWithCode:CLKErrorUnrecognizedVerb description:@"--quone: Unrecognized verb."];
    expectedResult = [CLKCommandResult resultWithExitStatus:EX_USAGE errors:@[ expectedError ]];
    depot = [[[CLKVerbDepot alloc] initWithArgumentVector:@[ @"--quone", @"barf" ] verbs:verbs] autorelease];
    [self _performDispatchTestWithDepot:depot expectedResult:expectedResult];
}

- (void)test_dispatchVerb_optionlessVerb
{
    NSArray *verbs = @[ [StuntVerb verbWithName:@"xyzzy" options:nil] ];
    
    CLKArgumentManifest *expectedManifest = [self manifestWithSwitchOptions:nil parameterOptions:nil];
    CLKVerbDepot *depot = [[[CLKVerbDepot alloc] initWithArgumentVector:@[ @"xyzzy" ] verbs:verbs] autorelease];
    [self _performDispatchTestWithDepot:depot expectedVerb:@"xyzzy" expectedManifest:expectedManifest];
    
    NSError *expectedError = [NSError clk_POSIXErrorWithCode:EINVAL description:@"unrecognized option: '--barf'"];
    CLKCommandResult *expectedResult = [CLKCommandResult resultWithExitStatus:EX_USAGE errors:@[ expectedError ]];
    depot = [[[CLKVerbDepot alloc] initWithArgumentVector:@[ @"xyzzy", @"--barf" ] verbs:verbs] autorelease];
    [self _performDispatchTestWithDepot:depot expectedResult:expectedResult];
}

- (void)test_dispatchVerb_verbWithOptions
{
    CLKOption *barf = [CLKOption optionWithName:@"barf" flag:@"b"];
    CLKOption *xyzzy = [CLKOption optionWithName:@"xyzzy" flag:@"x"];
    NSArray *verbs = @[
        [StuntVerb verbWithName:@"flarn" options:@[ barf ]],
        [StuntVerb verbWithName:@"quone" options:@[ xyzzy ]]
    ];
    
    CLKArgumentManifest *expectedManifest = [self manifestWithSwitchOptions:@{ xyzzy : @(1) } parameterOptions:nil];
    CLKVerbDepot *depot = [[[CLKVerbDepot alloc] initWithArgumentVector:@[ @"quone", @"--xyzzy" ] verbs:verbs] autorelease];
    [self _performDispatchTestWithDepot:depot expectedVerb:@"quone" expectedManifest:expectedManifest];
    
    NSError *expectedError = [NSError clk_POSIXErrorWithCode:EINVAL description:@"unrecognized option: '--what'"];
    CLKCommandResult *expectedResult = [CLKCommandResult resultWithExitStatus:EX_USAGE errors:@[ expectedError ]];
    depot = [[[CLKVerbDepot alloc] initWithArgumentVector:@[ @"flarn", @"--what" ] verbs:verbs] autorelease];
    [self _performDispatchTestWithDepot:depot expectedResult:expectedResult];
}

@end
