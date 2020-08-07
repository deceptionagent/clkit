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

@class CLKArgumentIssue;
@class CLKOption;
@class CLKOptionGroup;

NS_ASSUME_NONNULL_BEGIN

@interface CLKArgumentParser ()

- (instancetype)_initWithArgumentVector:(NSArray<NSString *> *)argv
                               options:(NSArray<CLKOption *> *)options
                          optionGroups:(nullable NSArray<CLKOptionGroup *> *)groups NS_DESIGNATED_INITIALIZER;

@property (nullable, retain) CLKOption *currentParameterOption;

- (nullable CLKOption *)_optionForOptionNameToken:(NSString *)token issue:(CLKArgumentIssue *__nullable *__nonnull)outIssue;
- (nullable CLKOption *)_optionForOptionFlagToken:(NSString *)token issue:(CLKArgumentIssue *__nullable *__nonnull)outIssue;

#pragma mark -
#pragma mark Errors

- (void)_accumulateParsingIssue:(CLKArgumentIssue *)issue;
- (void)_accumulateValidationIssue:(CLKArgumentIssue *)issue;
- (BOOL)_shouldAccumulateValidationIssue:(CLKArgumentIssue *)issue;
- (BOOL)_hasParsingIssueForOptionNamed:(NSString *)optionName;

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
- (BOOL)_processAssignedArgument:(NSString *)argument forParameterOption:(CLKOption *)option userInvocation:(NSString *)userInvocation issue:(CLKArgumentIssue *__nullable *__nonnull)outIssue;
- (CLKAPState)_processParsedOption:(CLKOption *)option userInvocation:(NSString *)userInvocation;
- (BOOL)_processArgument:(NSString *)argument forParameterOption:(nullable CLKOption *)option issue:(CLKArgumentIssue *__nullable *__nonnull)outIssue;

#pragma mark -
#pragma mark Validation

- (BOOL)_validateManifest;

@end

NS_ASSUME_NONNULL_END
