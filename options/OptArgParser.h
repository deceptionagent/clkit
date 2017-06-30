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


@class Option;
@class OptArgManifest;


NS_ASSUME_NONNULL_BEGIN

@interface OptArgParser : NSObject
{
    OAParserState _state;
    Option *_currentOption;
    NSMutableArray<NSString *> *_argumentVector;
    NSMutableDictionary<NSString *, Option *> *_longOptionMap;
    NSMutableDictionary<NSString *, Option *> *_shortOptionMap;
    OptArgManifest *_manifest;
}

+ (instancetype)parserWithArgumentVector:(NSArray<NSString *> *)argv options:(NSArray<Option *> *)options;
- (instancetype)initWithArgumentVector:(NSArray<NSString *> *)argv options:(NSArray<Option *> *)options NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

- (nullable OptArgManifest *)parseArguments:(NSError **)outError;

@end

NS_ASSUME_NONNULL_END
