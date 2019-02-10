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
+ (instancetype)flarnVerb; // --alpha (-a)
+ (instancetype)barfVerb;  // --bravo (-b)
+ (instancetype)quoneVerb; // --charlie (-c)
+ (instancetype)xyzzyVerb; // --delta (-d)
+ (instancetype)synVerb;   // --echo (-e)
+ (instancetype)ackVerb;   // --foxtrot (-f)

+ (instancetype)verbWithName:(NSString *)name option:(CLKOption *)option;
+ (instancetype)verbWithName:(NSString *)name options:(nullable NSArray<CLKOption *> *)options;

- (instancetype)initWithName:(NSString *)name
                     options:(nullable NSArray<CLKOption *> *)options
                optionGroups:(nullable NSArray<CLKOptionGroup *> *)optionGroups NS_DESIGNATED_INITIALIZER;

@property (nullable, copy) CLKCommandResult *(^runWithManifest_impl)(CLKArgumentManifest *);

@end

NS_ASSUME_NONNULL_END
