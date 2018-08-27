//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(uint32_t, CLKArgumentTokenKind) {
    CLKArgumentTokenKindOptionName = 0, // `--xyxxy`
    CLKArgumentTokenKindOptionFlag = 1, // `-x`
    CLKArgumentTokenKindOptionFlagSet = 2, // `-xyz`
    CLKArgumentTokenKindArgument = 3,
    CLKArgumentTokenKindOptionParsingSentinel = 4, // `--`
    CLKArgumentTokenKindMalformedOption = 5
};

NS_ASSUME_NONNULL_BEGIN

@interface NSString (CLKAdditions)

- (BOOL)clk_containsCharacterFromSet:(NSCharacterSet *)characterSet;
- (BOOL)clk_containsCharacterFromSet:(NSCharacterSet *)characterSet range:(NSRange)range;

@property (readonly) BOOL clk_resemblesOptionArgumentToken;
@property (readonly) BOOL clk_isNumericArgumentToken;
@property (readonly) CLKArgumentTokenKind clk_argumentTokenKind;

@end

NS_ASSUME_NONNULL_END
