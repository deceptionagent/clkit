//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "NSCharacterSet+CLKAdditions.h"


@implementation NSCharacterSet (CLKAdditions)

+ (NSCharacterSet *)clk_optionFlagIllegalCharacterSet
{
    static NSMutableCharacterSet *optionFlagIllegalCharacterSet;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        optionFlagIllegalCharacterSet = [[NSMutableCharacterSet characterSetWithCharactersInString:@"-"] retain];
        [optionFlagIllegalCharacterSet formUnionWithCharacterSet:self.clk_parameterOptionAssignmentCharacterSet];
//        [optionFlagIllegalCharacterSet formUnionWithCharacterSet:NSCharacterSet.decimalDigitCharacterSet];
        [optionFlagIllegalCharacterSet formUnionWithCharacterSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    });
    
    return optionFlagIllegalCharacterSet;
}

+ (NSCharacterSet *)clk_optionNameIllegalCharacterSet
{
    static NSMutableCharacterSet *optionNameIllegalCharacterSet;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        optionNameIllegalCharacterSet = [NSMutableCharacterSet.whitespaceAndNewlineCharacterSet retain];
        [optionNameIllegalCharacterSet formUnionWithCharacterSet:self.clk_parameterOptionAssignmentCharacterSet];
    });
    
    return optionNameIllegalCharacterSet;
}

+ (NSCharacterSet *)clk_parameterOptionAssignmentCharacterSet
{
    static NSCharacterSet *parameterOptionAssignmentCharacterSet;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        parameterOptionAssignmentCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@":="] retain];
    });
    
    return parameterOptionAssignmentCharacterSet;
}

@end
