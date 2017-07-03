//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


@class CLKArgumentTransformer;


NS_ASSUME_NONNULL_BEGIN

@interface CLKOption : NSObject
{
    NSString *_longName;
    NSString *_shortName;
    BOOL _expectsArgument;
    CLKArgumentTransformer *_transformer;
}

// there are two basic kinds of options:
//
//    1. normal options that expect arguments
//    2. free options that don't have arguments
//
// long and short names should not include leading dashes.

+ (instancetype)optionWithLongName:(NSString *)longName shortName:(NSString *)shortName;
+ (instancetype)optionWithLongName:(NSString *)longName shortName:(NSString *)shortName transformer:(nullable CLKArgumentTransformer *)transformer;
+ (instancetype)freeOptionWithLongName:(NSString *)longName shortName:(NSString *)shortName;

- (instancetype)init NS_UNAVAILABLE;

@property (readonly) NSString *longName;
@property (readonly) NSString *shortName;
@property (readonly) BOOL expectsArgument;
@property (nullable, readonly) CLKArgumentTransformer *transformer;

@end

NS_ASSUME_NONNULL_END
