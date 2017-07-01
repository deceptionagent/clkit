//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(uint32_t, OAParserState) {
    OAPStateBegin = 0,
    OAPStateReadNextItem,
    OAPStateParseLongOption,
    OAPStateParseShortOption,
    OAPStateParseShortOptionGroup,
    OAPStateParseArgument,
    OAPStateError,
    OAPStateEnd
};


@class CLKOption;
@class CLKOptArgManifest;


NS_ASSUME_NONNULL_BEGIN

@interface CLKOptArgParser : NSObject
{
    OAParserState _state;
    CLKOption *_currentOption;
    NSMutableArray<NSString *> *_argumentVector;
    NSMutableDictionary<NSString *, CLKOption *> *_longOptionMap;
    NSMutableDictionary<NSString *, CLKOption *> *_shortOptionMap;
    CLKOptArgManifest *_manifest;
}

+ (instancetype)parserWithArgumentVector:(NSArray<NSString *> *)argv options:(NSArray<CLKOption *> *)options;
- (instancetype)initWithArgumentVector:(NSArray<NSString *> *)argv options:(NSArray<CLKOption *> *)options NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

- (nullable CLKOptArgManifest *)parseArguments:(NSError **)outError;

@end

NS_ASSUME_NONNULL_END
