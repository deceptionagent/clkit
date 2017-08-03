//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

extern NSString * const CLKVerbDepotErrorDomain;


@class CLKVerb;


@interface CLKVerbDepot : NSObject

- (instancetype)initWithArgumentVector:(NSArray<NSString *> *)argumentVector verbs:(NSArray<CLKVerb *> *)verbs NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

- (int)dispatch:(NSError **)outError;

@end

NS_ASSUME_NONNULL_END
