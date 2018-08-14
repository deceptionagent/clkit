//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(uint32_t, CLKTokenKind) {
    CLKTokenKindOptionName = 0, // `--xyxxy`
    CLKTokenKindOptionFlag = 1, // `-x`
    CLKTokenKindOptionFlagGroup = 2, // `-xyz`
    CLKTokenKindOptionRemainderDelimiter = 3, // `--`
    CLKTokenKindArgument = 4,
    CLKTokenKindInvalid = 5
};

@interface NSString (CLKAdditions)

@property (readonly) CLKTokenKind clk_tokenKind;

@end
