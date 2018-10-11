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

- (BOOL)clk_resemblesOptionArgumentToken
{
    switch (self.clk_argumentTokenKind) {
        case CLKArgumentTokenKindOptionName:
        case CLKArgumentTokenKindOptionFlag:
        case CLKArgumentTokenKindOptionFlagSet:
        case CLKArgumentTokenKindMalformedOption:
            return YES;
        
        case CLKArgumentTokenKindOptionParsingSentinel:
        case CLKArgumentTokenKindArgument:
            return NO;
    }
}

- (BOOL)clk_isNumericArgumentToken
{
    static NSCharacterSet *nonNumericArgumentCharacterSet;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        nonNumericArgumentCharacterSet = [NSCharacterSet.clk_numericArgumentCharacterSet.invertedSet retain];
    });
    
    NSRange range;
    if ([self hasPrefix:@"-"]) {
        range = NSMakeRange(1, self.length - 1);
    } else {
        range = NSMakeRange(0, self.length);
    }
    
    return ([self clk_containsCharacterFromSet:NSCharacterSet.decimalDigitCharacterSet range:range]
            && ![self clk_containsCharacterFromSet:nonNumericArgumentCharacterSet range:range]);
}

- (CLKArgumentTokenKind)clk_argumentTokenKind
{
    if (self.length < 2) {
        // a zero-length argument is technically still an argument
        return CLKArgumentTokenKindArgument;
    }
    
    if ([self hasPrefix:@"-"]) {
        if ([self containsString:@" "]) {
            return CLKArgumentTokenKindMalformedOption;
        }
        
        if (self.clk_isNumericArgumentToken) {
            return CLKArgumentTokenKindArgument;
        }
        
        if (self.length == 2) {
            if ([self isEqualToString:@"--"]) {
                return CLKArgumentTokenKindOptionParsingSentinel;
            }
            
            return CLKArgumentTokenKindOptionFlag;
        }
        
        if ([self hasPrefix:@"--"]) {
            return CLKArgumentTokenKindOptionName;
        }
        
        // flag sets cannot contain dashes
        NSRange contractedRange = NSMakeRange(1, self.length - 1);
        if ([self clk_containsString:@"-" range:contractedRange]) {
            return CLKArgumentTokenKindMalformedOption;
        }
        
        if ([self clk_containsCharacterFromSet:NSCharacterSet.clk_numericArgumentCharacterSet range:contractedRange]) {
            return CLKArgumentTokenKindMalformedOption;
        }
        
        return CLKArgumentTokenKindOptionFlagSet;
    }
    
    return CLKArgumentTokenKindArgument;
}

@end
