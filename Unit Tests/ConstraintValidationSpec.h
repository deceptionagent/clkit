//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


@class CLKArgumentManifestConstraint;

NS_ASSUME_NONNULL_BEGIN

@interface ConstraintValidationSpec : NSObject

+ (instancetype)specWithConstraints:(NSArray<CLKArgumentManifestConstraint *> *)constraints errors:(nullable NSArray<NSError *> *)errors;
- (instancetype)initWithConstraints:(NSArray<CLKArgumentManifestConstraint *> *)constraints errors:(nullable NSArray<NSError *> *)errors NS_DESIGNATED_INITIALIZER;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@property (readonly) NSArray<CLKArgumentManifestConstraint *> *constraints;
@property (nullable, readonly) NSArray<NSError *> *errors;
@property (readonly) BOOL shouldPass;

@end

NS_ASSUME_NONNULL_END
