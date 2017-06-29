//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@protocol ArgumentTransformer <NSObject>

@required

- (nullable id)transformArgument:(NSString *)argument error:(NSError **)outError;

@end

NS_ASSUME_NONNULL_END
