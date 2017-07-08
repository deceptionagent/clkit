//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(uint32_t, CLKOAPState) {
    CLKOAPStateBegin = 0,
    CLKOAPStateReadNextItem,
    CLKOAPStateParseOptionName,
    CLKOAPStateParseOptionFlag,
    CLKOAPStateParseOptionFlagGroup,
    CLKOAPStateParseArgument,
    CLKOAPStateError,
    CLKOAPStateEnd
};


@class CLKOption;
@class CLKOptArgManifest;


NS_ASSUME_NONNULL_BEGIN

@interface CLKOptArgParser : NSObject
{
    CLKOAPState _state;
    CLKOption *_currentOption;
    NSMutableArray<NSString *> *_argumentVector;
    NSMutableDictionary<NSString *, CLKOption *> *_optionNameMap;
    NSMutableDictionary<NSString *, CLKOption *> *_optionFlagMap;
    CLKOptArgManifest *_manifest;
}

+ (instancetype)parserWithArgumentVector:(NSArray<NSString *> *)argv options:(NSArray<CLKOption *> *)options;

- (instancetype)initWithArgumentVector:(NSArray<NSString *> *)argv options:(NSArray<CLKOption *> *)options NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

- (nullable CLKOptArgManifest *)parseArguments:(NSError **)outError;

@end

NS_ASSUME_NONNULL_END
