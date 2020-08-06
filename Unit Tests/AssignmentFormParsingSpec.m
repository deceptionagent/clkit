//
//  Copyright (c) 2020 Plastic Pulse. All rights reserved.
//

#import "AssignmentFormParsingSpec.h"


@implementation AssignmentFormParsingSpec
{
    NSString *_optionSegment;
    NSString *_operator;
    NSString *_argumentSegment;
}

@synthesize argumentSegment = _argumentSegment;

- (instancetype)initWithOptionSegment:(NSString *)optionSegment operator:(NSString *)operator argumentSegment:(NSString *)argumentSegment
{
    self = [super init];
    if (self != nil) {
        _optionSegment = [optionSegment copy];
        _operator = [operator copy];
        _argumentSegment = [argumentSegment copy];
    }
    
    return self;
}

- (NSString *)debugDescription
{
    return self.composedToken;
}

- (NSString *)composedToken
{
    return [NSString stringWithFormat:@"%@%@%@", _optionSegment, _operator, _argumentSegment];
}

- (BOOL)malformed
{
    return ([_optionSegment isEqualToString:@"-"] || [_optionSegment isEqualToString:@"--"]);
}

@end
