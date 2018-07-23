//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


@class CLKCommandResult;
@class CLKVerbFamily;
@protocol CLKVerb;


NS_ASSUME_NONNULL_BEGIN

@interface CLKVerbDepot : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithArgumentVector:(NSArray<NSString *> *)argumentVector verbs:(NSArray<id<CLKVerb>> *)verbs;
- (instancetype)initWithArgumentVector:(NSArray<NSString *> *)argumentVector
                                 verbs:(NSArray<id<CLKVerb>> *)verbs
                          verbFamilies:(nullable NSArray<CLKVerbFamily *> *)verbFamilies NS_DESIGNATED_INITIALIZER;

- (CLKCommandResult *)dispatchVerb;

@end

NS_ASSUME_NONNULL_END
