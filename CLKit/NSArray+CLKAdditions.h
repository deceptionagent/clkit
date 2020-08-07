//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (CLKAdditions)

+ (NSArray<NSString *> *)clk_arrayWithArgv:(const char *_Nonnull [_Nonnull])argv argc:(int)argc;

@end

NS_ASSUME_NONNULL_END
