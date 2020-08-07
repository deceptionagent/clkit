//
//  Copyright (c) 2019 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(uint32_t, CLKTokenForm) {
    CLKTokenFormOptionName = 0, // `--xyxxy`
    CLKTokenFormOptionFlag = 1, // `-x`
    CLKTokenFormOptionFlagSet = 2, // `-xyz`
    CLKTokenFormParameterOptionNameAssignment = 3, // `--flarn=barf`, `--flarn:barf`
    CLKTokenFormParameterOptionFlagAssignment = 4, // `-x=y`, `-x:y`
    CLKTokenFormOptionParsingSentinel = 5, // `--`
    CLKTokenFormArgument = 6,
    CLKTokenFormMalformedOption = 7
};

NS_ASSUME_NONNULL_BEGIN

CLKTokenForm CLKTokenFormForToken(NSString *token);

BOOL CLKTokenIsOptionName(NSString *token);
BOOL CLKTokenIsOptionFlag(NSString *token);
BOOL CLKTokenIsOptionFlagSet(NSString *token);
BOOL CLKTokenIsParameterOptionNameAssignment(NSString *token);
BOOL CLKTokenIsParameterOptionFlagAssignment(NSString *token);

BOOL CLKTokenFormIsKindOfOption(CLKTokenForm tokenForm);

NS_ASSUME_NONNULL_END
