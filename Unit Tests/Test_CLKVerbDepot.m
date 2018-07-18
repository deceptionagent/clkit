//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CLKVerb.h"
#import "CLKVerbDepot.h"
#import "StuntVerb.h"


@interface Test_CLKVerbDepot : XCTestCase

@end

@implementation Test_CLKVerbDepot

- (void)testInit
{
    NSArray *argv = @[ @"flarn", @"--barf" ];
    NSArray<id<CLKVerb>> *verbs = @[
        [StuntVerb flarnVerb],
        [StuntVerb quoneVerb]
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
}

- (void)testInit_collisionGuard
{
    NSArray *argv = @[ @"flarn", @"--barf" ];
    NSArray<id<CLKVerb>> *verbs = @[
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

@end
