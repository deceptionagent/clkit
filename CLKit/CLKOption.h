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

+ (instancetype)optionWithName:(NSString *)name flag:(NSString *)flag;
+ (instancetype)optionWithName:(NSString *)name flag:(NSString *)flag transformer:(nullable CLKArgumentTransformer *)transformer;
+ (instancetype)freeOptionWithName:(NSString *)name flag:(NSString *)flag;

- (instancetype)init NS_UNAVAILABLE;

@property (readonly) NSString *name;
@property (readonly) NSString *flag;
@property (nullable, readonly) CLKArgumentTransformer *transformer;

@end

NS_ASSUME_NONNULL_END
