//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface NSCharacterSet (CLKAdditions)

@property (class, readonly) NSCharacterSet *clk_optionFlagIllegalCharacterSet;
@property (class, readonly) NSCharacterSet *clk_optionNameIllegalCharacterSet;
@property (class, readonly) NSCharacterSet *clk_parameterOptionAssignmentCharacterSet;

@end

NS_ASSUME_NONNULL_END
