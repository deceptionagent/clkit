//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


@class CLKOption;


NS_ASSUME_NONNULL_BEGIN

@interface CLKOptionGroup : NSObject

+ (instancetype)groupForOptionsNamed:(NSArray<NSString *> *)options;
+ (instancetype)groupForOptionsNamed:(NSArray<NSString *> *)options required:(BOOL)required;
+ (instancetype)groupForOptionsNamed:(NSArray<NSString *> *)options restricted:(BOOL)restricted;
+ (instancetype)mutexedGroupForOptionsNamed:(NSArray<NSString *> *)options;
+ (instancetype)mutexedGroupForOptionsNamed:(NSArray<NSString *> *)options required:(BOOL)required;
+ (instancetype)mutexedGroupForOptionsNamed:(nullable NSArray<NSString *> *)options subgroups:(nullable NSArray<CLKOptionGroup *> *)subgroups required:(BOOL)required;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@property (nullable, readonly) NSArray<NSString *> *options;
@property (nullable, readonly) NSArray<CLKOptionGroup *> *subgroups;
@property (readonly) BOOL mutexed;
@property (readonly) BOOL required; // at least one member of this group is required
@property (readonly) BOOL restricted;

@end

NS_ASSUME_NONNULL_END
