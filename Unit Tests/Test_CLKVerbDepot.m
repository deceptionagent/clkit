//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CLKVerb.h"
#import "CLKVerbDepot.h"
#import "XCTestCase+CLKAdditions.h"


@interface Test_CLKVerbDepot : XCTestCase

@end


@implementation Test_CLKVerbDepot

- (void)testInit
{
    NSArray *argv = @[ @"flarn", @"--womp" ];
    CLKVerbBlock blok = ^(__unused NSArray *argv_, __unused NSError **outError) { return 0; };
    NSArray *verbs = @[
        [CLKVerb verbWithName:@"flarn" block:blok],
        [CLKVerb verbWithName:@"barf" block:blok]
    ];
    
    CLKVerbDepot *depot = [[[CLKVerbDepot alloc] initWithArgumentVector:argv verbs:verbs] autorelease];
    XCTAssertNotNil(depot);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    XCTAssertThrows([[[CLKVerbDepot alloc] initWithArgumentVector:nil verbs:verbs] autorelease]);
    XCTAssertThrows([[[CLKVerbDepot alloc] initWithArgumentVector:@[] verbs:verbs] autorelease]);
    XCTAssertThrows([[[CLKVerbDepot alloc] initWithArgumentVector:argv verbs:nil] autorelease]);
    XCTAssertThrows([[[CLKVerbDepot alloc] initWithArgumentVector:argv verbs:@[]] autorelease]);
#pragma clang diagnostic pop
    
    NSArray *dupeVerbs = @[
        [CLKVerb verbWithName:@"flarn" block:blok],
        [CLKVerb verbWithName:@"barf" block:blok],
        [CLKVerb verbWithName:@"flarn" block:blok],
    ];
    
    XCTAssertThrows([[[CLKVerbDepot alloc] initWithArgumentVector:argv verbs:dupeVerbs] autorelease]);
}

- (void)testVerbDispatch
{
    NSArray *argv = @[ @"/usr/bin/lol", @"barf", @"--womp" ];
    
    __block BOOL barfRan = NO;
    
    CLKVerb *flarn = [CLKVerb verbWithName:@"flarn" block:^(__unused NSArray *argv_, __unused NSError **outError) {
        XCTFail(@"flarn verb invoked unexpectedly");
        return 0;
    }];
    
    CLKVerb *barf = [CLKVerb verbWithName:@"barf" block:^(NSArray *argv_, NSError **outError) {
        XCTAssertEqualObjects(argv_, @[ @"--womp" ]);
        XCTAssert(outError == nil, @"passed nil to -dispatch:, expected nil outError in verb block");
        XCTAssertFalse(barfRan, @"barf verb unexpectedly invoked twice");
        barfRan = YES;
        return 1;
    }];
    
    NSArray *verbs = @[ flarn, barf ];
    
    CLKVerbDepot *depot = [[[CLKVerbDepot alloc] initWithArgumentVector:argv verbs:verbs] autorelease];
    int result = [depot dispatch:nil];
    XCTAssertEqual(result, 1);
    XCTAssertTrue(barfRan);
}

- (void)testCaseInsensitiveVerbDispatch
{
    NSArray *argv = @[ @"/usr/bin/lol", @"fLaRn", @"--womp" ];
    
    __block BOOL flarnRan = NO;
    
    CLKVerb *flarn = [CLKVerb verbWithName:@"FlArN" block:^(NSArray *argv_, NSError **outError) {
        XCTAssertEqualObjects(argv_, @[ @"--womp" ]);
        XCTAssert(outError == nil, @"passed nil to -dispatch:, expected nil outError in verb block");
        XCTAssertFalse(flarnRan, @"flarn verb unexpectedly invoked twice");
        flarnRan = YES;
        return 1;
    }];
    
    CLKVerbDepot *depot = [[[CLKVerbDepot alloc] initWithArgumentVector:argv verbs:@[ flarn ]] autorelease];
    int result = [depot dispatch:nil];
    XCTAssertEqual(result, 1);
    XCTAssertTrue(flarnRan);
}

- (void)testVerbNotFound
{
    NSArray *argv = @[ @"/usr/bin/lol", @"barf", @"--womp" ];
    
    CLKVerb *flarn = [CLKVerb verbWithName:@"flarn" block:^(__unused NSArray *argv_, __unused NSError **outError) {
        XCTFail(@"flarn verb invoked unexpectedly");
        return 0;
    }];
    
    CLKVerbDepot *depot = [[[CLKVerbDepot alloc] initWithArgumentVector:argv verbs:@[ flarn ]] autorelease];
    NSError *error = nil;
    int result = [depot dispatch:&error];;
    XCTAssertEqual(result, 1);
    [self verifyError:error domain:CLKVerbDepotErrorDomain code:404 description:@"verb not found"];
}

- (void)testVerbBlockOutError
{
    NSArray *argv = @[ @"/usr/bin/lol", @"flarn" ];
    
    CLKVerb *flarn = [CLKVerb verbWithName:@"flarn" block:^(__unused NSArray *argv_, NSError **outError) {
        XCTAssert(outError != nil, @"passed nil to -dispatch:, expected nil outError in verb block");
        *outError = [NSError errorWithDomain:CLKVerbDepotErrorDomain code:666 userInfo:@{ @"foo" : @"bar" }];
        return 1;
    }];
    
    CLKVerbDepot *depot = [[[CLKVerbDepot alloc] initWithArgumentVector:argv verbs:@[ flarn ]] autorelease];
    NSError *error = nil;
    int result = [depot dispatch:&error];;
    XCTAssertEqual(result, 1);
    [self verifyError:error domain:CLKVerbDepotErrorDomain code:666 userInfo:@{ @"foo" : @"bar" }];
}

- (void)testVerbCollisionCheck
{
    NSArray *argv = @[ @"/usr/bin/lol", @"flarn" ];
    CLKVerb *flarnA = [CLKVerb verbWithName:@"flarn" block:^(__unused NSArray *argv_, __unused NSError **outError) { return 0; }];
    CLKVerb *flarnB = [CLKVerb verbWithName:@"flarn" block:^(__unused NSArray *argv_, __unused NSError **outError) { return 0; }];
    CLKVerb *flarnC = [CLKVerb verbWithName:@"flArn" block:^(__unused NSArray *argv_, __unused NSError **outError) { return 0; }];
    XCTAssertThrows([[[CLKVerbDepot alloc] initWithArgumentVector:argv verbs:(@[ flarnA, flarnB ])] autorelease]);
    XCTAssertThrows([[[CLKVerbDepot alloc] initWithArgumentVector:argv verbs:(@[ flarnA, flarnC ])] autorelease]);
}

@end
