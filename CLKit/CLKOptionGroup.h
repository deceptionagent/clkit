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

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@property (nullable, readonly) NSArray<NSString *> *options;
@property (nullable, readonly) NSArray<CLKOptionGroup *> *subgroups;
@property (readonly) BOOL mutexed;
@property (readonly) BOOL required; // at least one member of this group is required

@end

NS_ASSUME_NONNULL_END
