//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface CLKOptArgManifest : NSObject
{
    NSMutableDictionary<NSString *, NSNumber *> *_freeOptions; // accumulation count
    NSMutableDictionary<NSString *, NSMutableArray *> *_optionArguments;
    NSMutableArray<NSString *> *_positionalArguments;
}

#pragma mark -
#pragma mark Building Manifests

- (void)accumulateFreeOptionNamed:(NSString *)name;
- (void)accumulateArgument:(id)argument forOptionNamed:(NSString *)name;
- (void)accumulatePositionalArgument:(NSString *)argument;

#pragma mark -
#pragma mark Reading Manifests

@property (readonly) NSDictionary<NSString *, NSNumber *> *freeOptions;
@property (readonly) NSDictionary<NSString *, NSArray *> *optionArguments;
@property (readonly) NSArray<NSString *> *positionalArguments;

@end

NS_ASSUME_NONNULL_END
