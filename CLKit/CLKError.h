//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString * const CLKErrorDomain;


typedef NS_ERROR_ENUM(CLKErrorDomain, CLKError) {
    CLKErrorRequiredOptionNotProvided = 1,
    CLKErrorTooManyOccurrencesOfOption = 2
};
