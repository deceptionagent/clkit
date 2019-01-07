//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(uint32_t, CLKArgumentTokenForm) {
    CLKArgumentTokenFormOptionName = 0, // `--xyxxy`
    CLKArgumentTokenFormOptionFlag = 1, // `-x`
    CLKArgumentTokenFormOptionFlagSet = 2, // `-xyz`
    CLKArgumentTokenFormParameterOptionNameAssignment = 3, // `--flarn=barf`, `--flarn:barf`
    CLKArgumentTokenFormParameterOptionFlagAssignment = 4, // `-x=y`, `-x:y`
    CLKArgumentTokenFormOptionParsingSentinel = 5, // `--`
    CLKArgumentTokenFormArgument = 6,
    CLKArgumentTokenFormMalformedOption = 7
};

NS_ASSUME_NONNULL_BEGIN

@interface NSString (CLKAdditions)

- (BOOL)clk_containsString:(NSString *)string range:(NSRange)range;
- (BOOL)clk_containsCharacterFromSet:(NSCharacterSet *)characterSet;
- (BOOL)clk_containsCharacterFromSet:(NSCharacterSet *)characterSet range:(NSRange)range;

@property (readonly) CLKArgumentTokenForm clk_argumentTokenForm;

@property (readonly) BOOL clk_isOptionNameToken;
@property (readonly) BOOL clk_isOptionFlagToken;
@property (readonly) BOOL clk_isOptionFlagSetToken;
@property (readonly) BOOL clk_isParameterOptionNameAssignmentToken;
@property (readonly) BOOL clk_isParameterOptionFlagAssignmentToken;

@property (readonly) BOOL clk_resemblesOptionTokenForm;

@end

NS_ASSUME_NONNULL_END
