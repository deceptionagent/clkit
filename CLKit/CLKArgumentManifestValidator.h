//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


@class CLKArgumentManifest;
@class CLKArgumentManifestConstraint;
@class CLKOption;


NS_ASSUME_NONNULL_BEGIN

typedef void (^CLKAMVIssueHandler)(NSError *error);

@interface CLKArgumentManifestValidator : NSObject

- (instancetype)initWithManifest:(CLKArgumentManifest *)manifest NS_DESIGNATED_INITIALIZER;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@property (nonnull, readonly) CLKArgumentManifest *manifest;

- (void)validateConstraints:(NSArray<CLKArgumentManifestConstraint *> *)constraints issueHandler:(CLKAMVIssueHandler)issueHandler;

@end

NS_ASSUME_NONNULL_END
