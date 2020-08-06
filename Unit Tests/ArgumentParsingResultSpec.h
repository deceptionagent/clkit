//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CLKError.h"


NS_ASSUME_NONNULL_BEGIN

@interface ArgumentParsingResultSpec : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)specWithEmptyManifest;
+ (instancetype)specWithSwitchOption:(NSString *)option occurrences:(NSUInteger)occurrences;
+ (instancetype)specWithSwitchOption:(NSString *)option occurrences:(NSUInteger)occurrences positionalArguments:(NSArray<NSString *> *)positionalArguments;
+ (instancetype)specWithOptionManifest:(NSDictionary<NSString *, id> *)optionManifest;
+ (instancetype)specWithPositionalArguments:(NSArray<NSString *> *)positionalArguments;
+ (instancetype)specWithOptionManifest:(NSDictionary<NSString *, id> *)optionManifest positionalArguments:(NSArray<NSString *> *)positionalArguments;

+ (instancetype)specWithError:(NSError *)error;
+ (instancetype)specWithErrors:(NSArray<NSError *> *)errors;
+ (instancetype)specWithCLKErrorCode:(CLKError)code description:(NSString *)description;
+ (instancetype)specWithCLKErrorCode:(CLKError)code representedOptions:(NSArray<NSString *> *)options description:(NSString *)description;
+ (instancetype)specWithPOSIXErrorCode:(int)code description:(NSString *)description;
+ (instancetype)specWithPOSIXErrorCode:(int)code representedOptions:(NSArray<NSString *> *)options description:(NSString *)description;

@property (nullable, readonly) NSDictionary<NSString *, id> *optionManifest;
@property (nullable, readonly) NSArray<NSString *> *positionalArguments;
@property (nullable, readonly) NSArray<NSError *> *errors;
@property (readonly) BOOL parserShouldSucceed;

@end

NS_ASSUME_NONNULL_END
