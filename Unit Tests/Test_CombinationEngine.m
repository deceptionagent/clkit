//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CombinationEngine.h"
#import "XCTestCase+CLKAdditions.h"


NS_ASSUME_NONNULL_BEGIN

@interface Test_CombinationEngine : XCTestCase

- (NSArray<NSDictionary<NSString *, id> *> *)generateCombinationsFromPrototype:(NSDictionary<NSString *, NSArray *> *)prototype;
- (NSArray<NSDictionary<NSString *, id> *> *)generateCombinationsUsingEngine:(CombinationEngine *)engine;
- (void)performTestWithPrototype:(NSDictionary<NSString *, NSArray *> *)prototype;

@end

NS_ASSUME_NONNULL_END


@implementation Test_CombinationEngine

- (NSArray<NSDictionary<NSString *, id> *> *)generateCombinationsFromPrototype:(NSDictionary<NSString *, NSArray *> *)prototype
{
    CombinationEngine *engine = [[[CombinationEngine alloc] initWithPrototype:prototype] autorelease];
    return [self generateCombinationsUsingEngine:engine];
}

- (NSArray<NSDictionary<NSString *, id> *> *)generateCombinationsUsingEngine:(CombinationEngine *)engine
{
    NSMutableArray *combinations = [NSMutableArray array];
    [engine enumerateCombinations:^(NSDictionary<NSString *, id> *combination) {
        [combinations addObject:combination];
    }];
    
    return combinations;
}

- (void)performTestWithPrototype:(NSDictionary<NSString *, NSArray *> *)prototype
{
    NSUInteger expectedCombinationCount = 1;
    for (NSString *key in prototype) {
        expectedCombinationCount *= [prototype[key] count];
    }
    
    NSArray *combinations = [self generateCombinationsFromPrototype:prototype];
    XCTAssertEqual(combinations.count, expectedCombinationCount);
    NSSet *uniqueCombinations = [NSSet setWithArray:combinations];
    XCTAssertEqual(uniqueCombinations.count, expectedCombinationCount);
}

#pragma mark -

- (void)testInit
{
    CombinationEngine *engine = [[[CombinationEngine alloc] initWithPrototype:@{ @"flarn" : @[ @"barf", @"quone" ] }] autorelease];
    XCTAssertNotNil(engine);
    
    XCTAssertThrows([[[CombinationEngine alloc] initWithPrototype:@{}] autorelease]);
    XCTAssertThrows([[[CombinationEngine alloc] initWithPrototype:@{ @"flarn" : @[] }] autorelease]);
}

- (void)testCombinationGeneration
{
    NSDictionary *prototype = @{
        @"flarn" : @[ @(1), @(2), @(3) ],
        @"barf"  : @[ @(4), @(5), @(6) ],
        @"quone" : @[ @(7), @(8), @(9) ]
    };
    
    [self performTestWithPrototype:prototype];
}

- (void)testCombinationGeneration_uneven
{
    NSDictionary *prototype = @{
        @"flarn" : @[ @(1) ],
        @"barf"  : @[ @(2), @(3) ],
        @"quone" : @[ @(4), @(5), @(6) ]
    };
    
    [self performTestWithPrototype:prototype];
}

- (void)testCombinationGeneration_singleKey
{
    NSDictionary *prototype = @{
        @"flarn" : @[ @(1), @(2), @(3) ]
    };
    
    NSArray *expectedCombinations = @[
        @{ @"flarn" : @(1) },
        @{ @"flarn" : @(2) },
        @{ @"flarn" : @(3) }
    ];
    
    NSArray *combinations = [self generateCombinationsFromPrototype:prototype];
    XCTAssertEqualObjects(combinations, expectedCombinations);
}

- (void)testCombinationGeneration_singleKey_singleValue
{
    NSArray *combinations = [self generateCombinationsFromPrototype:@{ @"flarn" : @[ @(1) ] }];
    XCTAssertEqualObjects(combinations, (@[ @{ @"flarn" : @(1) } ]));
}

- (void)testCombinationGeneration_singleCombination
{
    NSDictionary *prototype = @{
        @"flarn" : @[ @(1) ],
        @"barf"  : @[ @(2) ],
        @"quone" : @[ @(3) ]
    };
    
    NSDictionary *expectedCombination = @{
        @"flarn" : @(1),
        @"barf"  : @(2),
        @"quone" : @(3)
    };
    
    NSArray *combinations = [self generateCombinationsFromPrototype:prototype];
    XCTAssertEqualObjects(combinations, @[ expectedCombination ]);
}

- (void)test_CEPrototypeNoValue
{
    NSDictionary *prototype = @{
        @"flarn" : @[ CEPrototypeNoValue, @(2), @(3) ],
        @"barf" : @[ @(7) ]
    };
    
    NSArray *expectedCombinations = @[
        @{ @"barf" : @(7) },
        @{ @"flarn" : @(2), @"barf" : @(7) },
        @{ @"flarn" : @(3), @"barf" : @(7) }
    ];
    
    NSArray *combinations = [self generateCombinationsFromPrototype:prototype];
    XCTAssertEqualObjects(combinations, expectedCombinations);
}

- (void)testDeterministicGeneration
{
    NSDictionary *prototype = @{
        @"flarn" : @[ CEPrototypeNoValue, @(7), @(420) ],
        @"barf" : @[ @"syn", @"ack" ],
        @"quone" : @[ @"ne", @"cede", @"malis" ]
    };
    
    NSArray *combinationsA = [self generateCombinationsFromPrototype:prototype];
    NSArray *combinationsB = [self generateCombinationsFromPrototype:prototype];
    XCTAssertEqualObjects(combinationsA, combinationsB);
}

@end
