//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "CLKCommandResult.h"


@implementation CLKCommandResult
{
    int _exitStatus;
    NSArray<NSError *> *_errors;
    NSDictionary *_userInfo;
}

@synthesize exitStatus = _exitStatus;
@synthesize errors = _errors;
@synthesize userInfo = _userInfo;

+ (instancetype)resultWithExitStatus:(int)exitStatus
{
    return [[[self alloc] initWithExitStatus:exitStatus errors:nil userInfo:nil] autorelease];
}

+ (instancetype)resultWithExitStatus:(int)exitStatus errors:(NSArray<NSError *> *)errors
{
    return [[[self alloc] initWithExitStatus:exitStatus errors:errors userInfo:nil] autorelease];
}

- (instancetype)initWithExitStatus:(int)exitStatus errors:(NSArray<NSError *> *)errors userInfo:(NSDictionary *)userInfo
{
    self = [super init];
    if (self != nil) {
        _exitStatus = exitStatus;
        _errors = [errors copy];
        _userInfo = [userInfo copy];
    }
    
    return self;
}

- (void)dealloc
{
    [_errors release];
    [_userInfo release];
    [super dealloc];
}

- (NSString *)errorDescription
{
    if (self.errors.count == 0) {
        return nil;
    }
    
    NSMutableString *errorDescription = [NSMutableString string];
    
    for (NSUInteger i = 0 ; i < self.errors.count ; i++) {
        if (i > 0) {
            [errorDescription appendString:@"\n"];
        }
        
        NSError *error = self.errors[i];
        [errorDescription appendFormat:@"%@ (%@: %ld)", error.localizedDescription, error.domain, error.code];
    }
    
    return errorDescription;
}

@end