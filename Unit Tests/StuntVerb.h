//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CLKVerb.h"


@class CLKArgumentManifest;
@class CLKCommandResult;
@class CLKOption;
@class CLKOptionGroup;


NS_ASSUME_NONNULL_BEGIN

@interface StuntVerb : NSObject <CLKVerb>

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

// simple verbs that always return success
+ (instancetype)flarnVerb; // --barf (-b)
+ (instancetype)quoneVerb; // --xyxxy (-x)

+ (instancetype)verbWithName:(NSString *)name options:(nullable NSArray<CLKOption *> *)options;

- (instancetype)initWithName:(NSString *)name
                        help:(NSString *)help
                      pubilc:(BOOL)public
                     options:(nullable NSArray<CLKOption *> *)options
                optionGroups:(nullable NSArray<CLKOptionGroup *> *)optionGroups NS_DESIGNATED_INITIALIZER;

@property (nullable, copy) CLKCommandResult *(^runWithManifest_impl)(CLKArgumentManifest *);

@end

NS_ASSUME_NONNULL_END
