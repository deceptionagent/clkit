//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


@class CLKArgumentIssue;
@class CLKArgumentManifestConstraint;

NS_ASSUME_NONNULL_BEGIN

@interface ConstraintValidationSpec : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)specWithConstraints:(NSArray<CLKArgumentManifestConstraint *> *)constraints issues:(nullable NSArray<CLKArgumentIssue *> *)issues;
- (instancetype)initWithConstraints:(NSArray<CLKArgumentManifestConstraint *> *)constraints issues:(nullable NSArray<CLKArgumentIssue *> *)issues NS_DESIGNATED_INITIALIZER;

@property (readonly) NSArray<CLKArgumentManifestConstraint *> *constraints;
@property (nullable, readonly) NSArray<CLKArgumentIssue *> *issues;
@property (readonly) BOOL shouldPass;

@end

NS_ASSUME_NONNULL_END
