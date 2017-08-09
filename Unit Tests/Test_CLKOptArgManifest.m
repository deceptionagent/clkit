//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CLKOption.h"
#import "CLKOptArgManifest.h"
#import "CLKOptArgManifest_Private.h"


@interface Test_CLKOptArgManifest : XCTestCase

@end


@implementation Test_CLKOptArgManifest

- (void)testFreeOptions
{
    CLKOption *flarn = [CLKOption freeOptionWithName:@"flarn" flag:nil];
    CLKOption *barf = [CLKOption freeOptionWithName:@"barf" flag:@"b"];
    CLKOption *payloadOption = [CLKOption optionWithName:@"payload" flag:@"p"];
    CLKOptArgManifest *manifest = [[[CLKOptArgManifest alloc] init] autorelease];
    
    // payload options and positional arguments should not affect free options
    [manifest accumulateArgument:@"foo" forOption:payloadOption];
    [manifest accumulatePositionalArgument:@"barf"];
    
    XCTAssertNil(manifest.freeOptions[@"flarn"]);
    
    [manifest accumulateFreeOption:flarn];
    XCTAssertEqualObjects(manifest.freeOptions[@"flarn"], @(1));
    XCTAssertNil(manifest.freeOptions[@"barf"]);
    
    [manifest accumulateFreeOption:flarn];
    [manifest accumulateFreeOption:barf];
    XCTAssertEqualObjects(manifest.freeOptions[@"flarn"], @(2));
    XCTAssertEqualObjects(manifest.freeOptions[@"barf"], @(1));
}

- (void)testOptArgPairs
{
    CLKOption *freeOption = [CLKOption freeOptionWithName:@"free" flag:@"f"];
    CLKOption *lorem = [CLKOption optionWithName:@"lorem" flag:@"l"];
    CLKOption *ipsum = [CLKOption optionWithName:@"ipsum" flag:nil];
    CLKOption *solo = [CLKOption optionWithName:@"solo" flag:nil];
    CLKOptArgManifest *manifest = [[[CLKOptArgManifest alloc] init] autorelease];
    
    // free options and positional arguments should not affect optarg pairs
    [manifest accumulateFreeOption:freeOption];
    [manifest accumulatePositionalArgument:@"positional"];
    
    XCTAssertNil(manifest.optionArguments[@"lorem"]);
    
    [manifest accumulateArgument:@"alpha" forOption:lorem];
    [manifest accumulateArgument:@"bravo" forOption:lorem];
    [manifest accumulateArgument:@"echo" forOption:ipsum];
    [manifest accumulateArgument:@"echo" forOption:ipsum];
    [manifest accumulateArgument:@"foxtrot" forOption:solo];
    XCTAssertEqualObjects(manifest.optionArguments[@"lorem"], (@[ @"alpha", @"bravo" ]));
    XCTAssertEqualObjects(manifest.optionArguments[@"ipsum"], (@[ @"echo", @"echo" ]));
    XCTAssertEqualObjects(manifest.optionArguments[@"solo"], @[ @"foxtrot" ]);
    XCTAssertNil(manifest.optionArguments[@"flarn"]);
}

- (void)testPositionalArguments
{
    CLKOption *payloadOption = [CLKOption optionWithName:@"payload" flag:@"p"];
    CLKOption *freeOption = [CLKOption freeOptionWithName:@"free" flag:@"f"];
    CLKOptArgManifest *manifest = [[[CLKOptArgManifest alloc] init] autorelease];
    
    // free options and payload options should not affect positional arguments
    [manifest accumulateArgument:@"flarn" forOption:payloadOption];
    [manifest accumulateFreeOption:freeOption];
    
    XCTAssertEqualObjects(manifest.positionalArguments, @[]);
    
    [manifest accumulatePositionalArgument:@"alpha"];
    [manifest accumulatePositionalArgument:@"bravo"];
    [manifest accumulatePositionalArgument:@"alpha"];
    XCTAssertEqualObjects(manifest.positionalArguments, (@[ @"alpha", @"bravo", @"alpha"]));
}

- (void)testAccumulationGuards
{
    CLKOption *payloadOption = [CLKOption optionWithName:@"payload" flag:@"p"];
    CLKOption *freeOption = [CLKOption freeOptionWithName:@"free" flag:@"f"];
    CLKOptArgManifest *manifest = [[[CLKOptArgManifest alloc] init] autorelease];
    
    XCTAssertThrowsSpecificNamed([manifest accumulateArgument:@"flarn" forOption:freeOption], NSException, NSInvalidArgumentException);
    XCTAssertThrowsSpecificNamed([manifest accumulateFreeOption:payloadOption], NSException, NSInvalidArgumentException);
}

@end
