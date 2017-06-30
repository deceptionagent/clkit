//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol ArgumentTransformer;


NS_ASSUME_NONNULL_BEGIN

@interface Option : NSObject
{
    NSString *_longName;
    NSString *_shortName;
    BOOL _hasArgument;
    id<ArgumentTransformer> _argumentTransformer;
}

// there are two basic kinds of options:
//    - normal options that expect arguments
//    - free options that don't have arguments
//
// long and short names should not include leading dashes.
+ (instancetype)optionWithLongName:(NSString *)longName shortName:(NSString *)shortName;
+ (instancetype)freeOptionWithLongName:(NSString *)longName shortName:(NSString *)shortName;

- (instancetype)init NS_UNAVAILABLE;

@property (readonly) NSString *longName;
@property (readonly) NSString *shortName;
@property (readonly) BOOL hasArgument;
@property (nullable, retain) id<ArgumentTransformer> argumentTransformer;

@end

NS_ASSUME_NONNULL_END
