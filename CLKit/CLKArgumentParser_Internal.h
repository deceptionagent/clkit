//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "CLKArgumentParser.h"


typedef NS_ENUM(uint32_t, CLKAPState) {
    CLKAPStateBegin = 0,
    CLKAPStateReadNextArgumentToken = 1,
    CLKAPStateParseOptionName = 2,
    CLKAPStateParseOptionFlag = 3,
    CLKAPStateParseOptionFlagSet = 4,
    CLKAPStateParseArgument = 5,
    CLKAPStateParseRemainingArguments = 6,
    CLKAPStateEnd = 7
};

@class CLKOption;
@class CLKOptionGroup;

NS_ASSUME_NONNULL_BEGIN

@interface CLKArgumentParser ()

- (instancetype)_initWithArgumentVector:(NSArray<NSString *> *)argv
                               options:(NSArray<CLKOption *> *)options
                          optionGroups:(nullable NSArray<CLKOptionGroup *> *)groups NS_DESIGNATED_INITIALIZER;

@property (nullable, retain) CLKOption *currentParameterOption;

- (void)_accumulateError:(NSError *)error;

- (CLKAPState)_readNextArgumentToken;
- (CLKAPState)_parseOptionName;
- (CLKAPState)_parseOptionFlag;
- (CLKAPState)_processParsedOption:(CLKOption *)option userInvocation:(NSString *)userInvocation;
- (CLKAPState)_parseOptionFlagSet;
- (CLKAPState)_parseArgument;
- (CLKAPState)_parseRemainingArguments;
- (BOOL)_parseArgument:(NSError **)outError;

- (BOOL)_validateManifest;

@end

NS_ASSUME_NONNULL_END
