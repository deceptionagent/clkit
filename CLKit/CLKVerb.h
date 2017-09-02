//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

typedef int (^CLKVerbBlock)(NSArray<NSString *> *, NSError **outError);


@interface CLKVerb : NSObject

+ (instancetype)verbWithName:(NSString *)name block:(CLKVerbBlock)block;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@property (readonly) NSString *name;
@property (readonly) CLKVerbBlock block;

@end

NS_ASSUME_NONNULL_END
