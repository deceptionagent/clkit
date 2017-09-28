//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface CLKArgumentManifest : NSObject

- (nullable id)objectForKeyedSubscript:(NSString *)key;

@property (readonly) NSArray<NSString *> *positionalArguments;

@end

NS_ASSUME_NONNULL_END
