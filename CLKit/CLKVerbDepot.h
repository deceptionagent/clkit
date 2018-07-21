//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


@class CLKCommandResult;
@protocol CLKVerb;


NS_ASSUME_NONNULL_BEGIN

@interface CLKVerbDepot : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

//- (instancetype)initWithArgv:(const char * _Nonnull [])argv argc:(int)argc verbs:(NSArray<CLKVerb> *)verbs;
- (instancetype)initWithArgumentVector:(NSArray<NSString *> *)argumentVector verbs:(NSArray<id<CLKVerb>> *)verbs NS_DESIGNATED_INITIALIZER;

- (CLKCommandResult *)dispatchVerb;

@end

NS_ASSUME_NONNULL_END
