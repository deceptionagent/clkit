//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CLKOptionGroup : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)groupRequiringAnyOfOptionsNamed:(NSArray<NSString *> *)options;
+ (instancetype)groupForOptionNamed:(NSString *)option requiringAnyOfDependents:(NSArray<NSString *> *)dependentOptions;
+ (instancetype)mutexedGroupForOptionsNamed:(NSArray<NSString *> *)options;
+ (instancetype)standaloneGroupForOptionNamed:(NSString *)option allowing:(NSArray<NSString *> *)whitelistedOptions;
+ (instancetype)groupForOptionNamed:(NSString *)option requiringDependency:(NSString *)parentOption;

@end

NS_ASSUME_NONNULL_END
