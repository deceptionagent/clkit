//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "ArgumentTransformer.h"


@interface Test_ArgumentTransformer : XCTestCase

@end


@implementation Test_ArgumentTransformer

- (void)testIntegerArgumentTransformer
{
    IntegerArgumentTransformer *transformer = [[[IntegerArgumentTransformer alloc] init] autorelease];
    
    NSError *error = nil;
    NSNumber *num = [transformer transformedArgument:@"0" error:&error];
    XCTAssertEqualObjects(num, @(0));
    XCTAssertNil(error);
    
    error = nil;
    num = [transformer transformedArgument:@"666" error:&error];
    XCTAssertEqualObjects(num, @(666));
    XCTAssertNil(error);
    
    error = nil;
    num = [transformer transformedArgument:@"-666" error:&error];
    XCTAssertEqualObjects(num, @(-666));
    XCTAssertNil(error);
    
    error = nil;
    num = [transformer transformedArgument:@"6.66" error:&error];
    XCTAssertNil(num);
    XCTAssertNotNil(error);
    
    error = nil;
    num = [transformer transformedArgument:@"barf" error:&error];
    XCTAssertNil(num);
    XCTAssertNotNil(error);
    
    error = nil;
    num = [transformer transformedArgument:@"666barf" error:&error];
    XCTAssertNil(num);
    XCTAssertNotNil(error);
    
    error = nil;
    num = [transformer transformedArgument:@"barf666" error:&error];
    XCTAssertNil(num);
    XCTAssertNotNil(error);
    
    num = [transformer transformedArgument:@"barf" error:nil];
    XCTAssertNil(num);
}

@end
