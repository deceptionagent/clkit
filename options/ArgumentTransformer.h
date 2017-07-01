//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface ArgumentTransformer : NSObject

+ (instancetype)transformer;

- (nullable id)transformedArgument:(NSString *)argument error:(NSError **)outError;

@end


@interface IntegerArgumentTransformer : ArgumentTransformer

@end


@interface FloatArgumentTransformer : ArgumentTransformer

@end

NS_ASSUME_NONNULL_END
