//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CLKHardAssert(condition, exception, ...) \
({ \
    if (!(condition)) { \
        NSString *__reason__ = [[NSString alloc] initWithFormat:__VA_ARGS__]; \
        [[NSException exceptionWithName:exception reason:__reason__ userInfo:nil] raise]; \
    } \
})

#define CLKHardParameterAssert(parameterCondition, ...) \
({ \
    if (!(parameterCondition)) { \
        NSString *__reason__ = [[NSString alloc] initWithFormat:@"Invalid parameter not satisfying: %@", @#parameterCondition]; \
        NSString *__extendedReason__ = [[NSString alloc] initWithFormat:@"" __VA_ARGS__]; \
        if (__extendedReason__.length > 0) { \
            __reason__ = [__reason__ stringByAppendingFormat:@" (%@)", __extendedReason__]; \
        } \
\
        [[NSException exceptionWithName:NSInvalidArgumentException reason:__reason__ userInfo:nil] raise]; \
    } \
})

#if NS_BLOCK_ASSERTIONS
    #define CLKParameterAssert(parameterCondition, ...) do {} while (0)
#else
    #define CLKParameterAssert(parameterCondition, ...) CLKHardParameterAssert(parameterCondition, __VA_ARGS__)
#endif

