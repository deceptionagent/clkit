//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSArray (OptArgAdditions)

+ (NSArray *)arrayWithArgv:(const char *[])argv argc:(int)argc;

@end
