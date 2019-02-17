//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "CLKOptionGroup_Private.h"

#import "CLKArgumentManifestConstraint.h"
#import "CLKAssert.h"
#import "NSMutableArray+CLKAdditions.h"


NS_ASSUME_NONNULL_BEGIN

@interface CLKOptionGroup ()

- (instancetype)_initWithConstraints:(NSArray<CLKArgumentManifestConstraint *> *)constraints NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END

@implementation CLKOptionGroup
{
    NSArray<CLKArgumentManifestConstraint *> *_constraints;
}

@synthesize constraints = _constraints;

+ (instancetype)requiredGroupForOptionsNamed:(NSArray<NSString *> *)options
{
    return [self groupForOptionsNamed:options required:YES mutexed:NO];
}

+ (instancetype)mutexedGroupForOptionsNamed:(NSArray<NSString *> *)options
{
    return [self groupForOptionsNamed:options required:NO mutexed:YES];
}

+ (instancetype)groupForOptionsNamed:(NSArray<NSString *> *)options required:(BOOL)required mutexed:(BOOL)mutexed
{
    CLKHardParameterAssert(options != nil);
    
    if (options.count == 0) {
        return [[self alloc] _initWithConstraints:@[]];
    }
    
    NSMutableArray<CLKArgumentManifestConstraint *> *constraints = [NSMutableArray array];
    
    if (required) {
        [constraints addObject:[CLKArgumentManifestConstraint constraintRequiringRepresentationForOptions:options]];
    }
    
    if (mutexed) {
        [constraints addObject:[CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:options]];
    }
    
    if (constraints.count == 0) {
        [constraints addObject:[CLKArgumentManifestConstraint inactiveConstraintForOptions:options]];
    }
    
    return [[self alloc] _initWithConstraints:constraints];
}

+ (instancetype)standaloneGroupForOptionNamed:(NSString *)option allowing:(NSArray<NSString *> *)whitelistedOptionNames
{
    CLKHardParameterAssert(option != nil);
    CLKArgumentManifestConstraint *constraint = [CLKArgumentManifestConstraint constraintForStandaloneOption:option allowingOptions:whitelistedOptionNames];
    return [[self alloc] _initWithConstraints:@[ constraint ]];
}

- (instancetype)_initWithConstraints:(NSArray<CLKArgumentManifestConstraint *> *)constraints
{
    NSParameterAssert(constraints != nil);
    
    self = [super init];
    if (self != nil) {
        _constraints = [constraints copy];
    }
    
    return self;
}

#pragma mark -

- (NSArray<NSString *> *)allOptions
{
    NSMutableArray *allOptions = [NSMutableArray array];
    
    for (CLKArgumentManifestConstraint *constraint in _constraints) {
        [allOptions addObjectsFromArray:constraint.options.array];
        [allOptions addObjectsFromArray:constraint.auxOptions.array];
    }
    
    return allOptions;
}

@end
