//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


@class CLKOption;
@class CLKArgumentManifest;


NS_ASSUME_NONNULL_BEGIN

@interface CLKArgumentParser : NSObject

+ (instancetype)parserWithArgumentVector:(NSArray<NSString *> *)argv options:(NSArray<CLKOption *> *)options;
- (instancetype)initWithArgumentVector:(NSArray<NSString *> *)argv options:(NSArray<CLKOption *> *)options NS_DESIGNATED_INITIALIZER;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (nullable CLKArgumentManifest *)parseArguments:(NSError **)outError;

@end

NS_ASSUME_NONNULL_END
