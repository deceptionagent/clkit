//
//  Copyright (c) 2019 Plastic Pulse. All rights reserved.
//

#import "CLKToken.h"

#import "NSCharacterSet+CLKAdditions.h"
#import "NSString+CLKAdditions.h"

CLKTokenForm CLKTokenFormForToken(NSString *token)
{
    if (token.length < 2) {
        // a zero-length argument is technically still an argument.
        // this also catches `-`, which has no special meaning to CLKit.
        return CLKTokenFormArgument;
    }
    
    if (CLKTokenIsOptionName(token)) {
        return CLKTokenFormOptionName;
    }
    
    if (CLKTokenIsOptionFlag(token)) {
        return CLKTokenFormOptionFlag;
    }
    
    if (CLKTokenIsOptionFlagSet(token)) {
        return CLKTokenFormOptionFlagSet;
    }
    
    if (CLKTokenIsParameterOptionNameAssignment(token)) {
        return CLKTokenFormParameterOptionNameAssignment;
    }
    
    if (CLKTokenIsParameterOptionFlagAssignment(token)) {
        return CLKTokenFormParameterOptionFlagAssignment;
    }
    
    if ([token isEqualToString:@"--"]) {
        return CLKTokenFormOptionParsingSentinel;
    }
    
    // if the token has a leading dash and has failed all of the option form checks,
    // it looks like an option but is malformed somehow. (e.g., the option segment
    // contains whitespace after the dash.) this is an order-dependent check.
    if ([token hasPrefix:@"-"]) {
        return CLKTokenFormMalformedOption;
    }
    
    return CLKTokenFormArgument;
}

BOOL CLKTokenIsOptionName(NSString *token)
{
    // `--xyzzy`
    return (token.length > 2
            && [token hasPrefix:@"--"]
            && ![token clk_containsCharacterFromSet:NSCharacterSet.clk_optionNameIllegalCharacterSet range:NSMakeRange(2, (token.length - 2))]
    );
}

BOOL CLKTokenIsOptionFlag(NSString *token)
{
    // `-x`
    return (token.length == 2
            && [token characterAtIndex:0] == '-'
            && ![NSCharacterSet.clk_optionFlagIllegalCharacterSet characterIsMember:[token characterAtIndex:1]]
    );
}

BOOL CLKTokenIsOptionFlagSet(NSString *token)
{
    // `-xyz`
    return (token.length > 2
            && [token characterAtIndex:0] == '-'
            && ![token clk_containsCharacterFromSet:NSCharacterSet.clk_optionFlagIllegalCharacterSet range:NSMakeRange(1, (token.length - 1))]
    );
}

BOOL CLKTokenIsParameterOptionNameAssignment(NSString *token)
{
    /* `--flarn=barf`, `--flarn:barf` */
    
    // name assignment forms contain at least two leading dashes, an assignment character, and at least one option name character.
    // this check does not differentiate between (e.g.,) `--f=` (acceptable) and `--=f` (malformed); the latter will be
    // detected as part of option name extraction below.
    if (!(token.length > 3 && [token hasPrefix:@"--"])) {
        return NO;
    }
    
    // find the first occurence of an assignment operator and verify there is an option name segment preceding it
    // (e.g., `--=barf` is malformed)
    NSRange r = NSMakeRange(2, (token.length - 2));
    NSUInteger loc = [token rangeOfCharacterFromSet:NSCharacterSet.clk_parameterOptionAssignmentCharacterSet options:NSLiteralSearch range:r].location;
    if (loc == NSNotFound || loc == 2) {
        return NO;
    }
    
    // validate the form of the option name segment
    NSUInteger s = (loc - 2);
    r = NSMakeRange(2, s);
    return ![token clk_containsCharacterFromSet:NSCharacterSet.clk_optionNameIllegalCharacterSet range:r];
}

BOOL CLKTokenIsParameterOptionFlagAssignment(NSString *token)
{
    // `-x=y`, `-x:y`
    return (token.length > 2
            && [token characterAtIndex:0] == '-'
            && ![NSCharacterSet.clk_optionFlagIllegalCharacterSet characterIsMember:[token characterAtIndex:1]]
            && [NSCharacterSet.clk_parameterOptionAssignmentCharacterSet characterIsMember:[token characterAtIndex:2]]
    );
}

BOOL CLKTokenFormIsKindOfOption(CLKTokenForm tokenForm)
{
    switch (tokenForm) {
        case CLKTokenFormOptionName:
        case CLKTokenFormOptionFlag:
        case CLKTokenFormOptionFlagSet:
        case CLKTokenFormParameterOptionFlagAssignment:
        case CLKTokenFormParameterOptionNameAssignment:
        case CLKTokenFormMalformedOption:
            return YES;
        
        case CLKTokenFormOptionParsingSentinel:
        case CLKTokenFormArgument:
            return NO;
    }
}
