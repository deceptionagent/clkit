//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLKArgumentIssue;
@class CLKArgumentManifest;
@class CLKArgumentManifestConstraint;
@class CLKOption;

NS_ASSUME_NONNULL_BEGIN

typedef void (^CLKAMVIssueHandler)(CLKArgumentIssue *issue);

@interface CLKArgumentManifestValidator : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithManifest:(CLKArgumentManifest *)manifest NS_DESIGNATED_INITIALIZER;

@property (readonly) CLKArgumentManifest *manifest;

- (void)validateConstraints:(NSArray<CLKArgumentManifestConstraint *> *)constraints issueHandler:(NS_NOESCAPE CLKAMVIssueHandler)issueHandler;

@end

NS_ASSUME_NONNULL_END
