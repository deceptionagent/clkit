//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


#define CLKHardAssert(condition, exception, fmt, ...) \
({ \
    if (!(condition)) { \
        NSString *__reason__ = [[[NSString alloc] initWithFormat: fmt, ##__VA_ARGS__] autorelease]; \
        [[NSException exceptionWithName:exception reason:__reason__ userInfo:nil] raise]; \
    } \
})

#define CLKHardParameterAssert(parameterCondition) \
({ \
    CLKHardAssert(parameterCondition, NSInvalidArgumentException, @"Invalid parameter not satisfying: %@", @#parameterCondition); \
})
