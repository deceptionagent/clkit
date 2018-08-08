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

@interface CLKOption : NSObject <NSCopying>

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

#pragma mark -
#pragma mark Switch Options

+ (instancetype)optionWithName:(NSString *)name flag:(nullable NSString *)flag;
+ (instancetype)optionWithName:(NSString *)name flag:(nullable NSString *)flag dependencies:(nullable NSArray<NSString *> *)dependencies;

#pragma mark -
#pragma mark Parameter Options

+ (instancetype)parameterOptionWithName:(NSString *)name flag:(nullable NSString *)flag;
+ (instancetype)parameterOptionWithName:(NSString *)name flag:(nullable NSString *)flag required:(BOOL)required;
+ (instancetype)parameterOptionWithName:(NSString *)name flag:(nullable NSString *)flag recurrent:(BOOL)recurrent;
+ (instancetype)parameterOptionWithName:(NSString *)name flag:(nullable NSString *)flag dependencies:(nullable NSArray<NSString *> *)dependencies;
+ (instancetype)parameterOptionWithName:(NSString *)name flag:(nullable NSString *)flag transformer:(nullable CLKArgumentTransformer *)transformer;

+ (instancetype)parameterOptionWithName:(NSString *)name
                                   flag:(nullable NSString *)flag
                               required:(BOOL)required
                              recurrent:(BOOL)recurrent
                           dependencies:(nullable NSArray<NSString *> *)dependencies
                            transformer:(nullable CLKArgumentTransformer *)transformer;

#pragma mark -

@property (readonly) CLKOptionType type;
@property (readonly) NSString *name;
@property (nullable, readonly) NSString *flag;
@property (readonly) BOOL required;
@property (readonly) BOOL recurrent;
@property (nullable, readonly) NSArray<NSString *> *dependencies;
@property (nullable, readonly) CLKArgumentTransformer *transformer;

- (BOOL)isEqualToOption:(CLKOption *)option;

@end

NS_ASSUME_NONNULL_END
