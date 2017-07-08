//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


@class CLKArgumentTransformer;


NS_ASSUME_NONNULL_BEGIN

@interface CLKOption : NSObject
{
    NSString *_name;
    NSString *_flag;
    BOOL _expectsArgument;
    CLKArgumentTransformer *_transformer;
}

// there are two basic kinds of options:
//
//    1. normal options that expect arguments
//    2. free options that don't have arguments
//
// names and flags should not include leading dashes.

+ (instancetype)optionWithName:(NSString *)name flag:(NSString *)flag;
+ (instancetype)optionWithName:(NSString *)name flag:(NSString *)flag transformer:(nullable CLKArgumentTransformer *)transformer;
+ (instancetype)freeOptionWithName:(NSString *)name flag:(NSString *)flag;

- (instancetype)init NS_UNAVAILABLE;

@property (readonly) NSString *name;
@property (readonly) NSString *flag;
@property (readonly) BOOL expectsArgument;
@property (nullable, readonly) CLKArgumentTransformer *transformer;

@end

NS_ASSUME_NONNULL_END
