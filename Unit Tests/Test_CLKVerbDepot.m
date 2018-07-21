//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <sysexits.h>

#import "CLKCommandResult.h"
#import "CLKVerb.h"
#import "CLKVerbDepot.h"
#import "StuntVerb.h"
#import "NSError+CLKAdditions.h"


NS_ASSUME_NONNULL_BEGIN

@interface Test_CLKVerbDepot : XCTestCase

- (void)_performDispatchTestWithDepot:(CLKVerbDepot *)depot expectedResult:(CLKCommandResult *)expectedResult;

@end

NS_ASSUME_NONNULL_END


@implementation Test_CLKVerbDepot

- (void)_performDispatchTestWithDepot:(CLKVerbDepot *)depot expectedResult:(CLKCommandResult *)expectedResult
{
    CLKCommandResult *result = [depot dispatchVerb];
    XCTAssertNotNil(result);
    XCTAssertEqual(result.exitStatus, expectedResult.exitStatus);
    XCTAssertEqualObjects(result.errors, expectedResult.errors);
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

@end
