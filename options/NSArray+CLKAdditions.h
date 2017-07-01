//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSArray (CLKAdditions)

+ (NSArray *)clk_arrayWithArgv:(const char *[])argv argc:(int)argc;

@end
