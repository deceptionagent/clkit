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

- (void)test_clk_containsCharacterFromSet_range
{
    NSCharacterSet *charset = [NSCharacterSet characterSetWithCharactersInString:@"!"];
    XCTAssertTrue([@"?!?" clk_containsCharacterFromSet:charset range:NSMakeRange(0, 3)]);
    XCTAssertTrue([@"?!?" clk_containsCharacterFromSet:charset range:NSMakeRange(1, 1)]);
    XCTAssertFalse([@"!?!" clk_containsCharacterFromSet:charset range:NSMakeRange(1, 1)]);
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

- (void)test_clk_tokenType
{
    XCTAssertEqual(@"--x".clk_tokenKind, CLKTokenKindOptionName);
    XCTAssertEqual(@"--flarn".clk_tokenKind, CLKTokenKindOptionName);
    XCTAssertEqual(@"--syn-ack".clk_tokenKind, CLKTokenKindOptionName);
    XCTAssertEqual(@"--syn--ack".clk_tokenKind, CLKTokenKindOptionName);
    XCTAssertEqual(@"--syn.ack".clk_tokenKind, CLKTokenKindOptionName);
    XCTAssertEqual(@"--.syn.ack.".clk_tokenKind, CLKTokenKindOptionName);
    XCTAssertEqual(@"--what-".clk_tokenKind, CLKTokenKindOptionName);
    XCTAssertEqual(@"--what--".clk_tokenKind, CLKTokenKindOptionName);
    XCTAssertEqual(@"--what?".clk_tokenKind, CLKTokenKindOptionName);
    XCTAssertEqual(@"--se7en".clk_tokenKind, CLKTokenKindOptionName);
    XCTAssertEqual(@"--420".clk_tokenKind, CLKTokenKindOptionName);
    XCTAssertEqual(@"--barƒ".clk_tokenKind, CLKTokenKindOptionName);
    XCTAssertEqual(@"---".clk_tokenKind, CLKTokenKindOptionName);
    
    XCTAssertEqual(@"-a".clk_tokenKind, CLKTokenKindOptionFlag);
    XCTAssertEqual(@"-Z".clk_tokenKind, CLKTokenKindOptionFlag);
    XCTAssertEqual(@"-?".clk_tokenKind, CLKTokenKindOptionFlag);
    XCTAssertEqual(@"-π".clk_tokenKind, CLKTokenKindOptionFlag);
    
    XCTAssertEqual(@"-xy".clk_tokenKind, CLKTokenKindOptionFlagSet);
    XCTAssertEqual(@"-xYz".clk_tokenKind, CLKTokenKindOptionFlagSet);
    XCTAssertEqual(@"-πƒ".clk_tokenKind, CLKTokenKindOptionFlagSet);
    
    XCTAssertEqual(@"--".clk_tokenKind, CLKTokenKindOptionParsingSentinel);
    
    XCTAssertEqual(@" ".clk_tokenKind, CLKTokenKindArgument);
    XCTAssertEqual(@"   ".clk_tokenKind, CLKTokenKindArgument);
    XCTAssertEqual(@"-".clk_tokenKind, CLKTokenKindArgument);
    XCTAssertEqual(@"flarn".clk_tokenKind, CLKTokenKindArgument);
    XCTAssertEqual(@"w-hat".clk_tokenKind, CLKTokenKindArgument);
    XCTAssertEqual(@" -x".clk_tokenKind, CLKTokenKindArgument);
    XCTAssertEqual(@" --flarn".clk_tokenKind, CLKTokenKindArgument);
    
    XCTAssertEqual(@"-7".clk_tokenKind, CLKTokenKindArgument);
    XCTAssertEqual(@"-420".clk_tokenKind, CLKTokenKindArgument);
    
    XCTAssertEqual(@"-42.0".clk_tokenKind, CLKTokenKindArgument);
    XCTAssertEqual(@"-0.420".clk_tokenKind, CLKTokenKindArgument);
    XCTAssertEqual(@"-00.420".clk_tokenKind, CLKTokenKindArgument);
    XCTAssertEqual(@"-4.2.0".clk_tokenKind, CLKTokenKindArgument);
    XCTAssertEqual(@"-4..2..0".clk_tokenKind, CLKTokenKindArgument);
    XCTAssertEqual(@"-.420".clk_tokenKind, CLKTokenKindArgument);
    XCTAssertEqual(@"-420.".clk_tokenKind, CLKTokenKindArgument);
    
    XCTAssertEqual(@"-42:0".clk_tokenKind, CLKTokenKindArgument);
    XCTAssertEqual(@"-0:420".clk_tokenKind, CLKTokenKindArgument);
    XCTAssertEqual(@"-00:420".clk_tokenKind, CLKTokenKindArgument);
    XCTAssertEqual(@"-4:2:0".clk_tokenKind, CLKTokenKindArgument);
    XCTAssertEqual(@"-4::2::0".clk_tokenKind, CLKTokenKindArgument);
    XCTAssertEqual(@"-:420".clk_tokenKind, CLKTokenKindArgument);
    XCTAssertEqual(@"-420:".clk_tokenKind, CLKTokenKindArgument);
    
    XCTAssertEqual(@"-4.2:0".clk_tokenKind, CLKTokenKindArgument);
    XCTAssertEqual(@"-4.2.0:7:7".clk_tokenKind, CLKTokenKindArgument);
    
    XCTAssertEqual(@"".clk_tokenKind, CLKTokenKindInvalid);
    XCTAssertEqual(@"- ".clk_tokenKind, CLKTokenKindInvalid);
    XCTAssertEqual(@"-  ".clk_tokenKind, CLKTokenKindInvalid);
    XCTAssertEqual(@"-- ".clk_tokenKind, CLKTokenKindInvalid);
    XCTAssertEqual(@"--   ".clk_tokenKind, CLKTokenKindInvalid);
    XCTAssertEqual(@"- -".clk_tokenKind, CLKTokenKindInvalid);
    XCTAssertEqual(@"-x ".clk_tokenKind, CLKTokenKindInvalid);
    XCTAssertEqual(@"- x".clk_tokenKind, CLKTokenKindInvalid);
    XCTAssertEqual(@"--flarn ".clk_tokenKind, CLKTokenKindInvalid);
    XCTAssertEqual(@"-- flarn".clk_tokenKind, CLKTokenKindInvalid);
    XCTAssertEqual(@"-- flarn ".clk_tokenKind, CLKTokenKindInvalid);
    XCTAssertEqual(@"-- w hat ".clk_tokenKind, CLKTokenKindInvalid);
    XCTAssertEqual(@"-x7z".clk_tokenKind, CLKTokenKindInvalid);
    XCTAssertEqual(@"-7x7".clk_tokenKind, CLKTokenKindInvalid);
    XCTAssertEqual(@"-7yz".clk_tokenKind, CLKTokenKindInvalid);
    XCTAssertEqual(@"-xy7".clk_tokenKind, CLKTokenKindInvalid);
}

@end
