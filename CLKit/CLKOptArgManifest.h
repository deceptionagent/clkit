//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface CLKOptArgManifest : NSObject

@property (readonly) NSDictionary<NSString *, NSNumber *> *freeOptions;
@property (readonly) NSDictionary<NSString *, NSArray *> *optionArguments;
@property (readonly) NSArray<NSString *> *positionalArguments;

@end

NS_ASSUME_NONNULL_END
