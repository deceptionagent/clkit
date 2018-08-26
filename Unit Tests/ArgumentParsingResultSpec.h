//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface ArgumentParsingResultSpec : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)specWithEmptyManifest;
+ (instancetype)specWithOptionManifest:(NSDictionary<NSString *, id> *)optionManifest;
+ (instancetype)specWithPositionalArguments:(NSArray<NSString *> *)positionalArguments;
+ (instancetype)specWithOptionManifest:(NSDictionary<NSString *, id> *)optionManifest positionalArguments:(NSArray<NSString *> *)positionalArguments;
+ (instancetype)specWithErrors:(NSArray<NSError *> *)errors;

@property (nullable, readonly) NSDictionary<NSString *, id> *optionManifest;
@property (nullable, readonly) NSArray<NSString *> *positionalArguments;
@property (nullable, readonly) NSArray<NSError *> *errors;
@property (readonly) BOOL parserShouldSucceed;

@end

NS_ASSUME_NONNULL_END
