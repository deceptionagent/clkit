//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface OptArgManifest : NSObject
{
    NSMutableDictionary<NSString *, NSNumber *> *_freeOptions; // accumulation count
    NSMutableDictionary<NSString *, NSMutableArray *> *_optionArguments;
    NSMutableArray<NSString *> *_remainderArguments;
}

// cool stuff to know:
//
//    - "free options" are options that have no argument
//    - option names are always long names
//

#pragma mark -
#pragma mark Building Manifests

- (void)accumulateFreeOption:(NSString *)optionName;
- (void)accumulateArgument:(id)argument forOption:(NSString *)optionName;
- (void)accumulateRemainderArgument:(NSString *)argument;

#pragma mark -
#pragma mark Reading Manifests

@property (readonly) NSDictionary<NSString *, NSNumber *> *freeOptions;
@property (readonly) NSDictionary<NSString *, NSArray *> *optionArguments;
@property (readonly) NSArray<NSString *> *remainderArguments;

@end

NS_ASSUME_NONNULL_END
