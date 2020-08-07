//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLKArgumentManifest;
@class CLKOption;
@class CLKOptionGroup;

NS_ASSUME_NONNULL_BEGIN

@interface CLKArgumentParser : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)parserWithArgumentVector:(NSArray<NSString *> *)argv options:(NSArray<CLKOption *> *)options;
+ (instancetype)parserWithArgumentVector:(NSArray<NSString *> *)argv options:(NSArray<CLKOption *> *)options optionGroups:(nullable NSArray<CLKOptionGroup *> *)groups;

- (nullable CLKArgumentManifest *)parseArguments;

@property (nullable, readonly) NSArray<NSError *> *errors;

@end

NS_ASSUME_NONNULL_END
