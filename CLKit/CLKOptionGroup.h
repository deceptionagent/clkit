//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


@class CLKOption;


NS_ASSUME_NONNULL_BEGIN

@interface CLKOptionGroup : NSObject

+ (instancetype)groupWithOptions:(NSArray<CLKOption *> *)options required:(BOOL)required;
+ (instancetype)mutexedGroupWithOptions:(NSArray<CLKOption *> *)options required:(BOOL)required;
+ (instancetype)mutexedGroupWithOptions:(nullable NSArray<CLKOption *> *)options subgroups:(nullable NSArray<CLKOptionGroup *> *)subgroups required:(BOOL)required;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@property (nullable, readonly) NSArray<CLKOption *> *options;
@property (nullable, readonly) NSArray<CLKOptionGroup *> *subgroups;
@property (readonly) BOOL mutexed;
@property (readonly) BOOL required; // at least one member of this group is required

@end

NS_ASSUME_NONNULL_END
