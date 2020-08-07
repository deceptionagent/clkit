//
//  Copyright (c) 2020 Plastic Pulse. All rights reserved.
//

#import "CLKArgumentIssue.h"

#import "CLKError.h"

NS_ASSUME_NONNULL_BEGIN

@interface CLKArgumentIssue ()

- (instancetype)_initWithError:(NSError *)error salientOptions:(nullable NSArray<NSString *> *)options NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END

@implementation CLKArgumentIssue
{
    NSError *_error;
    NSArray<NSString *> *_salientOptions;
}

@synthesize error = _error;
@synthesize salientOptions = _salientOptions;

+ (instancetype)issueWithError:(NSError *)error
{
    return [[self alloc] _initWithError:error salientOptions:nil];
}

+ (instancetype)issueWithError:(NSError *)error salientOption:(NSString *)option
{
    return [self issueWithError:error salientOptions:(option != nil ? @[ option ] : nil)];
}

+ (instancetype)issueWithError:(NSError *)error salientOptions:(NSArray<NSString *> *)options
{
    return [[self alloc] _initWithError:error salientOptions:options];
}

- (instancetype)_initWithError:(NSError *)error salientOptions:(NSArray<NSString *> *)options
{
    self = [super init];
    if (self != nil) {
        _error = error;
        _salientOptions = [options copy];
    }
    
    return self;
}

- (NSUInteger)hash
{
    return (_error.hash ^ _salientOptions.hash);
}

- (BOOL)isEqual:(id)obj
{
    if (obj == self) {
        return YES;
    }
    
    if (![obj isKindOfClass:[CLKArgumentIssue class]]) {
        return NO;
    }
    
    return [self isEqualToIssue:(CLKArgumentIssue *)obj];
}

- (BOOL)isEqualToIssue:(CLKArgumentIssue *)issue
{
    if (![_error isEqual:issue.error]) {
        return NO;
    }
    
    if ((_salientOptions != nil) != (issue.salientOptions != nil)) {
        return NO;
    }
    
    BOOL compareSalientOptions = (_salientOptions != nil && issue.salientOptions != nil);
    if (compareSalientOptions && ![_salientOptions isEqualToArray:issue.salientOptions]) {
        return NO;
    }
    
    return YES;
}

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"%@ {\n    error: %@,\n    salientOptions: [ %@ ]\n}", super.debugDescription, _error.debugDescription, [_salientOptions componentsJoinedByString:@", "]];
}

- (BOOL)isValidationIssue
{
    if (![_error.domain isEqualToString:CLKErrorDomain]) {
        return NO;
    }
    
    return (_error.code == CLKErrorRequiredOptionNotProvided
            || _error.code == CLKErrorTooManyOccurrencesOfOption
            || _error.code == CLKErrorMutuallyExclusiveOptionsPresent);
}

@end
