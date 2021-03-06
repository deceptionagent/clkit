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

- (void)test_clk_optionFlagCharacterSet
{
    NSCharacterSet *asciiLetters = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"];
    NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    NSCharacterSet *symbols = [NSCharacterSet characterSetWithCharactersInString:@"!@#$%^&,?"];
    
    NSCharacterSet *charset = NSCharacterSet.clk_optionFlagIllegalCharacterSet;
    XCTAssertNotNil(charset);
    XCTAssertEqual(charset, NSCharacterSet.clk_optionFlagIllegalCharacterSet);
    XCTAssertFalse([charset isSupersetOfSet:asciiLetters]);
    XCTAssertFalse([charset isSupersetOfSet:numbers]);
    XCTAssertFalse([charset isSupersetOfSet:symbols]);
    XCTAssertTrue([charset characterIsMember:'-']);
    XCTAssertTrue([charset characterIsMember:'=']);
    XCTAssertTrue([charset characterIsMember:':']);
    XCTAssertTrue([charset characterIsMember:' ']);
}

- (void)test_clk_optionNameCharacterSet
{
    NSCharacterSet *asciiLetters = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"];
    NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    NSCharacterSet *symbols = [NSCharacterSet characterSetWithCharactersInString:@"-!@#$%^&,?"];
    
    NSCharacterSet *charset = NSCharacterSet.clk_optionNameIllegalCharacterSet;
    XCTAssertNotNil(charset);
    XCTAssertEqual(charset, NSCharacterSet.clk_optionNameIllegalCharacterSet);
    XCTAssertFalse([charset isSupersetOfSet:asciiLetters]);
    XCTAssertFalse([charset isSupersetOfSet:numbers]);
    XCTAssertFalse([charset isSupersetOfSet:symbols]);
    XCTAssertTrue([charset characterIsMember:'=']);
    XCTAssertTrue([charset characterIsMember:':']);
    XCTAssertTrue([charset characterIsMember:' ']);
}

- (void)test_clk_parameterOptionAssignmentCharacterSet
{
    NSCharacterSet *charset = NSCharacterSet.clk_parameterOptionAssignmentCharacterSet;
    XCTAssertNotNil(charset);
    XCTAssertEqual(charset, NSCharacterSet.clk_parameterOptionAssignmentCharacterSet);
    XCTAssertTrue([charset characterIsMember:':']);
    XCTAssertTrue([charset characterIsMember:'=']);
    XCTAssertFalse([charset characterIsMember:'-']);
}

@end

#pragma mark -

NS_ASSUME_NONNULL_BEGIN

@interface Test_NSError_CLKAdditions : XCTestCase

- (void)verifyError:(NSError *)error domain:(NSString *)domain code:(NSInteger)code description:(NSString *)description;

@end

NS_ASSUME_NONNULL_END

@implementation Test_NSError_CLKAdditions

- (void)verifyError:(NSError *)error domain:(NSString *)domain code:(NSInteger)code description:(NSString *)description
{
    XCTAssertNotNil(error, @"[description: %@]", description);
    if (error == nil) {
        return;
    }
    
    XCTAssertEqualObjects(error.domain, domain);
    XCTAssertEqual(error.code, code);
    XCTAssertEqualObjects(error.localizedDescription, description);
}

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
    NSMutableArray *alpha = [@[ @"alpha" ] mutableCopy];
    XCTAssertEqualObjects([alpha clk_popFirstObject], @"alpha");
    XCTAssertEqual(alpha.count, 0UL);
    
    NSMutableArray *bravo = [@[ @"alpha", @"bravo" ] mutableCopy];
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

- (void)test_clk_containsString_range
{
    XCTAssertFalse([@"" clk_containsString:@"?" range:NSMakeRange(0, 0)]);
    XCTAssertFalse([@"?" clk_containsString:@"?" range:NSMakeRange(0, 0)]);
    XCTAssertFalse([@"!" clk_containsString:@"?" range:NSMakeRange(0, 0)]);
    XCTAssertTrue([@"?" clk_containsString:@"?" range:NSMakeRange(0, 1)]);
    XCTAssertFalse([@"!" clk_containsString:@"?" range:NSMakeRange(0, 1)]);
    XCTAssertTrue([@"?!?" clk_containsString:@"?" range:NSMakeRange(0, 3)]);
    XCTAssertFalse([@"?!?" clk_containsString:@"?" range:NSMakeRange(1, 1)]);
    XCTAssertTrue([@"!?!" clk_containsString:@"?" range:NSMakeRange(1, 1)]);
}

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

@end
