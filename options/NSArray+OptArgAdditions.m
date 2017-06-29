//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import "NSArray+OptArgAdditions.h"


@implementation NSArray (OptArgAdditions)

+ (NSArray *)arrayWithArgv:(const char *[])argv argc:(int)argc
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (int i = 0 ; i < argc ; i++) {
        NSString *arg = [NSString stringWithUTF8String:argv[i]];
        [array addObject:arg];
    }
    
    return array;
}

@end
