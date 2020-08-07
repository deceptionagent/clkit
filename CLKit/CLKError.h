//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const CLKErrorDomain;

NS_ASSUME_NONNULL_END

typedef NS_ERROR_ENUM(CLKErrorDomain, CLKError) {
    CLKErrorNoError = 0,
    
    // manifest validation errors
    CLKErrorRequiredOptionNotProvided = 100,
    CLKErrorTooManyOccurrencesOfOption = 101,
    CLKErrorMutuallyExclusiveOptionsPresent = 102,
    
    // verb errors
    CLKErrorNoVerbSpecified = 200,
    CLKErrorUnrecognizedVerb = 201
};
