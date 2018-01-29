//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString * const CLKErrorDomain;


typedef NS_ERROR_ENUM(CLKErrorDomain, CLKError) {
    CLKErrorNoError = 0,
    CLKErrorRequiredOptionNotProvided = 1,
    CLKErrorTooManyOccurrencesOfOption = 2,
    CLKErrorMutuallyExclusiveOptionsPresent = 3
};
