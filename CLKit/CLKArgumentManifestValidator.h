//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


@class CLKArgumentManifest;
@class CLKArgumentManifestConstraint;
@class CLKOption;


NS_ASSUME_NONNULL_BEGIN

@interface CLKArgumentManifestValidator : NSObject

- (instancetype)initWithManifest:(CLKArgumentManifest *)manifest NS_DESIGNATED_INITIALIZER;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (BOOL)validateConstraints:(NSArray<CLKArgumentManifestConstraint *> *)constraints error:(NSError **)outError;

@end

NS_ASSUME_NONNULL_END
