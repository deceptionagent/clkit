//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CLKArgumentManifest.h"
#import "CLKArgumentManifest_Private.h"
#import "CLKOption.h"


@interface Test_CLKArgumentManifest : XCTestCase

@end


@implementation Test_CLKArgumentManifest

- (void)testInitDefaults
{
    CLKArgumentManifest *manifest = [[[CLKArgumentManifest alloc] init] autorelease];
    XCTAssertNotNil(manifest.freeOptions);
    XCTAssertEqual(manifest.freeOptions.allKeys.count, 0);
    XCTAssertNotNil(manifest.optionArguments);
    XCTAssertEqual(manifest.optionArguments.allKeys.count, 0);
    XCTAssertNotNil(manifest.positionalArguments);
    XCTAssertEqual(manifest.positionalArguments.count, 0);
}

- (void)testFreeOptions
{
    CLKOption *flarn = [CLKOption freeOptionWithName:@"flarn" flag:nil];
    CLKOption *barf = [CLKOption freeOptionWithName:@"barf" flag:@"b"];
    CLKOption *payloadOption = [CLKOption optionWithName:@"payload" flag:@"p"];
    CLKArgumentManifest *manifest = [[[CLKArgumentManifest alloc] init] autorelease];
    
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

- (void)testPayloadOptions
{
    CLKOption *freeOption = [CLKOption freeOptionWithName:@"free" flag:@"f"];
    CLKOption *lorem = [CLKOption optionWithName:@"lorem" flag:@"l"];
    CLKOption *ipsum = [CLKOption optionWithName:@"ipsum" flag:nil];
    CLKOption *solo = [CLKOption optionWithName:@"solo" flag:nil];
    CLKArgumentManifest *manifest = [[[CLKArgumentManifest alloc] init] autorelease];
    
    // free options and positional arguments should not affect payload options
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
    CLKArgumentManifest *manifest = [[[CLKArgumentManifest alloc] init] autorelease];
    
    // free options and payload options should not affect positional arguments
    [manifest accumulateArgument:@"flarn" forOption:payloadOption];
    [manifest accumulateFreeOption:freeOption];
    
    XCTAssertEqualObjects(manifest.positionalArguments, @[]);
    
    [manifest accumulatePositionalArgument:@"alpha"];
    [manifest accumulatePositionalArgument:@"bravo"];
    [manifest accumulatePositionalArgument:@"alpha"];
    XCTAssertEqualObjects(manifest.positionalArguments, (@[ @"alpha", @"bravo", @"alpha"]));
}

@end
