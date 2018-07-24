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
#import "CLKVerbFamily.h"
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
    NSArray *argv = @[ @"flarn", @"--alpha" ];
    NSArray *verbs = @[
        [StuntVerb flarnVerb],
        [StuntVerb quoneVerb]
    ];
    
    CLKVerbDepot *depot = [[[CLKVerbDepot alloc] initWithArgumentVector:argv verbs:verbs] autorelease];
    XCTAssertNotNil(depot);
    
    depot = [[[CLKVerbDepot alloc] initWithArgumentVector:@[] verbs:verbs] autorelease];
    XCTAssertNotNil(depot);
    
    depot = [[[CLKVerbDepot alloc] initWithArgumentVector:@[] verbs:verbs verbFamilies:nil] autorelease];
    XCTAssertNotNil(depot);
    
    depot = [[[CLKVerbDepot alloc] initWithArgumentVector:@[] verbs:verbs verbFamilies:@[]] autorelease];
    XCTAssertNotNil(depot);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    XCTAssertThrows([[[CLKVerbDepot alloc] initWithArgumentVector:nil verbs:verbs] autorelease]);
    XCTAssertThrows([[[CLKVerbDepot alloc] initWithArgumentVector:argv verbs:nil] autorelease]);
    XCTAssertThrows([[[CLKVerbDepot alloc] initWithArgumentVector:argv verbs:@[]] autorelease]);
#pragma clang diagnostic pop
}

- (void)testInit_families
{
    NSArray *topLevelVerbs = @[
        [StuntVerb flarnVerb],
        [StuntVerb quoneVerb]
    ];
    
    NSArray *confoundFamilyVerbs = @[
        [StuntVerb quoneVerb],
        [StuntVerb xyzzyVerb]
    ];
    
    NSArray *deliveryFamilyVerbs = @[
        [StuntVerb synVerb],
        [StuntVerb ackVerb]
    ];
    
    NSArray *families = @[
        [CLKVerbFamily familyWithName:@"confound" verbs:confoundFamilyVerbs]
    ];
    
    CLKVerbDepot *depot = [[[CLKVerbDepot alloc] initWithArgumentVector:@[] verbs:topLevelVerbs verbFamilies:families] autorelease];
    XCTAssertNotNil(depot);
    
    families = @[
        [CLKVerbFamily familyWithName:@"confound" verbs:confoundFamilyVerbs],
        [CLKVerbFamily familyWithName:@"delivery" verbs:deliveryFamilyVerbs]
    ];
    
    depot = [[[CLKVerbDepot alloc] initWithArgumentVector:@[] verbs:topLevelVerbs verbFamilies:families] autorelease];
    XCTAssertNotNil(depot);

    // [TACK] should this be allowed?
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    XCTAssertThrows([[[CLKVerbDepot alloc] initWithArgumentVector:@[] verbs:nil verbFamilies:families] autorelease]);
#pragma clang diagnostic pop
}

- (void)testVerbFamilyCollision
{
    NSArray *topLevelVerbs = @[
        [StuntVerb flarnVerb]
    ];
    
    NSArray *deliveryFamilyVerbs = @[
        [StuntVerb barfVerb]
    ];
    
    NSArray *confoundFamilyVerbsAlpha = @[
        [StuntVerb quoneVerb],
        [StuntVerb xyzzyVerb]
    ];
    
    NSArray *confoundFamilyVerbsBravo = @[
        [StuntVerb synVerb],
        [StuntVerb ackVerb]
    ];
    
    NSArray *families = @[
        [CLKVerbFamily familyWithName:@"confound" verbs:confoundFamilyVerbsAlpha],
        [CLKVerbFamily familyWithName:@"delivery" verbs:deliveryFamilyVerbs],
        [CLKVerbFamily familyWithName:@"confound" verbs:confoundFamilyVerbsBravo]
    ];
    
    XCTAssertThrows([[[CLKVerbDepot alloc] initWithArgumentVector:@[] verbs:topLevelVerbs verbFamilies:families] autorelease]);
}

- (void)testVerbFamilyAndTopLevelVerbCollision
{
    NSArray *topLevelVerbs = @[
        [StuntVerb flarnVerb],
        [StuntVerb barfVerb]
    ];
    
    NSArray *confoundFamilyVerbs = @[
        [StuntVerb quoneVerb],
    ];
    
    NSArray *confoundFamilyVerbsAlpha = @[
        [StuntVerb synVerb],
        [StuntVerb barfVerb],
        [StuntVerb ackVerb]
    ];
    
    NSArray *families = @[
        [CLKVerbFamily familyWithName:@"confound" verbs:confoundFamilyVerbs],
        [CLKVerbFamily familyWithName:@"delivery" verbs:confoundFamilyVerbsAlpha],
    ];
    
    XCTAssertThrows([[[CLKVerbDepot alloc] initWithArgumentVector:@[] verbs:topLevelVerbs verbFamilies:families] autorelease]);
}

- (void)test_dispatchVerb_emptyArgumentVector
{
    NSArray *verbs = @[ [StuntVerb flarnVerb] ];
    NSError *expectedError = [NSError clk_CLKErrorWithCode:CLKErrorNoVerbSpecified description:@"No verb specified."];
    CLKCommandResult *expectedResult = [CLKCommandResult resultWithExitStatus:EX_USAGE errors:@[ expectedError ]];
    
    CLKVerbDepot *depot = [[[CLKVerbDepot alloc] initWithArgumentVector:@[] verbs:verbs] autorelease];
    [self _performDispatchTestWithDepot:depot expectedResult:expectedResult];

    NSArray *familyVerbs = @[
        [StuntVerb barfVerb]
    ];
    
    CLKVerbFamily *family = [CLKVerbFamily familyWithName:@"quone" verbs:familyVerbs];
    depot = [[[CLKVerbDepot alloc] initWithArgumentVector:@[] verbs:verbs verbFamilies:@[ family ]] autorelease];
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
    CLKOption *alpha = [CLKOption optionWithName:@"alpha" flag:@"a"];
    CLKOption *bravo = [CLKOption optionWithName:@"bravo" flag:@"b"];
    NSArray *verbs = @[
        [StuntVerb verbWithName:@"flarn" options:@[ alpha ]],
        [StuntVerb verbWithName:@"barf" options:@[ bravo ]]
    ];
    
    CLKArgumentManifest *expectedManifest = [self manifestWithSwitchOptions:@{ alpha : @(1) } parameterOptions:nil];
    CLKVerbDepot *depot = [[[CLKVerbDepot alloc] initWithArgumentVector:@[ @"flarn", @"--alpha" ] verbs:verbs] autorelease];
    [self _performDispatchTestWithDepot:depot expectedVerb:@"flarn" expectedManifest:expectedManifest];

    expectedManifest = [self manifestWithSwitchOptions:@{ bravo : @(1) } parameterOptions:nil];
    depot = [[[CLKVerbDepot alloc] initWithArgumentVector:@[ @"barf", @"--bravo" ] verbs:verbs] autorelease];
    [self _performDispatchTestWithDepot:depot expectedVerb:@"barf" expectedManifest:expectedManifest];
    
    NSError *expectedError = [NSError clk_POSIXErrorWithCode:EINVAL description:@"unrecognized option: '--what'"];
    CLKCommandResult *expectedResult = [CLKCommandResult resultWithExitStatus:EX_USAGE errors:@[ expectedError ]];
    depot = [[[CLKVerbDepot alloc] initWithArgumentVector:@[ @"flarn", @"--what" ] verbs:verbs] autorelease];
    [self _performDispatchTestWithDepot:depot expectedResult:expectedResult];
}

@end
