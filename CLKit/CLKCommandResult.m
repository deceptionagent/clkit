//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "CLKCommandResult.h"

#import "CLKError.h"


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
    return [[self alloc] initWithExitStatus:exitStatus errors:nil userInfo:nil];
}

+ (instancetype)resultWithExitStatus:(int)exitStatus errors:(NSArray<NSError *> *)errors
{
    return [[self alloc] initWithExitStatus:exitStatus errors:errors userInfo:nil];
}

+ (instancetype)resultWithExitStatus:(int)exitStatus userInfo:(NSDictionary *)userInfo
{
    return [[self alloc] initWithExitStatus:exitStatus errors:nil userInfo:userInfo];
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

- (NSString *)errorDescription
{
    if (self.errors.count == 0) {
        return nil;
    }
    
    NSMutableArray<NSString *> *errorDescriptions = [NSMutableArray array];
    for (NSError *error in self.errors) {
        [errorDescriptions addObject:error.localizedDescription];
    }
    
    return [errorDescriptions componentsJoinedByString:@"\n"];
}

@end
