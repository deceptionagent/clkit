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
    CLKAPStateParseParameterOptionNameAssignment = 5,
    CLKAPStateParseParameterOptionFlagAssignment = 6,
    CLKAPStateParseArgument = 7,
    CLKAPStateParseRemainingArguments = 8,
    CLKAPStateEnd = 9
};

@class CLKOption;
@class CLKOptionGroup;

NS_ASSUME_NONNULL_BEGIN

@interface CLKArgumentParser ()

- (instancetype)_initWithArgumentVector:(NSArray<NSString *> *)argv
                               options:(NSArray<CLKOption *> *)options
                          optionGroups:(nullable NSArray<CLKOptionGroup *> *)groups NS_DESIGNATED_INITIALIZER;

@property (nullable, retain) CLKOption *currentParameterOption;

- (nullable CLKOption *)_optionForOptionNameToken:(NSString *)token error:(NSError **)outError;
- (nullable CLKOption *)_optionForOptionFlagToken:(NSString *)token error:(NSError **)outError;

#pragma mark -
#pragma mark Errors

- (void)_accumulateParsingError:(NSError *)error;
- (void)_accumulateValidationError:(NSError *)error;
- (BOOL)_hasParsingErrorForOptionNamed:(NSString *)optionName;

#pragma mark -
#pragma mark Parsing

- (CLKAPState)_readNextArgumentToken;
- (CLKAPState)_parseOptionName;
- (CLKAPState)_parseOptionFlag;
- (CLKAPState)_parseOptionFlagSet;
- (CLKAPState)_parseOptionNameAssignment;
- (CLKAPState)_parseOptionFlagAssignment;
- (CLKAPState)_parseArgument;
- (CLKAPState)_parseRemainingArguments;
- (BOOL)_processAssignedArgument:(NSString *)argument forParameterOption:(CLKOption *)option userInvocation:(NSString *)userInvocation error:(NSError **)outError;
- (CLKAPState)_processParsedOption:(CLKOption *)option userInvocation:(NSString *)userInvocation;
- (BOOL)_processArgument:(NSString *)argument forParameterOption:(nullable CLKOption *)option error:(NSError **)outError;

#pragma mark -
#pragma mark Validation

- (BOOL)_validateManifest;

@end

NS_ASSUME_NONNULL_END
