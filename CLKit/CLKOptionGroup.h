//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface CLKOptionGroup : NSObject

+ (instancetype)groupForOptionsNamed:(NSArray<NSString *> *)options;
+ (instancetype)groupForOptionsNamed:(NSArray<NSString *> *)options required:(BOOL)required;

+ (instancetype)mutexedGroupForOptionsNamed:(NSArray<NSString *> *)options;
+ (instancetype)mutexedGroupForOptionsNamed:(NSArray<NSString *> *)options required:(BOOL)required;

+ (instancetype)mutexedGroupWithSubgroups:(NSArray<CLKOptionGroup *> *)subgroups;
+ (instancetype)mutexedGroupWithSubgroups:(NSArray<CLKOptionGroup *> *)subgroups required:(BOOL)required;

//+ (instancetype)groupForOptionsNamed:(NSArray<NSString *> *)options;
//+ (instancetype)requiredGroupForOptionsNamed:(NSArray<NSString *> *)options;
//+ (instancetype)mutexedGroupForOptionsNamed:(NSArray<NSString *> *)options;
//+ (instancetype)groupForOptionsNamed:(NSArray<NSString *> *)options required:(BOOL)required mutexed:(BOOL)mutexed;
//
//+ (instancetype)groupWithSubgroups:(NSArray<CLKOptionGroup *> *)subgroups required:(BOOL)required mutexed:(BOOL)mutexed;
//
//+ (instancetype)standaloneGroupForOptionNamed:(NSString *)option allowing:(NSArray<NSString *> *)whitelistedOptionNames;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
