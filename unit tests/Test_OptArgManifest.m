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
    
    XCTAssertFalse([manifest freeOptionEnabled:@"flarn"]);
    XCTAssertEqual([manifest freeOptionCount:@"flarn"], 0);
    
    [manifest accumulateFreeOption:@"flarn"];
    XCTAssertTrue([manifest freeOptionEnabled:@"flarn"]);
    XCTAssertEqual([manifest freeOptionCount:@"flarn"], 1);
    XCTAssertFalse([manifest freeOptionEnabled:@"barf"]);
    XCTAssertEqual([manifest freeOptionCount:@"barf"], 0);
    
    [manifest accumulateFreeOption:@"flarn"];
    [manifest accumulateFreeOption:@"barf"];
    XCTAssertTrue([manifest freeOptionEnabled:@"flarn"]);
    XCTAssertEqual([manifest freeOptionCount:@"flarn"], 2);
    XCTAssertTrue([manifest freeOptionEnabled:@"barf"]);
    XCTAssertEqual([manifest freeOptionCount:@"barf"], 1);
}

- (void)testOptArgPairs
{
    OptArgManifest *manifest = [[[OptArgManifest alloc] init] autorelease];
    
    // free options and remainder arguments should not affect optarg pairs
    [manifest accumulateFreeOption:@"free"];
    [manifest accumulateRemainderArgument:@"remainder"];
    
    XCTAssertNil([manifest argumentsForOption:@"lorem"]);
    
    [manifest accumulateArgument:@"alpha" forOption:@"lorem"];
    [manifest accumulateArgument:@"bravo" forOption:@"lorem"];
    [manifest accumulateArgument:@"charlie" forOption:@"ipsum"];
    [manifest accumulateArgument:@"delta" forOption:@"ipsum"];
    [manifest accumulateArgument:@"echo" forOption:@"dolor"];
    [manifest accumulateArgument:@"echo" forOption:@"dolor"];
    [manifest accumulateArgument:@"foxtrot" forOption:@"solo"];

    NSArray *argumentListLorem = [manifest argumentsForOption:@"lorem"];
    NSArray *argumentListIpsum = [manifest argumentsForOption:@"ipsum"];
    NSArray *argumentListDolor = [manifest argumentsForOption:@"dolor"];
    NSArray *argumentListSolo = [manifest argumentsForOption:@"solo"];
    NSArray *expectedArgumentListLorem = @[ @"alpha", @"bravo" ];
    NSArray *expectedArgumentListIpsum = @[ @"charlie", @"delta" ];
    NSArray *expectedArgumentListDolor = @[ @"echo", @"echo" ];
    NSArray *expectedArgumentListSolo = @[ @"foxtrot" ];
    
    XCTAssertEqualObjects(argumentListLorem, expectedArgumentListLorem);
    XCTAssertEqualObjects(argumentListIpsum, expectedArgumentListIpsum);
    XCTAssertEqualObjects(argumentListDolor, expectedArgumentListDolor);
    XCTAssertEqualObjects(argumentListSolo, expectedArgumentListSolo);
    XCTAssertNil([manifest argumentsForOption:@"flarn"]);
}

- (void)testRemainderArguments
{
    OptArgManifest *manifest = [[[OptArgManifest alloc] init] autorelease];
    
    // free options and optarg pairs should not affect remainder arguments
    [manifest accumulateArgument:@"foo" forOption:@"bar"];
    [manifest accumulateFreeOption:@"flarn"];
    
    XCTAssertNil(manifest.remainderArguments);
    
    [manifest accumulateRemainderArgument:@"alpha"];
    [manifest accumulateRemainderArgument:@"bravo"];
    [manifest accumulateRemainderArgument:@"alpha"];
    
    NSArray *expectedRemainderArguments = @[
        @"alpha",
        @"bravo",
        @"alpha"
    ];
    
    XCTAssertEqualObjects(manifest.remainderArguments, expectedRemainderArguments);
}

@end
