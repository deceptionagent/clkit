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

- (void)testFlarn
{
    NSArray *argv = @[ @"--foo", @"flarn", @"-b", @"hack", @"-b", @"-bab", @"barf"];
    NSArray *options = @[
         [Option optionWithLongName:@"foo" shortName:@"f" hasArgument:YES],
         [Option optionWithLongName:@"bar" shortName:@"b" hasArgument:NO],
         [Option optionWithLongName:@"ack" shortName:@"a" hasArgument:NO],
    ];
    
    OptArgParser *parser = [OptArgParser parserWithArgumentVector:argv options:options];
    NSError *error = nil;
    OptArgManifest *manifest = [parser parseArguments:&error];
    NSArray *fooArgs = [manifest argumentsForOption:@"foo"];
    uint32_t ackCount = [manifest freeOptionCount:@"ack"];
    uint32_t barCount = [manifest freeOptionCount:@"bar"];
    NSArray *remainders = manifest.remainderArguments;
    printf("*\n");
}

@end
