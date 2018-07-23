//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CLKVerbFamily.h"
#import "StuntVerb.h"


@interface Test_CLKVerbFamily : XCTestCase

@end

@implementation Test_CLKVerbFamily

- (void)testInit
{
    NSArray *verbs = @[ [StuntVerb flarnVerb] ];
    
    CLKVerbFamily *family = [CLKVerbFamily familyWithName:@"confound" verbs:verbs];
    XCTAssertEqualObjects(family.name, @"confound");
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    XCTAssertThrows([CLKVerbFamily familyWithName:nil verbs:verbs]);
    XCTAssertThrows([CLKVerbFamily familyWithName:@"flarn" verbs:nil]);
    XCTAssertThrows([CLKVerbFamily familyWithName:@"flarn" verbs:@[]]);
#pragma clang diagnostic pop
}

- (void)testVerbCollisionGuard
{
    NSArray *verbs = @[
        [StuntVerb flarnVerb],
        [StuntVerb quoneVerb],
        [StuntVerb flarnVerb]
    ];
    
    XCTAssertThrows([CLKVerbFamily familyWithName:@"confound" verbs:verbs]);
    
/* [future: when case-insensitive lookup is implemented] */
//
//    verbs = @[
//        [[[StuntVerb alloc] initWithName:@"flarn" help:@"" pubilc:YES options:nil optionGroups:nil] autorelease],
//        [[[StuntVerb alloc] initWithName:@"FLARN" help:@"" pubilc:YES options:nil optionGroups:nil] autorelease],
//    ];
//
//    XCTAssertThrows([CLKVerbFamily familyWithName:@"confound" verbs:verbs]);
}

- (void)testVerbLookup
{
    StuntVerb *flarn = [StuntVerb flarnVerb];
    StuntVerb *quone = [StuntVerb quoneVerb];
    CLKVerbFamily *family = [CLKVerbFamily familyWithName:@"confound" verbs:@[ flarn, quone ]];
    XCTAssertEqual([family verbNamed:@"flarn"], flarn);
    XCTAssertEqual([family verbNamed:@"quone"], quone);
    XCTAssertNil([family verbNamed:@"FLARN"]);
    XCTAssertNil([family verbNamed:@"xyzzy"]);
}

@end
