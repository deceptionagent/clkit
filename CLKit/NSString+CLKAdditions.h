//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(uint32_t, CLKTokenKind) {
    CLKTokenKindOptionName = 0, // `--xyxxy`
    CLKTokenKindOptionFlag = 1, // `-x`
    CLKTokenKindOptionFlagSet = 2, // `-xyz`
    #warning rename this: "sentinel"
    CLKTokenKindRemainderArgumentsDelimiter = 3, // `--`
    CLKTokenKindArgument = 4,
    CLKTokenKindInvalid = 5
};

NS_ASSUME_NONNULL_BEGIN

@interface NSString (CLKAdditions)

- (BOOL)clk_containsCharacterFromSet:(NSCharacterSet *)characterSet range:(NSRange)range;

@property (readonly) BOOL clk_isNumericArgumentToken;
@property (readonly) CLKTokenKind clk_tokenKind;

@end

NS_ASSUME_NONNULL_END
