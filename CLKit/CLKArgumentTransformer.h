//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface CLKArgumentTransformer : NSObject

+ (instancetype)transformer;

- (nullable id)transformedArgument:(NSString *)argument error:(NSError **)outError;

@end

@interface CLKIntArgumentTransformer : CLKArgumentTransformer

@end

@interface CLKFloatArgumentTransformer : CLKArgumentTransformer

@end

NS_ASSUME_NONNULL_END
