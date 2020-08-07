//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLKOption;

NS_ASSUME_NONNULL_BEGIN

@interface CLKOptionRegistry : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)registryWithOptions:(NSArray<CLKOption *> *)options;
- (instancetype)initWithOptions:(NSArray<CLKOption *> *)options NS_DESIGNATED_INITIALIZER;

- (nullable CLKOption *)optionNamed:(NSString *)name;
- (nullable CLKOption *)optionForFlag:(NSString *)flag;

- (BOOL)hasOptionNamed:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
