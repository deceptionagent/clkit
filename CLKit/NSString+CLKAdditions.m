//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "NSString+CLKAdditions.h"

#import "NSCharacterSet+CLKAdditions.h"


@implementation NSString (CLKAdditions)

- (BOOL)clk_containsString:(NSString *)string range:(NSRange)range
{
    return ([self rangeOfString:string options:NSLiteralSearch range:range].location != NSNotFound);
}

- (BOOL)clk_containsCharacterFromSet:(NSCharacterSet *)characterSet
{
    return [self clk_containsCharacterFromSet:characterSet range:NSMakeRange(0, self.length)];
}

- (BOOL)clk_containsCharacterFromSet:(NSCharacterSet *)characterSet range:(NSRange)range
{
    return ([self rangeOfCharacterFromSet:characterSet options:NSLiteralSearch range:range].location != NSNotFound);
}

#pragma mark -
#pragma mark Token Forms

- (CLKArgumentTokenForm)clk_argumentTokenForm
{
    if (self.length < 2) {
        // a zero-length argument is technically still an argument.
        // this also catches "-", which has no special meaning to CLKit.
        return CLKArgumentTokenFormArgument;
    }
    
    if (self.clk_isOptionNameToken) {
        return CLKArgumentTokenFormOptionName;
    }
    
    if (self.clk_isOptionFlagToken) {
        return CLKArgumentTokenFormOptionFlag;
    }
    
    if (self.clk_isOptionFlagSetToken) {
        return CLKArgumentTokenFormOptionFlagSet;
    }
    
    if (self.clk_isParameterOptionNameAssignmentToken) {
        return CLKArgumentTokenFormParameterOptionNameAssignment;
    }
    
    if (self.clk_isParameterOptionFlagAssignmentToken) {
        return CLKArgumentTokenFormParameterOptionFlagAssignment;
    }
    
    if ([self isEqualToString:@"--"]) {
        return CLKArgumentTokenFormOptionParsingSentinel;
    }
    
    // if the token has a leading dash and has failed all of the option form checks,
    // it looks like an option but is malformed somehow. (e.g., it contains whitespace.)
    // this is the only order-dependent check.
    if ([self hasPrefix:@"-"]) {
        return CLKArgumentTokenFormMalformedOption;
    }
    
    return CLKArgumentTokenFormArgument;
}

- (BOOL)clk_isOptionNameToken
{
    // `--xyzzy`
    return (self.length > 2
            && [self hasPrefix:@"--"]
            && ![self clk_containsCharacterFromSet:NSCharacterSet.clk_optionNameIllegalCharacterSet range:NSMakeRange(2, (self.length - 2))]
    );
}

- (BOOL)clk_isOptionFlagToken
{
    // `-x`
    return (self.length == 2
            && [self characterAtIndex:0] == '-'
            && ![NSCharacterSet.clk_optionFlagIllegalCharacterSet characterIsMember:[self characterAtIndex:1]]
    );
}

- (BOOL)clk_isOptionFlagSetToken
{
    // `-xyz`
    return (self.length > 2
            && [self characterAtIndex:0] == '-'
            && ![self clk_containsCharacterFromSet:NSCharacterSet.clk_optionFlagIllegalCharacterSet range:NSMakeRange(1, (self.length - 1))]
    );
}

- (BOOL)clk_isParameterOptionNameAssignmentToken
{
    /* `--flarn=barf`, `--flarn:barf` */
    
    if (self.length < 3 && ![self hasPrefix:@"--"]) {
        return NO;
    }
    
    // find the first occurence of an assignment operator and verify there is an option name preceding it
    NSRange r = NSMakeRange(2, (self.length - 2));
    NSUInteger l = [self rangeOfCharacterFromSet:NSCharacterSet.clk_parameterOptionAssignmentCharacterSet options:NSLiteralSearch range:r].location;
    if (l == NSNotFound || l == 2) {
        return NO;
    }
    
    // validate the form of the option name segment
    NSUInteger s = (l - 2);
    r = NSMakeRange(2, s);
    return ![self clk_containsCharacterFromSet:NSCharacterSet.clk_optionNameIllegalCharacterSet range:r];
}

- (BOOL)clk_isParameterOptionFlagAssignmentToken
{
    // `-x=y`, `-x:y`
    return (self.length > 2
            && [self characterAtIndex:0] == '-'
            && ![NSCharacterSet.clk_optionFlagIllegalCharacterSet characterIsMember:[self characterAtIndex:1]]
            && [NSCharacterSet.clk_parameterOptionAssignmentCharacterSet characterIsMember:[self characterAtIndex:2]]
    );
}

- (BOOL)clk_resemblesOptionTokenForm
{
    switch (self.clk_argumentTokenForm) {
        case CLKArgumentTokenFormOptionName:
        case CLKArgumentTokenFormOptionFlag:
        case CLKArgumentTokenFormOptionFlagSet:
        case CLKArgumentTokenFormParameterOptionFlagAssignment:
        case CLKArgumentTokenFormParameterOptionNameAssignment:
        case CLKArgumentTokenFormMalformedOption:
            return YES;
        
        case CLKArgumentTokenFormOptionParsingSentinel:
        case CLKArgumentTokenFormArgument:
            return NO;
    }
}

@end
