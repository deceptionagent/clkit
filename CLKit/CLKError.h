//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString * const CLKErrorDomain;

typedef NS_ERROR_ENUM(CLKErrorDomain, CLKError) {
    CLKErrorNoError = 0,
    
    // parsing errors
    CLKErrorParameterArgumentParsingFailed = 1,
    
    // manifest validation errors
    CLKErrorRequiredOptionNotProvided = 100,
    CLKErrorTooManyOccurrencesOfOption = 101,
    CLKErrorMutuallyExclusiveOptionsPresent = 102,
    
    // verb errors
    CLKErrorNoVerbSpecified = 200,
    CLKErrorUnrecognizedVerb = 201
};
