//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>

#warning +groupForOption:requiringAnyOfDependents: needs test coverage

NS_ASSUME_NONNULL_BEGIN

@interface CLKOptionGroup : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)groupRequiringAnyOfOptions:(NSArray<NSString *> *)options;
+ (instancetype)groupForOption:(NSString *)option requiringAnyOfDependents:(NSArray<NSString *> *)dependentOptions;
+ (instancetype)mutexedGroupForOptions:(NSArray<NSString *> *)options;
+ (instancetype)standaloneGroupForOption:(NSString *)option allowing:(NSArray<NSString *> *)whitelistedOptions;
+ (instancetype)groupForOption:(NSString *)option requiringDependency:(NSString *)parentOption;

@end

NS_ASSUME_NONNULL_END
