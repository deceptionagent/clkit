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
    IntegerArgumentTransformer *transformer = [IntegerArgumentTransformer transformer];
    
    NSError *error = nil;
    NSNumber *num = [transformer transformedArgument:@"0" error:&error];
    XCTAssertEqual(num.longValue, 0);
    XCTAssertNil(error);
    
    error = nil;
    num = [transformer transformedArgument:@"666" error:&error];
    XCTAssertEqual(num.longValue, 666);
    XCTAssertNil(error);
    
    error = nil;
    num = [transformer transformedArgument:@"-666" error:&error];
    XCTAssertEqual(num.longValue, -666);
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

- (void)testFloatArgumentTransformer
{
    FloatArgumentTransformer *transformer = [FloatArgumentTransformer transformer];
    
    NSError *error = nil;
    NSNumber *num = [transformer transformedArgument:@"0.7" error:&error];
    XCTAssertEqual(num.floatValue, 0.70000F);
    XCTAssertNil(error);
    
    error = nil;
    num = [transformer transformedArgument:@"8.19" error:&error];
    XCTAssertEqual(num.floatValue, 8.190000F);
    XCTAssertNil(error);
    
    error = nil;
    num = [transformer transformedArgument:@"7" error:&error];
    XCTAssertEqual(num.floatValue, 7.000000F);
    XCTAssertNil(error);
    
    error = nil;
    num = [transformer transformedArgument:@"6.6.6" error:&error];
    XCTAssertNil(num);
    XCTAssertNotNil(error);
    
    error = nil;
    num = [transformer transformedArgument:@"barf" error:&error];
    XCTAssertNil(num);
    XCTAssertNotNil(error);
    
    error = nil;
    num = [transformer transformedArgument:@"6.66barf" error:&error];
    XCTAssertNil(num);
    XCTAssertNotNil(error);
    
    error = nil;
    num = [transformer transformedArgument:@"barf6.66" error:&error];
    XCTAssertNil(num);
    XCTAssertNotNil(error);
    
    num = [transformer transformedArgument:@"barf" error:nil];
    XCTAssertNil(num);
}

@end



