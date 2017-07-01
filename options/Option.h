//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


@class ArgumentTransformer;


NS_ASSUME_NONNULL_BEGIN

@interface Option : NSObject
{
    NSString *_longName;
    NSString *_shortName;
    BOOL _hasArgument;
    ArgumentTransformer *_transformer;
}

// there are two basic kinds of options:
//
//    1. normal options that expect arguments
//    2. free options that don't have arguments
//
// long and short names should not include leading dashes.
+ (instancetype)optionWithLongName:(NSString *)longName shortName:(NSString *)shortName;
+ (instancetype)optionWithLongName:(NSString *)longName shortName:(NSString *)shortName transformer:(nullable ArgumentTransformer *)transformer;
+ (instancetype)freeOptionWithLongName:(NSString *)longName shortName:(NSString *)shortName;

- (instancetype)init NS_UNAVAILABLE;

@property (readonly) NSString *longName;
@property (readonly) NSString *shortName;
@property (readonly) BOOL hasArgument;
@property (nullable, readonly) ArgumentTransformer *transformer;

@end

NS_ASSUME_NONNULL_END
