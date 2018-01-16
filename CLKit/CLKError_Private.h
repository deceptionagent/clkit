//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#define CLKSetOutError(__outError__, __error__) \
    if (__outError__ != nil) { \
        *__outError__ = __error__; \
    }
