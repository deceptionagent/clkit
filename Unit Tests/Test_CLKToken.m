//
//  Copyright (c) 2019 Plastic Pulse. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CLKToken.h"


NS_ASSUME_NONNULL_BEGIN

@interface TokenFormSpec : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)specWithTokens:(NSArray<NSString *> *)tokens form:(CLKTokenForm)form;
- (instancetype)initWithTokens:(NSArray<NSString *> *)tokens form:(CLKTokenForm)form NS_DESIGNATED_INITIALIZER;

@property (readonly) NSArray<NSString *> *tokens;
@property (readonly) CLKTokenForm form;

@end

NS_ASSUME_NONNULL_END

@implementation TokenFormSpec
{
    NSArray<NSString *> *_tokens;
    CLKTokenForm _form;
}

@synthesize tokens = _tokens;
@synthesize form = _form;

+ (instancetype)specWithTokens:(NSArray<NSString *> *)tokens form:(CLKTokenForm)form
{
    return [[self alloc] initWithTokens:tokens form:form];
}

- (instancetype)initWithTokens:(NSArray<NSString *> *)tokens form:(CLKTokenForm)form
{
    self = [super init];
    if (self != nil) {
        _tokens = [tokens copy];
        _form = form;
    }
    
    return self;
}

@end

@interface Test_CLKToken : XCTestCase

@property (readonly) NSArray<TokenFormSpec *> *tokenFormSpecs;

@end

@implementation Test_CLKToken

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
            @"-=-4-2:0",
            @"--=-4-2:0",
            
            @"-:",
            @"-:barf",
            @"- :barf",
            @"--:",
            @"--:barf",
            @"-- :barf",
            @"-:-4-2:0",
            @"--:=-4-2:0",
        ];
        
        tokenFormSpecs = @[
            [TokenFormSpec specWithTokens:flags form:CLKTokenFormOptionFlag],
            [TokenFormSpec specWithTokens:flagSets form:CLKTokenFormOptionFlagSet],
            [TokenFormSpec specWithTokens:names form:CLKTokenFormOptionName],
            [TokenFormSpec specWithTokens:flagAssignments form:CLKTokenFormParameterOptionFlagAssignment],
            [TokenFormSpec specWithTokens:nameAssignments form:CLKTokenFormParameterOptionNameAssignment],
            [TokenFormSpec specWithTokens:@[ @"--" ] form:CLKTokenFormOptionParsingSentinel],
            [TokenFormSpec specWithTokens:arguments form:CLKTokenFormArgument],
            [TokenFormSpec specWithTokens:malformedOptions form:CLKTokenFormMalformedOption]
        ];
    });
    
    return tokenFormSpecs;
}

- (void)enumerateInputTokens:(void (^)(NSString *, CLKTokenForm))block
{
    for (TokenFormSpec *spec in self.tokenFormSpecs) {
        for (NSString *token in spec.tokens) {
            block(token, spec.form);
        }
    }
}

- (void)test_CLKTokenFormForToken
{
    [self enumerateInputTokens:^(NSString *token, CLKTokenForm form) {
        XCTAssertEqual(CLKTokenFormForToken(token), form, @"token: '%@'", token);
    }];
}

- (void)test_CLKTokenIsOptionName
{
    [self enumerateInputTokens:^(NSString *token, CLKTokenForm form) {
        BOOL isOptionName = CLKTokenIsOptionName(token);
        if (form == CLKTokenFormOptionName) {
            XCTAssertTrue(isOptionName, @"token: '%@'", token);
        } else {
            XCTAssertFalse(isOptionName, @"token: '%@'", token);
        }
    }];
}

- (void)test_CLKTokenIsOptionFlag
{
    [self enumerateInputTokens:^(NSString *token, CLKTokenForm form) {
        BOOL isOptionFlag = CLKTokenIsOptionFlag(token);
        if (form == CLKTokenFormOptionFlag) {
            XCTAssertTrue(isOptionFlag, @"token: '%@'", token);
        } else {
            XCTAssertFalse(isOptionFlag, @"token: '%@'", token);
        }
    }];
}

- (void)test_CLKTokenIsOptionFlagSet
{
    [self enumerateInputTokens:^(NSString *token, CLKTokenForm form) {
        BOOL isOptionFlagSet = CLKTokenIsOptionFlagSet(token);
        if (form == CLKTokenFormOptionFlagSet) {
            XCTAssertTrue(isOptionFlagSet, @"token: '%@'", token);
        } else {
            XCTAssertFalse(isOptionFlagSet, @"token: '%@'", token);
        }
    }];
}

- (void)test_CLKTokenIsParameterOptionNameAssignment
{
    [self enumerateInputTokens:^(NSString *token, CLKTokenForm form) {
        BOOL isOptionNameAssignment = CLKTokenIsParameterOptionNameAssignment(token);
        if (form == CLKTokenFormParameterOptionNameAssignment) {
            XCTAssertTrue(isOptionNameAssignment, @"token: '%@'", token);
        } else {
            XCTAssertFalse(isOptionNameAssignment, @"token: '%@'", token);
        }
    }];
}

- (void)test_CLKTokenIsParameterOptionFlagAssignment
{
    [self enumerateInputTokens:^(NSString *token, CLKTokenForm form) {
        BOOL isOptionFlagAssignment = CLKTokenIsParameterOptionFlagAssignment(token);
        if (form == CLKTokenFormParameterOptionFlagAssignment) {
            XCTAssertTrue(isOptionFlagAssignment, @"token: '%@'", token);
        } else {
            XCTAssertFalse(isOptionFlagAssignment, @"token: '%@'", token);
        }
    }];
}

- (void)test_CLKTokenFormIsKindOfOption
{
    [self enumerateInputTokens:^(NSString *token, CLKTokenForm form) {
        // competing implementation of the logic in clk_resemblesOptionTokenForm
        BOOL shouldResemble = (form == CLKTokenFormOptionName
                               || form == CLKTokenFormOptionFlag
                               || form == CLKTokenFormOptionFlagSet
                               || form == CLKTokenFormParameterOptionFlagAssignment
                               || form == CLKTokenFormParameterOptionNameAssignment
                               || form == CLKTokenFormMalformedOption);
        
        BOOL isKindOfOption = CLKTokenFormIsKindOfOption(form);
        if (shouldResemble) {
            XCTAssertTrue(isKindOfOption, @"token: '%@'", token);
        } else {
            XCTAssertFalse(isKindOfOption, @"token: '%@'", token);
        }
    }];
}

@end
