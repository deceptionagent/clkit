//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


@class CLKArgumentTransformer;


NS_ASSUME_NONNULL_BEGIN

@interface CLKOption : NSObject

// there are two basic kinds of options:
//
//    1. "payload" options that expect arguments
//    2. "free" options that don't have arguments
//
// names and flags should not include leading dashes.

+ (instancetype)optionWithName:(NSString *)name flag:(nullable NSString *)flag;
+ (instancetype)optionWithName:(NSString *)name flag:(nullable NSString *)flag required:(BOOL)required;
+ (instancetype)optionWithName:(NSString *)name flag:(nullable NSString *)flag transformer:(nullable CLKArgumentTransformer *)transformer;
+ (instancetype)optionWithName:(NSString *)name flag:(nullable NSString *)flag required:(BOOL)required transformer:(nullable CLKArgumentTransformer *)transformer;
+ (instancetype)freeOptionWithName:(NSString *)name flag:(nullable NSString *)flag;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@property (readonly) NSString *name;
@property (nullable, readonly) NSString *flag;
@property (readonly) BOOL required;
@property (nullable, readonly) CLKArgumentTransformer *transformer;

@end

NS_ASSUME_NONNULL_END
