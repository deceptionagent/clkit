//
//  Created by mikey on 28/6/17.
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "Option.h"
#import "OptArgManifest.h"
#import "OptArgParser.h"


NS_ASSUME_NONNULL_BEGIN

@interface Test_OptArgParser : XCTestCase

- (void)performTestWithArgv:(NSArray<NSString *> *)argv
                    options:(NSArray<Option *> *)options
        expectedFreeOptions:(NSDictionary<NSString *, NSNumber *> *)expectedFreeOptions
    expectedOptionArguments:(NSDictionary<NSString *, NSArray *> *)expectedOptionArguments
 expectedRemainderArguments:(NSArray<NSString *> *)expectedRemainderArguments;

@end

NS_ASSUME_NONNULL_END


@implementation Test_OptArgParser

- (void)performTestWithArgv:(NSArray<NSString *> *)argv
                    options:(NSArray<Option *> *)options
        expectedFreeOptions:(NSDictionary<NSString *, NSNumber *> *)expectedFreeOptions
    expectedOptionArguments:(NSDictionary<NSString *, NSArray *> *)expectedOptionArguments
 expectedRemainderArguments:(NSArray<NSString *> *)expectedRemainderArguments
{
    OptArgParser *parser = [OptArgParser parserWithArgumentVector:argv options:options];
    NSError *error = nil;
    OptArgManifest *manifest = [parser parseArguments:&error];
    XCTAssertNotNil(manifest);
    XCTAssertNil(error);
    XCTAssertEqualObjects(manifest.freeOptions, expectedFreeOptions);
    XCTAssertEqualObjects(manifest.optionArguments, expectedOptionArguments);
    XCTAssertEqualObjects(manifest.remainderArguments, expectedRemainderArguments);
}

#pragma mark -

- (void)testInit
{
    NSArray *argv = @[ @"--flarn" ];
    NSArray *options = @[
         [Option freeOptionWithLongName:@"barf" shortName:@"b"],
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
         [Option optionWithLongName:@"foo" shortName:@"f"],
    ];
    
    [self performTestWithArgv:@[] options:options expectedFreeOptions:@{} expectedOptionArguments:@{} expectedRemainderArguments:@[]];
}

- (void)testUnrecognizedOption
{
    NSArray *argv = @[ @"--foo", @"flarn" ];
    NSArray *options = @[
         [Option freeOptionWithLongName:@"bar" shortName:@"b"],
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
        [Option freeOptionWithLongName:@"foo" shortName:@"f"],
        [Option freeOptionWithLongName:@"bar" shortName:@"b"]
    ];
    
    NSDictionary *expectedFreeOptions = @{
        @"foo" : @(2),
        @"bar" : @(1)
    };
    
    [self performTestWithArgv:argv options:options expectedFreeOptions:expectedFreeOptions expectedOptionArguments:@{} expectedRemainderArguments:@[]];
}

- (void)testOptionArguments
{
    NSArray *argv = @[ @"--foo", @"alpha", @"-f", @"bravo", @"-b", @"charlie" ];
    NSArray *options = @[
        [Option optionWithLongName:@"foo" shortName:@"f"],
        [Option optionWithLongName:@"bar" shortName:@"b"]
    ];
    
    NSDictionary *expectedOptionArguments = @{
        @"foo" : @[ @"alpha", @"bravo" ],
        @"bar" : @[ @"charlie" ]
    };
    
    [self performTestWithArgv:argv options:options expectedFreeOptions:@{} expectedOptionArguments:expectedOptionArguments expectedRemainderArguments:@[]];
}

- (void)testRemainderArguments
{
    NSArray *argv = @[ @"--foo", @"bar", @"/flarn.txt", @"/bort.txt" ];
    NSArray *options = @[
        [Option optionWithLongName:@"foo" shortName:@"f"],
    ];
    
    NSDictionary *expectedOptionArguments = @{
        @"foo" : @[ @"bar" ]
    };
    
    NSArray *expectedRemainderArguments = @[ @"/flarn.txt", @"/bort.txt" ];
    [self performTestWithArgv:argv options:options expectedFreeOptions:@{} expectedOptionArguments:expectedOptionArguments expectedRemainderArguments:expectedRemainderArguments];
}

- (void)testRemainderArgumentsOnly
{
    NSArray *argv = @[ @"/flarn.txt", @"/bort.txt" ];
    NSArray *options = @[
        [Option optionWithLongName:@"foo" shortName:@"f"],
        [Option optionWithLongName:@"bar" shortName:@"b"]
    ];
    
    [self performTestWithArgv:argv options:options expectedFreeOptions:@{} expectedOptionArguments:@{} expectedRemainderArguments:argv];
}

- (void)testRemainderArgumentsOnly_noParserOptions
{
    NSArray *argv = @[ @"alpha", @"bravo", @"charlie" ];
    [self performTestWithArgv:argv options:@[] expectedFreeOptions:@{} expectedOptionArguments:@{} expectedRemainderArguments:argv];
}

- (void)testOptionArgumentNotProvided
{
    NSArray *argv = @[ @"--foo", @"--bar", @"what" ];
    NSArray *options = @[
        [Option optionWithLongName:@"foo" shortName:@"f"],
        [Option optionWithLongName:@"bar" shortName:@"b"]
    ];
    
    OptArgParser *parser = [OptArgParser parserWithArgumentVector:argv options:options];
    NSError *error = nil;
    OptArgManifest *manifest = [parser parseArguments:&error];
    XCTAssertNil(manifest);
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, EINVAL);
    XCTAssertEqualObjects(error.localizedDescription, @"expected argument but encountered option-like token '--bar'");
}

- (void)testComplexMix
{
    NSArray *argv = @[ @"acme", @"--syn", @"aeons", @"--xyzzy", @"thrud", @"-a", @"hack", @"-x", @"-xpx", @"--syn", @"cathedra", @"confound", @"delivery" ];
    NSArray *options = @[
         [Option optionWithLongName:@"syn" shortName:@"s"],
         [Option optionWithLongName:@"ack" shortName:@"a"],
         [Option optionWithLongName:@"ghost" shortName:@"g"], // not provided in argv
         [Option freeOptionWithLongName:@"xyzzy" shortName:@"x"],
         [Option freeOptionWithLongName:@"spline" shortName:@"p"],
    ];
    
    NSDictionary *expectedFreeOptions = @{
        @"xyzzy" : @(4),
        @"spline" : @(1)
    };
    
    NSDictionary *expectedOptionArguments = @{
        @"syn" : @[ @"aeons", @"cathedra" ],
        @"ack" : @[ @"hack" ]
    };
    
    NSArray *expectedRemainderArguments = @[ @"acme", @"thrud", @"confound", @"delivery" ];
    [self performTestWithArgv:argv options:options expectedFreeOptions:expectedFreeOptions expectedOptionArguments:expectedOptionArguments expectedRemainderArguments:expectedRemainderArguments];
}

@end
