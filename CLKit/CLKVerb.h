//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

typedef int (^CLKVerbBlock)(NSArray<NSString *> *, NSError **outError);


@interface CLKVerb : NSObject
{
    NSString *_name;
    CLKVerbBlock _block;
}

+ (instancetype)verbWithName:(NSString *)name block:(CLKVerbBlock)block;

- (instancetype)init NS_UNAVAILABLE;

@property (readonly) NSString *name;
@property (readonly) CLKVerbBlock block;

@end

NS_ASSUME_NONNULL_END
