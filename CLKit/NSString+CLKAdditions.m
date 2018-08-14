//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "NSString+CLKAdditions.h"


@implementation NSString (CLKAdditions)

- (CLKTokenKind)clk_tokenKind
{
    if (self.length == 0) {
        return CLKTokenKindInvalid;
    }
    
    if (self.length == 1) {
        // `-` is a valid argument
        return CLKTokenKindArgument;
    }
    
    if ([self hasPrefix:@"-"] && [self containsString:@" "]) {
        return CLKTokenKindInvalid;
    }
    
    if ([self isEqualToString:@"--"]) {
        // it's up to the caller whether this is special or just another argument
        return CLKTokenKindOptionRemainderDelimiter;
    }
    
    if ([self hasPrefix:@"--"]) {
        NSAssert((self.length > 2), @"unexpected token length");
        return CLKTokenKindOptionName;
    }
    
    NSAssert((self.length > 1), @"unexpected token length");
    
    if ([self hasPrefix:@"-"]) {
        BOOL containsDigit = ([self rangeOfCharacterFromSet:NSCharacterSet.decimalDigitCharacterSet].location != NSNotFound);
        
        if (self.length > 2) {
            if (containsDigit) {
                // looks like a flag group with a number jammed in (e.g., `-x7z`)
                return CLKTokenKindInvalid;
            }
            
            return CLKTokenKindOptionFlagGroup;
        }
        
        if (containsDigit) {
            // this resembles a negative number argument (e.g., `-7`)
            return CLKTokenKindArgument;
        }
    
        return CLKTokenKindOptionFlag;
    }
    
    return CLKTokenKindArgument;
}

@end
