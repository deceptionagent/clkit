//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import "NSMutableArray+CLKAdditions.h"

@implementation NSMutableArray (CLKAdditions)

- (id)clk_popFirstObject
{
    if (self.count == 0) {
        return nil;
    }
    
    id obj = self.firstObject;
    [self removeObjectAtIndex:0];
    return obj;
}

@end
