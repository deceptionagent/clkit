//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "NSString+CLKAdditions.h"

#import "NSCharacterSet+CLKAdditions.h"


@implementation NSString (CLKAdditions)

- (BOOL)clk_containsCharacterFromSet:(NSCharacterSet *)characterSet range:(NSRange)range
{
    return ([self rangeOfCharacterFromSet:characterSet options:NSLiteralSearch range:range].location != NSNotFound);
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

- (CLKTokenKind)clk_tokenKind
{
    if (self.length == 0) {
        return CLKTokenKindInvalid;
    }
    
    if (self.length == 1) {
        return CLKTokenKindArgument;
    }
    
    if ([self hasPrefix:@"-"]) {
        if ([self containsString:@" "]) {
            return CLKTokenKindInvalid;
        }
        
        if (self.clk_isNumericArgumentToken) {
            return CLKTokenKindArgument;
        }
        
        if (self.length == 2) {
            if ([self isEqualToString:@"--"]) {
                return CLKTokenKindRemainderArgumentsDelimiter;
            }
            
            return CLKTokenKindOptionFlag;
        }
        
        if ([self hasPrefix:@"--"]) {
            return CLKTokenKindOptionName;
        }
        
        if ([self clk_containsCharacterFromSet:NSCharacterSet.clk_numericArgumentCharacterSet range:NSMakeRange(1, self.length - 1)]) {
            return CLKTokenKindInvalid;
        }
        
        return CLKTokenKindOptionFlagGroup;
    }
    
    return CLKTokenKindArgument;
}

@end
