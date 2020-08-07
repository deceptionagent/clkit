//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLKArgumentManifest;
@class CLKCommandResult;
@class CLKOption;
@class CLKOptionGroup;

NS_ASSUME_NONNULL_BEGIN

@protocol CLKVerb <NSObject>

@property (readonly) NSString *name;
@property (nullable, readonly) NSArray<CLKOption *> *options;
@property (nullable, readonly) NSArray<CLKOptionGroup *> *optionGroups;

- (CLKCommandResult *)runWithManifest:(CLKArgumentManifest *)manifest;

@end

NS_ASSUME_NONNULL_END
