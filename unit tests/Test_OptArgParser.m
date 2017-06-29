//
//  Created by mikey on 28/6/17.
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "Option.h"
#import "OptArgManifest.h"
#import "OptArgParser.h"


@interface Test_OptArgParser : XCTestCase

@end


@implementation Test_OptArgParser

- (void)testInit
{
    NSArray *argv = @[ @"--flarn" ];
    NSArray *options = @[
         [Option optionWithLongName:@"barf" shortName:@"b" hasArgument:NO],
    ];
    
    XCTAssertNotNil([OptArgParser parserWithArgumentVector:argv options:options]);
    XCTAssertNotNil([OptArgParser parserWithArgumentVector:argv options:@[]]);
    XCTAssertNotNil([OptArgParser parserWithArgumentVector:argv options:@[]]);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    XCTAssertThrows([OptArgParser parserWithArgumentVector:nil options:nil]);
    XCTAssertThrows([OptArgParser parserWithArgumentVector:nil options:options]);
    XCTAssertThrows([OptArgParser parserWithArgumentVector:argv options:nil]);
#pragma clang diagnostic pop
}

- (void)testEmptyArgv
{
    NSArray *options = @[
         [Option optionWithLongName:@"foo" shortName:@"f" hasArgument:YES],
    ];
    
    OptArgParser *parser = [OptArgParser parserWithArgumentVector:@[] options:options];
    
    NSError *error = nil;
    OptArgManifest *manifest = [parser parseArguments:&error];
    XCTAssertNotNil(manifest);
    XCTAssertNil(error);
    XCTAssertEqualObjects(manifest.freeOptions, @{});
    XCTAssertEqualObjects(manifest.optionArguments, @{});
    XCTAssertEqualObjects(manifest.remainderArguments, @[]);
}

- (void)testUnrecognizedOption
{
    NSArray *argv = @[ @"--foo", @"flarn" ];
    NSArray *options = @[
         [Option optionWithLongName:@"bar" shortName:@"b" hasArgument:NO],
    ];
    
    OptArgParser *parser = [OptArgParser parserWithArgumentVector:argv options:options];
    
    NSError *error = nil;
    OptArgManifest *manifest = [parser parseArguments:&error];
    XCTAssertNil(manifest);
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, EINVAL);
    XCTAssertEqualObjects(error.domain, NSPOSIXErrorDomain);
    XCTAssertEqualObjects(error.localizedDescription, @"unrecognized option: 'foo'");
}

- (void)testFreeOptions
{
    NSArray *argv = @[ @"--foo", @"-f", @"-b" ];
    NSArray *options = @[
        [Option optionWithLongName:@"foo" shortName:@"f" hasArgument:NO],
        [Option optionWithLongName:@"bar" shortName:@"b" hasArgument:NO]
    ];
    
    OptArgParser *parser = [OptArgParser parserWithArgumentVector:argv options:options];
    
    NSError *error = nil;
    OptArgManifest *manifest = [parser parseArguments:&error];
    XCTAssertNotNil(manifest);
    XCTAssertNil(error);
    
    NSDictionary *expectedFreeOptions = @{
        @"foo" : @(2),
        @"bar" : @(1)
    };
    
    XCTAssertEqualObjects(manifest.freeOptions, expectedFreeOptions);
    XCTAssertEqualObjects(manifest.optionArguments, @{});
    XCTAssertEqualObjects(manifest.remainderArguments, @[]);
}

- (void)testOptionArguments
{
    NSArray *argv = @[ @"--foo", @"alpha", @"-f", @"bravo", @"-b", @"charlie"];
    NSArray *options = @[
        [Option optionWithLongName:@"foo" shortName:@"f" hasArgument:YES],
        [Option optionWithLongName:@"bar" shortName:@"b" hasArgument:YES]
    ];
    
    OptArgParser *parser = [OptArgParser parserWithArgumentVector:argv options:options];
    
    NSError *error = nil;
    OptArgManifest *manifest = [parser parseArguments:&error];
    XCTAssertNotNil(manifest);
    XCTAssertNil(error);
    
    NSDictionary *expectedOptionArguments = @{
        @"foo" : @[ @"alpha", @"bravo" ],
        @"bar" : @[ @"charlie" ]
    };
    
    XCTAssertEqualObjects(manifest.freeOptions, @{});
    XCTAssertEqualObjects(manifest.optionArguments, expectedOptionArguments);
    XCTAssertEqualObjects(manifest.remainderArguments, @[]);
}

- (void)testRemainderArguments
{
    NSArray *argv = @[ @"--foo", @"bar", @"/flarn.txt", @"/bort.txt"];
    NSArray *options = @[
        [Option optionWithLongName:@"foo" shortName:@"f" hasArgument:YES],
    ];
    
    OptArgParser *parser = [OptArgParser parserWithArgumentVector:argv options:options];
    
    NSError *error = nil;
    OptArgManifest *manifest = [parser parseArguments:&error];
    XCTAssertNotNil(manifest);
    XCTAssertNil(error);
    
    NSDictionary *expectedOptionArguments = @{
        @"foo" : @[ @"bar" ]
    };
    
    NSArray *expectedRemainderArguments = @[ @"/flarn.txt", @"/bort.txt" ];
    
    XCTAssertEqualObjects(manifest.freeOptions, @{});
    XCTAssertEqualObjects(manifest.optionArguments, expectedOptionArguments);
    XCTAssertEqualObjects(manifest.remainderArguments, expectedRemainderArguments);
}

- (void)testRemainderArgumentsOnly
{
    NSArray *argv = @[ @"/flarn.txt", @"/bort.txt"];
    NSArray *options = @[
        [Option optionWithLongName:@"foo" shortName:@"f" hasArgument:YES],
        [Option optionWithLongName:@"bar" shortName:@"b" hasArgument:YES]
    ];
    
    OptArgParser *parser = [OptArgParser parserWithArgumentVector:argv options:options];
    
    NSError *error = nil;
    OptArgManifest *manifest = [parser parseArguments:&error];
    XCTAssertNotNil(manifest);
    XCTAssertNil(error);
    
    XCTAssertEqualObjects(manifest.freeOptions, @{});
    XCTAssertEqualObjects(manifest.optionArguments, @{});
    XCTAssertEqualObjects(manifest.remainderArguments, argv);
}

- (void)testRemainderArgumentsOnly_noParserOptions
{
    NSArray *argv = @[ @"alpha", @"bravo", @"charlie" ];
    OptArgParser *parser = [OptArgParser parserWithArgumentVector:argv options:@[]];
    
    NSError *error = nil;
    OptArgManifest *manifest = [parser parseArguments:&error];
    XCTAssertNotNil(manifest);
    XCTAssertNil(error);
    XCTAssertEqualObjects(manifest.freeOptions, @{});
    XCTAssertEqualObjects(manifest.optionArguments, @{});
    XCTAssertEqualObjects(manifest.remainderArguments, argv);
}

- (void)testComplexMix
{
    NSArray *argv = @[ @"acme", @"--syn", @"aeons", @"--xyzzy", @"thrud", @"-a", @"hack", @"-x", @"-xpx", @"--syn", @"cathedra", @"confound", @"delivery"];
    NSArray *options = @[
         [Option optionWithLongName:@"syn" shortName:@"s" hasArgument:YES],
         [Option optionWithLongName:@"ack" shortName:@"a" hasArgument:YES],
         [Option optionWithLongName:@"ghost" shortName:@"g" hasArgument:YES], // not provided in argv
         [Option optionWithLongName:@"xyzzy" shortName:@"x" hasArgument:NO],
         [Option optionWithLongName:@"spline" shortName:@"p" hasArgument:NO],
    ];
    
    OptArgParser *parser = [OptArgParser parserWithArgumentVector:argv options:options];
    
    NSError *error = nil;
    OptArgManifest *manifest = [parser parseArguments:&error];
    XCTAssertNotNil(manifest);
    XCTAssertNil(error);
    
    NSDictionary *expectedFreeOptions = @{
        @"xyzzy" : @(4),
        @"spline" : @(1)
    };
    
    NSDictionary *expectedOptionArguments = @{
        @"syn" : @[ @"aeons", @"cathedra" ],
        @"ack" : @[ @"hack" ]
    };
    
    NSArray *expectedRemainderArguments = @[ @"acme", @"thrud", @"confound", @"delivery" ];
    
    XCTAssertEqualObjects(manifest.freeOptions, expectedFreeOptions);
    XCTAssertEqualObjects(manifest.optionArguments, expectedOptionArguments);
    XCTAssertEqualObjects(manifest.remainderArguments, expectedRemainderArguments);
}

@end
