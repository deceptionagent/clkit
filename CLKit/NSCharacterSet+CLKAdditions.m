//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "NSCharacterSet+CLKAdditions.h"


@implementation NSCharacterSet (CLKAdditions)

+ (NSCharacterSet *)clk_numericArgumentCharacterSet
{
    static NSMutableCharacterSet *numericArgumentCharacterSet;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        numericArgumentCharacterSet = [NSMutableCharacterSet.decimalDigitCharacterSet retain];
        [numericArgumentCharacterSet formUnionWithCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@".:"]];
    });
    
    return numericArgumentCharacterSet;
}

@end
