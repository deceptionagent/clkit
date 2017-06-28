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

+ (instancetype)optionWithLongName:(NSString *)longName shortName:(NSString *)shortName hasArgument:(BOOL)hasArgument;
- (instancetype)initWithLongName:(NSString *)longName shortName:(NSString *)shortName hasArgument:(BOOL)hasArgument;

@property (readonly) NSString *longName;
@property (readonly) NSString *shortName;
@property (readonly) BOOL hasArgument;
@property (nullable, retain) id<ArgumentTransformer> argumentTransformer;

@end

NS_ASSUME_NONNULL_END
