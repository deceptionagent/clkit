//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "OptArgManifest.h"


@interface Test_OptArgManifest : XCTestCase

@end


@implementation Test_OptArgManifest

- (void)testFreeOptions
{
    OptArgManifest *manifest = [[[OptArgManifest alloc] init] autorelease];
    
    // optarg pairs and remainder arguments should not affect free options
    [manifest accumulateArgument:@"foo" forOption:@"bar"];
    [manifest accumulateRemainderArgument:@"barf"];
    
    XCTAssertNil(manifest.freeOptions[@"flarn"]);
    
    [manifest accumulateFreeOption:@"flarn"];
    XCTAssertEqualObjects(manifest.freeOptions[@"flarn"], @(1));
    XCTAssertNil(manifest.freeOptions[@"barf"]);
    
    [manifest accumulateFreeOption:@"flarn"];
    [manifest accumulateFreeOption:@"barf"];
    XCTAssertEqualObjects(manifest.freeOptions[@"flarn"], @(2));
    XCTAssertEqualObjects(manifest.freeOptions[@"barf"], @(1));
}

- (void)testOptArgPairs
{
    OptArgManifest *manifest = [[[OptArgManifest alloc] init] autorelease];
    
    // free options and remainder arguments should not affect optarg pairs
    [manifest accumulateFreeOption:@"free"];
    [manifest accumulateRemainderArgument:@"remainder"];
    
    XCTAssertNil(manifest.optionArguments[@"lorem"]);
    
    [manifest accumulateArgument:@"alpha" forOption:@"lorem"];
    [manifest accumulateArgument:@"bravo" forOption:@"lorem"];
    [manifest accumulateArgument:@"charlie" forOption:@"ipsum"];
    [manifest accumulateArgument:@"delta" forOption:@"ipsum"];
    [manifest accumulateArgument:@"echo" forOption:@"dolor"];
    [manifest accumulateArgument:@"echo" forOption:@"dolor"];
    [manifest accumulateArgument:@"foxtrot" forOption:@"solo"];
    XCTAssertEqualObjects(manifest.optionArguments[@"lorem"], (@[ @"alpha", @"bravo" ]));
    XCTAssertEqualObjects(manifest.optionArguments[@"ipsum"], (@[ @"charlie", @"delta" ]));
    XCTAssertEqualObjects(manifest.optionArguments[@"dolor"], (@[ @"echo", @"echo" ]));
    XCTAssertEqualObjects(manifest.optionArguments[@"solo"], @[ @"foxtrot" ]);
    XCTAssertNil(manifest.optionArguments[@"flarn"]);
}

- (void)testRemainderArguments
{
    OptArgManifest *manifest = [[[OptArgManifest alloc] init] autorelease];
    
    // free options and optarg pairs should not affect remainder arguments
    [manifest accumulateArgument:@"foo" forOption:@"bar"];
    [manifest accumulateFreeOption:@"flarn"];
    
    XCTAssertEqualObjects(manifest.remainderArguments, @[]);
    
    [manifest accumulateRemainderArgument:@"alpha"];
    [manifest accumulateRemainderArgument:@"bravo"];
    [manifest accumulateRemainderArgument:@"alpha"];
    XCTAssertEqualObjects(manifest.remainderArguments, (@[ @"alpha", @"bravo", @"alpha"]));
}

@end
