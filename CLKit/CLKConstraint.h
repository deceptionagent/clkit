//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


@class CLKOption;
@class CLKOptionGroup;


NS_ASSUME_NONNULL_BEGIN

@interface CLKConstraint : NSObject

+ (instancetype)constraintForRequiredOption:(CLKOption *)option;

// it makes no sense to have empty constraints, so at least one of `options` or `groups` is required
- (instancetype)initWithOptions:(nullable NSArray<CLKOption *> *)options
                         groups:(nullable NSArray<CLKOptionGroup *> *)groups
                       required:(BOOL)required
                        mutexed:(BOOL)mutexed NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@property (readonly) BOOL required;
@property (readonly) BOOL mutexed;
@property (nullable, readonly) NSArray<CLKOption *> *options;
@property (nullable, readonly) NSArray<CLKOptionGroup *> *groups;

@end

NS_ASSUME_NONNULL_END
