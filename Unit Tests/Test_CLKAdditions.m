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


NS_ASSUME_NONNULL_BEGIN

@interface TokenFormSpec : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)specWithTokens:(NSArray<NSString *> *)tokens form:(CLKArgumentTokenForm)form;
- (instancetype)initWithTokens:(NSArray<NSString *> *)tokens form:(CLKArgumentTokenForm)form NS_DESIGNATED_INITIALIZER;

@property (readonly) NSArray<NSString *> *tokens;
@property (readonly) CLKArgumentTokenForm form;

@end

NS_ASSUME_NONNULL_END

@implementation TokenFormSpec
{
    NSArray<NSString *> *_tokens;
    CLKArgumentTokenForm _form;
}

@synthesize tokens = _tokens;
@synthesize form = _form;

+ (instancetype)specWithTokens:(NSArray<NSString *> *)tokens form:(CLKArgumentTokenForm)form
{
    return [[self alloc] initWithTokens:tokens form:form];
}

- (instancetype)initWithTokens:(NSArray<NSString *> *)tokens form:(CLKArgumentTokenForm)form
{
    self = [super init];
    if (self != nil) {
        _tokens = [tokens copy];
        _form = form;
    }
    
    return self;
}

@end

#pragma mark -

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

@property (readonly) NSArray<TokenFormSpec *> *tokenFormSpecs;

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

- (void)test_clk_containsCharacterFromSet_character
{
    // ...
}

#pragma mark -
#pragma mark Token Forms

- (NSArray<TokenFormSpec *> *)tokenFormSpecs
{
    static NSArray<TokenFormSpec *> *tokenFormSpecs;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        NSArray *flags = @[
            @"-x",
            @"-Q",
            @"-?",
            @"-π"
        ];
        
        NSArray *flagSets = @[
            @"-xy",
            @"-xyz",
            @"-xYz",
            @"-ddd",
            @"-DdD",
            @"-q?",
            @"-πƒ",
            @"-x7z",
            @"-7x7",
            @"-7yz",
            @"-xy7",
        ];
        
        NSArray *names = @[
            @"--q",
            @"--flarn",
            @"--FLARN",
            @"--syn-ack",
            @"--syn--ack",
            @"--syn.ack",
            @"--.syn.ack.",
            @"--syn_ack",
            @"--what-",
            @"--what--",
            @"--what?",
            @"--se7en",
            @"--420",
            @"--barƒ",
            @"---barf",
            @"---" // CLKOption guards against `-` as an option name but technically this looks like a option name token
        ];
        
        NSArray *flagAssignments = @[
            @"-q=",
            @"-q= ",
            @"-q=  ",
            @"-q=p",
            @"-q=flarn",
            @"-q=-flarn",
            @"-q=--flarn",
            @"-q= flarn ",
            @"-q=?",
            @"-q=-",
            @"-q=--",
            @"-q=---",
            
            @"-q=syn=ack",
            @"-q==syn=ack=",
            @"-q=-syn=420",
            @"-q=syn:ack",
            @"-q=:syn:ack:",
            @"-q=-syn:420",
            
            @"-q=4twenty",
            @"-q=7",
            @"-q=420",
            @"-q=42.0",
            @"-q=.420",
            
            @"-q=-4twenty",
            @"-q=-7",
            @"-q=-420",
            @"-q=-42.0",
            @"-q=-.420",
            
            @"-q:",
            @"-q: ",
            @"-q:  ",
            @"-q:p",
            @"-q:flarn",
            @"-q: flarn ",
            @"-q:?",
            @"-q:-",
            @"-q:--",
            @"-q:---",
            
            @"-q:syn=ack",
            @"-q:=syn=ack=",
            @"-q:-syn=ack",
            @"-q:syn:ack",
            @"-q::syn:ack:",
            @"-q:-syn:420",
            
            @"-q:4twenty",
            @"-q:7",
            @"-q:420",
            @"-q:42.0",
            @"-q:.420",
            
            @"-q:-4twenty",
            @"-q:-7",
            @"-q:-420",
            @"-q:-42.0",
            @"-q:-.420"
        ];
        
        NSArray *nameAssignments = @[
            @"--quone=",
            @"--quone= ",
            @"--quone=  ",
            @"--quone=p",
            @"--quone=flarn",
            @"--quone=-flarn",
            @"--quone=--flarn",
            @"--quone= flarn ",
            @"--quone=?",
            @"--quone=-",
            @"--quone=--",
            @"--quone=---",
            @"--qu-one=flarn",
            
            @"--q=flarn",
            @"--q=",
            @"--q:flarn",
            @"--q:",
            
            @"--quone=syn=ack",
            @"--quone==syn=ack=",
            @"--quone=-syn=420",
            @"--quone=syn:ack",
            @"--quone=:syn:ack:",
            @"--quone=-syn:420",
            
            @"--quone=4twenty",
            @"--quone=7",
            @"--quone=420",
            @"--quone=42.0",
            @"--quone=.420",
            
            @"--quone=-4twenty",
            @"--quone=-7",
            @"--quone=-420",
            @"--quone=-42.0",
            @"--quone=-.420",
            
            @"--quone:",
            @"--quone: ",
            @"--quone:  ",
            @"--quone:p",
            @"--quone:flarn",
            @"--quone: flarn ",
            @"--quone:?",
            @"--quone:-",
            @"--quone:--",
            @"--quone:---",
            
            @"--quone:syn=ack",
            @"--quone:=syn=ack=",
            @"--quone:-syn=ack",
            @"--quone:syn:ack",
            @"--quone::syn:ack:",
            @"--quone:-syn:420",
            
            @"--quone:4twenty",
            @"--quone:7",
            @"--quone:420",
            @"--quone:42.0",
            @"--quone:.420",
            
            @"--quone:-4twenty",
            @"--quone:-7",
            @"--quone:-420",
            @"--quone:-42.0",
            @"--quone:-.420"
        ];
        
        NSArray *arguments = @[
            @"",
            @" ",
            @"  ",
            @"flarn",
            @"w-hat",
            @"w=hat",
            @"w:hat",
            @" -x",
            @" --flarn",
            @"-",
            @" -",
        ];
        
        NSArray *malformedOptions = @[
            @"- ",
            @"-  ",
            @"-- ",
            @"--  ",
            @"- -",
            
            @"-- barf",
            @"--barf ",
            @"-- barf ",
            @"--b arf",
            @"-- b arf",
            
            @"-x ",
            @"- x",
            @"-x z",
            
            @"-=",
            @"-=barf",
            @"- =barf",
            @"--=",
            @"--=barf",
            @"-- =barf",
            
            @"-:",
            @"-:barf",
            @"- :barf",
            @"--:",
            @"--:barf",
            @"-- :barf"
        ];
        
        tokenFormSpecs = @[
            [TokenFormSpec specWithTokens:flags form:CLKArgumentTokenFormOptionFlag],
            [TokenFormSpec specWithTokens:flagSets form:CLKArgumentTokenFormOptionFlagSet],
            [TokenFormSpec specWithTokens:names form:CLKArgumentTokenFormOptionName],
            [TokenFormSpec specWithTokens:flagAssignments form:CLKArgumentTokenFormParameterOptionFlagAssignment],
            [TokenFormSpec specWithTokens:nameAssignments form:CLKArgumentTokenFormParameterOptionNameAssignment],
            [TokenFormSpec specWithTokens:@[ @"--" ] form:CLKArgumentTokenFormOptionParsingSentinel],
            [TokenFormSpec specWithTokens:arguments form:CLKArgumentTokenFormArgument],
            [TokenFormSpec specWithTokens:malformedOptions form:CLKArgumentTokenFormMalformedOption]
        ];
    });
    
    return tokenFormSpecs;
}

- (void)enumerateInputTokens:(void (^)(NSString *, CLKArgumentTokenForm))block
{
    for (TokenFormSpec *spec in self.tokenFormSpecs) {
        for (NSString *token in spec.tokens) {
            block(token, spec.form);
        }
    }
}

- (void)test_clk_argumentTokenForm
{
    [self enumerateInputTokens:^(NSString *token, CLKArgumentTokenForm form) {
        XCTAssertEqual(token.clk_argumentTokenForm, form, @"token: '%@'", token);
    }];
}

- (void)test_clk_isOptionFlagToken
{
    [self enumerateInputTokens:^(NSString *token, CLKArgumentTokenForm form) {
        if (form == CLKArgumentTokenFormOptionFlag) {
            XCTAssertTrue(token.clk_isOptionFlagToken);
        } else {
            XCTAssertFalse(token.clk_isOptionFlagToken, @"token: '%@'", token);
        }
    }];
}

- (void)test_clk_isOptionFlagSetToken
{
    [self enumerateInputTokens:^(NSString *token, CLKArgumentTokenForm form) {
        if (form == CLKArgumentTokenFormOptionFlagSet) {
            XCTAssertTrue(token.clk_isOptionFlagSetToken, @"token: '%@'", token);
        } else {
            XCTAssertFalse(token.clk_isOptionFlagSetToken, @"token: '%@'", token);
        }
    }];
}

- (void)test_clk_isOptionNameToken
{
    [self enumerateInputTokens:^(NSString *token, CLKArgumentTokenForm form) {
        if (form == CLKArgumentTokenFormOptionName) {
            XCTAssertTrue(token.clk_isOptionNameToken, @"token: '%@'", token);
        } else {
            XCTAssertFalse(token.clk_isOptionNameToken, @"token: '%@'", token);
        }
    }];
}

- (void)test_clk_isParameterOptionFlagAssignmentToken
{
    [self enumerateInputTokens:^(NSString *token, CLKArgumentTokenForm form) {
        if (form == CLKArgumentTokenFormParameterOptionFlagAssignment) {
            XCTAssertTrue(token.clk_isParameterOptionFlagAssignmentToken, @"token: '%@'", token);
        } else {
            XCTAssertFalse(token.clk_isParameterOptionFlagAssignmentToken, @"token: '%@'", token);
        }
    }];
}

- (void)test_clk_isParameterOptionNameAssignmentToken
{
    [self enumerateInputTokens:^(NSString *token, CLKArgumentTokenForm form) {
        if (form == CLKArgumentTokenFormParameterOptionNameAssignment) {
            XCTAssertTrue(token.clk_isParameterOptionNameAssignmentToken, @"token: '%@'", token);
        } else {
            XCTAssertFalse(token.clk_isParameterOptionNameAssignmentToken, @"token: '%@'", token);
        }
    }];
}

- (void)test_clk_resemblesOptionTokenForm
{
    [self enumerateInputTokens:^(NSString *token, CLKArgumentTokenForm form) {
        // competing implementation of the logic in clk_resemblesOptionTokenForm
        BOOL shouldResemble = (form == CLKArgumentTokenFormOptionName
                               || form == CLKArgumentTokenFormOptionFlag
                               || form == CLKArgumentTokenFormOptionFlagSet
                               || form == CLKArgumentTokenFormParameterOptionFlagAssignment
                               || form == CLKArgumentTokenFormParameterOptionNameAssignment
                               || form == CLKArgumentTokenFormMalformedOption);
        
        if (shouldResemble) {
            XCTAssertTrue(token.clk_resemblesOptionTokenForm, @"token: '%@'", token);
        } else {
            XCTAssertFalse(token.clk_resemblesOptionTokenForm, @"token: '%@'", token);
        }
    }];
}

@end
