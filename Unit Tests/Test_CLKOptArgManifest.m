//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CLKOptArgManifest.h"


@interface Test_CLKOptArgManifest : XCTestCase

@end


@implementation Test_CLKOptArgManifest

- (void)testFreeOptions
{
    CLKOptArgManifest *manifest = [[[CLKOptArgManifest alloc] init] autorelease];
    
    // optarg pairs and remainder arguments should not affect free options
    [manifest accumulateArgument:@"foo" forOptionNamed:@"bar"];
    [manifest accumulateRemainderArgument:@"barf"];
    
    XCTAssertNil(manifest.freeOptions[@"flarn"]);
    
    [manifest accumulateFreeOptionNamed:@"flarn"];
    XCTAssertEqualObjects(manifest.freeOptions[@"flarn"], @(1));
    XCTAssertNil(manifest.freeOptions[@"barf"]);
    
    [manifest accumulateFreeOptionNamed:@"flarn"];
    [manifest accumulateFreeOptionNamed:@"barf"];
    XCTAssertEqualObjects(manifest.freeOptions[@"flarn"], @(2));
    XCTAssertEqualObjects(manifest.freeOptions[@"barf"], @(1));
}

- (void)testOptArgPairs
{
    CLKOptArgManifest *manifest = [[[CLKOptArgManifest alloc] init] autorelease];
    
    // free options and remainder arguments should not affect optarg pairs
    [manifest accumulateFreeOptionNamed:@"free"];
    [manifest accumulateRemainderArgument:@"remainder"];
    
    XCTAssertNil(manifest.optionArguments[@"lorem"]);
    
    [manifest accumulateArgument:@"alpha" forOptionNamed:@"lorem"];
    [manifest accumulateArgument:@"bravo" forOptionNamed:@"lorem"];
    [manifest accumulateArgument:@"charlie" forOptionNamed:@"ipsum"];
    [manifest accumulateArgument:@"delta" forOptionNamed:@"ipsum"];
    [manifest accumulateArgument:@"echo" forOptionNamed:@"dolor"];
    [manifest accumulateArgument:@"echo" forOptionNamed:@"dolor"];
    [manifest accumulateArgument:@"foxtrot" forOptionNamed:@"solo"];
    XCTAssertEqualObjects(manifest.optionArguments[@"lorem"], (@[ @"alpha", @"bravo" ]));
    XCTAssertEqualObjects(manifest.optionArguments[@"ipsum"], (@[ @"charlie", @"delta" ]));
    XCTAssertEqualObjects(manifest.optionArguments[@"dolor"], (@[ @"echo", @"echo" ]));
    XCTAssertEqualObjects(manifest.optionArguments[@"solo"], @[ @"foxtrot" ]);
    XCTAssertNil(manifest.optionArguments[@"flarn"]);
}

- (void)testRemainderArguments
{
    CLKOptArgManifest *manifest = [[[CLKOptArgManifest alloc] init] autorelease];
    
    // free options and optarg pairs should not affect remainder arguments
    [manifest accumulateArgument:@"foo" forOptionNamed:@"bar"];
    [manifest accumulateFreeOptionNamed:@"flarn"];
    
    XCTAssertEqualObjects(manifest.remainderArguments, @[]);
    
    [manifest accumulateRemainderArgument:@"alpha"];
    [manifest accumulateRemainderArgument:@"bravo"];
    [manifest accumulateRemainderArgument:@"alpha"];
    XCTAssertEqualObjects(manifest.remainderArguments, (@[ @"alpha", @"bravo", @"alpha"]));
}

@end
