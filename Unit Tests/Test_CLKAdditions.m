//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CLKError.h"
#import "NSArray+CLKAdditions.h"
#import "NSCharacterSet+CLKAdditions.h"
#import "NSError+CLKAdditions.h"
#import "NSMutableArray+CLKAdditions.h"
#import "NSString+CLKAdditions.h"
#import "XCTestCase+CLKAdditions.h"


@interface Test_NSArray_CLKAdditions : XCTestCase

@end

@implementation Test_NSArray_CLKAdditions

- (void)test_clk_arrayWithArgv_argc
{
    const char *argvAlpha[] = { "alpha" };
    NSArray *alpha = [NSArray clk_arrayWithArgv:argvAlpha argc:1];
    XCTAssertEqualObjects(alpha, @[ @"alpha" ]);
    
    const char *argvBravo[] = { "alpha", "bravo" };
    NSArray *bravo = [NSArray clk_arrayWithArgv:argvBravo argc:2];
    XCTAssertEqualObjects(bravo, (@[ @"alpha", @"bravo" ]));
    
    const char *argvCharlie[] = {};
    NSArray *charlie = [NSArray clk_arrayWithArgv:argvCharlie argc:0];
    XCTAssertNotNil(charlie);
    XCTAssertEqual(charlie.count, 0UL);
}

@end

#pragma mark -

@interface Test_NSCharacterSet_CLKAdditions : XCTestCase

@end

@implementation Test_NSCharacterSet_CLKAdditions

- (void)test_clk_numericArgumentCharacterSet
{
    NSCharacterSet *charset = NSCharacterSet.clk_numericArgumentCharacterSet;
    XCTAssertNotNil(charset);
    XCTAssertEqual(charset, NSCharacterSet.clk_numericArgumentCharacterSet);
    XCTAssertTrue([charset characterIsMember:'.']);
    XCTAssertTrue([charset characterIsMember:':']);
    XCTAssertTrue([charset characterIsMember:'0']);
    XCTAssertTrue([charset characterIsMember:'1']);
    XCTAssertTrue([charset characterIsMember:'2']);
    XCTAssertTrue([charset characterIsMember:'3']);
    XCTAssertTrue([charset characterIsMember:'4']);
    XCTAssertTrue([charset characterIsMember:'5']);
    XCTAssertTrue([charset characterIsMember:'6']);
    XCTAssertTrue([charset characterIsMember:'7']);
    XCTAssertTrue([charset characterIsMember:'8']);
    XCTAssertTrue([charset characterIsMember:'9']);
    XCTAssertFalse([charset characterIsMember:'x']);
    XCTAssertFalse([charset characterIsMember:' ']);
    XCTAssertFalse([charset characterIsMember:'-']);
    XCTAssertFalse([charset characterIsMember:'$']);
}

@end

#pragma mark -

@interface Test_NSError_CLKAdditions : XCTestCase

@end

@implementation Test_NSError_CLKAdditions

- (void)test_clk_POSIXErrorWithCode_description
{
    NSError *error = [NSError clk_POSIXErrorWithCode:ENOENT description:@"404 flarn not found"];
    [self verifyError:error domain:NSPOSIXErrorDomain code:ENOENT description:@"404 flarn not found"];
    
    error = [NSError clk_POSIXErrorWithCode:ENOENT description:@"404 %@ not found", @"flarn"];
    [self verifyError:error domain:NSPOSIXErrorDomain code:ENOENT description:@"404 flarn not found"];
}

- (void)test_clk_CLKErrorWithCode_description
{
    NSError *error = [NSError clk_CLKErrorWithCode:CLKErrorRequiredOptionNotProvided description:@"404 flarn not found"];
    [self verifyError:error domain:CLKErrorDomain code:CLKErrorRequiredOptionNotProvided description:@"404 flarn not found"];
    
    error = [NSError clk_CLKErrorWithCode:CLKErrorRequiredOptionNotProvided description:@"404 %@ not found", @"flarn"];
    [self verifyError:error domain:CLKErrorDomain code:CLKErrorRequiredOptionNotProvided description:@"404 flarn not found"];
}

@end

#pragma mark -

@interface Test_NSMutableArray_CLKAdditions : XCTestCase

@end

@implementation Test_NSMutableArray_CLKAdditions

- (void)test_clk_popLastObject
{
    NSMutableArray *alpha = [[@[ @"alpha" ] mutableCopy] autorelease];
    XCTAssertEqualObjects([alpha clk_popFirstObject], @"alpha");
    XCTAssertEqual(alpha.count, 0UL);
    
    NSMutableArray *bravo = [[@[ @"alpha", @"bravo" ] mutableCopy] autorelease];
    XCTAssertEqualObjects([bravo clk_popFirstObject], @"alpha");
    XCTAssertEqualObjects(bravo, @[ @"bravo" ]);
    
    NSMutableArray *charlie = [NSMutableArray array];
    XCTAssertNil([charlie clk_popFirstObject]);
    XCTAssertEqual(charlie.count, 0UL);
}

@end

#pragma mark -

@interface Test_NSString_CLKAdditions : XCTestCase

@end

@implementation Test_NSString_CLKAdditions

- (void)test_clk_containsCharacterFromSet
{
    NSCharacterSet *charset = [NSCharacterSet characterSetWithCharactersInString:@"!"];
    XCTAssertFalse([@"" clk_containsCharacterFromSet:charset]);
    XCTAssertFalse([@"?" clk_containsCharacterFromSet:charset]);
    XCTAssertTrue([@"!" clk_containsCharacterFromSet:charset]);
    XCTAssertTrue([@"?!?" clk_containsCharacterFromSet:charset]);
    XCTAssertFalse([@"???" clk_containsCharacterFromSet:charset]);
}

- (void)test_clk_containsCharacterFromSet_range
{
    NSCharacterSet *charset = [NSCharacterSet characterSetWithCharactersInString:@"!"];
    XCTAssertFalse([@"" clk_containsCharacterFromSet:charset range:NSMakeRange(0, 0)]);
    XCTAssertFalse([@"?" clk_containsCharacterFromSet:charset range:NSMakeRange(0, 0)]);
    XCTAssertFalse([@"!" clk_containsCharacterFromSet:charset range:NSMakeRange(0, 0)]);
    XCTAssertFalse([@"?" clk_containsCharacterFromSet:charset range:NSMakeRange(0, 1)]);
    XCTAssertTrue([@"!" clk_containsCharacterFromSet:charset range:NSMakeRange(0, 1)]);
    XCTAssertTrue([@"?!?" clk_containsCharacterFromSet:charset range:NSMakeRange(0, 3)]);
    XCTAssertTrue([@"?!?" clk_containsCharacterFromSet:charset range:NSMakeRange(1, 1)]);
    XCTAssertFalse([@"!?!" clk_containsCharacterFromSet:charset range:NSMakeRange(1, 1)]);
}

- (void)test_clk_resemblesOptionArgumentToken
{
    XCTFail(@"unimplemented test");
}

- (void)test_clk_isNumericToken
{
    // leading-dash variants are generated from this list
    NSArray *nonMatchInputs = @[
        @"",
        @" ",
        @".",
        @". ",
        @":",
        @": ",
        @":.",
        @"..",
        @"::",
        @"q",
        @".q",
        @"q:",
        @"xyz",
        @"0x0",
        @".0x0",
        @"0x0:",
        @"$100.00"
    ];
    
    for (NSString *token in nonMatchInputs) {
        XCTAssertFalse(token.clk_isNumericArgumentToken, @"token: '%@'", token);
        NSString *dashToken = [@"-" stringByAppendingString:token];
        XCTAssertFalse(dashToken.clk_isNumericArgumentToken, @"dashToken: '%@'", dashToken);
    }
    
    // leading-dash variants are generated from this list
    NSArray *matchInputs = @[
        @"1",
        @"234",
        @".5",
        @"5.",
        @"0.6",
        @"000.666",
        @"7.0",
        @"777.000",
        @":7",
        @"7:",
        @"8:0",
        @".9.",
        @":10:",
        @"7..7",
        @"7::7",
        @"7.7.7:7"
    ];
    
    for (NSString *token in matchInputs) {
        XCTAssertTrue(token.clk_isNumericArgumentToken, @"token: '%@'", token);
        NSString *dashToken = [@"-" stringByAppendingString:token];
        XCTAssertTrue(dashToken.clk_isNumericArgumentToken, @"dashToken: '%@'", dashToken);
    }
}

- (void)testTokenKindProperties
{
    #define TEST_TOKEN(token, expectedKind) \
    { \
        CLKArgumentTokenKind kind = token.clk_argumentTokenKind; \
        XCTAssertEqual(kind, expectedKind, @"(token: '%@')", token); \
        if (kind == CLKArgumentTokenKindOptionName \
            || kind == CLKArgumentTokenKindOptionFlag \
            || kind == CLKArgumentTokenKindOptionFlagSet \
            || kind == CLKArgumentTokenKindMalformedOption ) \
        { \
            XCTAssertTrue(token.clk_resemblesOptionArgumentToken); \
        } else { \
            XCTAssertFalse(token.clk_resemblesOptionArgumentToken); \
        } \
    }
    
    TEST_TOKEN(@"--x", CLKArgumentTokenKindOptionName);
    TEST_TOKEN(@"--flarn", CLKArgumentTokenKindOptionName);
    TEST_TOKEN(@"--syn-ack", CLKArgumentTokenKindOptionName);
    TEST_TOKEN(@"--syn--ack", CLKArgumentTokenKindOptionName);
    TEST_TOKEN(@"--syn.ack", CLKArgumentTokenKindOptionName);
    TEST_TOKEN(@"--.syn.ack.", CLKArgumentTokenKindOptionName);
    TEST_TOKEN(@"--what-", CLKArgumentTokenKindOptionName);
    TEST_TOKEN(@"--what--", CLKArgumentTokenKindOptionName);
    TEST_TOKEN(@"--what?", CLKArgumentTokenKindOptionName);
    TEST_TOKEN(@"--se7en", CLKArgumentTokenKindOptionName);
    TEST_TOKEN(@"--420", CLKArgumentTokenKindOptionName);
    TEST_TOKEN(@"--barƒ", CLKArgumentTokenKindOptionName);
    TEST_TOKEN(@"---", CLKArgumentTokenKindOptionName);
    
    TEST_TOKEN(@"-a", CLKArgumentTokenKindOptionFlag);
    TEST_TOKEN(@"-Z", CLKArgumentTokenKindOptionFlag);
    TEST_TOKEN(@"-?", CLKArgumentTokenKindOptionFlag);
    TEST_TOKEN(@"-π", CLKArgumentTokenKindOptionFlag);
    
    TEST_TOKEN(@"-xy", CLKArgumentTokenKindOptionFlagSet);
    TEST_TOKEN(@"-xYz", CLKArgumentTokenKindOptionFlagSet);
    TEST_TOKEN(@"-πƒ", CLKArgumentTokenKindOptionFlagSet);
    
    TEST_TOKEN(@"--", CLKArgumentTokenKindOptionParsingSentinel);
    
    TEST_TOKEN(@"", CLKArgumentTokenKindArgument);
    TEST_TOKEN(@" ", CLKArgumentTokenKindArgument);
    TEST_TOKEN(@"   ", CLKArgumentTokenKindArgument);
    TEST_TOKEN(@"-", CLKArgumentTokenKindArgument);
    TEST_TOKEN(@"flarn", CLKArgumentTokenKindArgument);
    TEST_TOKEN(@"w-hat", CLKArgumentTokenKindArgument);
    TEST_TOKEN(@" -x", CLKArgumentTokenKindArgument);
    TEST_TOKEN(@" --flarn", CLKArgumentTokenKindArgument);
    
    TEST_TOKEN(@"-7", CLKArgumentTokenKindArgument);
    TEST_TOKEN(@"-420", CLKArgumentTokenKindArgument);
    
    TEST_TOKEN(@"-42.0", CLKArgumentTokenKindArgument);
    TEST_TOKEN(@"-0.420", CLKArgumentTokenKindArgument);
    TEST_TOKEN(@"-00.420", CLKArgumentTokenKindArgument);
    TEST_TOKEN(@"-4.2.0", CLKArgumentTokenKindArgument);
    TEST_TOKEN(@"-4..2..0", CLKArgumentTokenKindArgument);
    TEST_TOKEN(@"-.420", CLKArgumentTokenKindArgument);
    TEST_TOKEN(@"-420.", CLKArgumentTokenKindArgument);
    
    TEST_TOKEN(@"-42:0", CLKArgumentTokenKindArgument);
    TEST_TOKEN(@"-0:420", CLKArgumentTokenKindArgument);
    TEST_TOKEN(@"-00:420", CLKArgumentTokenKindArgument);
    TEST_TOKEN(@"-4:2:0", CLKArgumentTokenKindArgument);
    TEST_TOKEN(@"-4::2::0", CLKArgumentTokenKindArgument);
    TEST_TOKEN(@"-:420", CLKArgumentTokenKindArgument);
    TEST_TOKEN(@"-420:", CLKArgumentTokenKindArgument);
    
    TEST_TOKEN(@"-4.2:0", CLKArgumentTokenKindArgument);
    TEST_TOKEN(@"-4.2.0:7:7", CLKArgumentTokenKindArgument);
    
    TEST_TOKEN(@"- ", CLKArgumentTokenKindMalformedOption);
    TEST_TOKEN(@"-  ", CLKArgumentTokenKindMalformedOption);
    TEST_TOKEN(@"-- ", CLKArgumentTokenKindMalformedOption);
    TEST_TOKEN(@"--   ", CLKArgumentTokenKindMalformedOption);
    TEST_TOKEN(@"- -", CLKArgumentTokenKindMalformedOption);
    TEST_TOKEN(@"-x ", CLKArgumentTokenKindMalformedOption);
    TEST_TOKEN(@"- x", CLKArgumentTokenKindMalformedOption);
    TEST_TOKEN(@"--flarn ", CLKArgumentTokenKindMalformedOption);
    TEST_TOKEN(@"-- flarn", CLKArgumentTokenKindMalformedOption);
    TEST_TOKEN(@"-- flarn ", CLKArgumentTokenKindMalformedOption);
    TEST_TOKEN(@"-- w hat ", CLKArgumentTokenKindMalformedOption);
    TEST_TOKEN(@"-x7z", CLKArgumentTokenKindMalformedOption);
    TEST_TOKEN(@"-7x7", CLKArgumentTokenKindMalformedOption);
    TEST_TOKEN(@"-7yz", CLKArgumentTokenKindMalformedOption);
    TEST_TOKEN(@"-xy7", CLKArgumentTokenKindMalformedOption);
}

@end
