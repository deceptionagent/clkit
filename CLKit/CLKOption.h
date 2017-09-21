//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(uint32_t, CLKOptionType) {
    CLKOptionTypeSwitch = 0,
    CLKOptionTypeParameter = 1
};


@class CLKArgumentTransformer;


NS_ASSUME_NONNULL_BEGIN

@interface CLKOption : NSObject

// CLKOptionTypeSwitch
+ (instancetype)optionWithName:(NSString *)name flag:(nullable NSString *)flag;

// CLKOptionTypeParameter
+ (instancetype)parameterOptionWithName:(NSString *)name flag:(nullable NSString *)flag;
+ (instancetype)parameterOptionWithName:(NSString *)name flag:(nullable NSString *)flag required:(BOOL)required;
+ (instancetype)parameterOptionWithName:(NSString *)name flag:(nullable NSString *)flag transformer:(nullable CLKArgumentTransformer *)transformer;
+ (instancetype)parameterOptionWithName:(NSString *)name flag:(nullable NSString *)flag required:(BOOL)required transformer:(nullable CLKArgumentTransformer *)transformer;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@property (readonly) NSString *name;
@property (nullable, readonly) NSString *flag;
@property (readonly) BOOL required;
@property (nullable, readonly) CLKArgumentTransformer *transformer;
@property (readonly) CLKOptionType type;

@end

NS_ASSUME_NONNULL_END
