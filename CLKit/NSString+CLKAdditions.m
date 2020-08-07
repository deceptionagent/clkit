//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "NSString+CLKAdditions.h"

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

@end
