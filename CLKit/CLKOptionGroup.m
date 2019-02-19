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
    CLKHardParameterAssert(options.count > 0, @"one or more option names required for required group");
    CLKArgumentManifestConstraint *constraint = [CLKArgumentManifestConstraint constraintRequiringRepresentationForOptions:options];
    return [[self alloc] _initWithConstraints:@[ constraint ]];
}

+ (instancetype)mutexedGroupForOptionsNamed:(NSArray<NSString *> *)options
{
    CLKHardParameterAssert(options.count > 1, @"two or more option names required for mutexed group");
    CLKArgumentManifestConstraint *constraint = [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:options];
    return [[self alloc] _initWithConstraints:@[ constraint ]];
}

+ (instancetype)standaloneGroupForOptionNamed:(NSString *)option allowing:(NSArray<NSString *> *)whitelistedOptionNames
{
    CLKHardParameterAssert(option != nil);
    CLKArgumentManifestConstraint *constraint = [CLKArgumentManifestConstraint constraintForStandaloneOption:option allowingOptions:whitelistedOptionNames];
    return [[self alloc] _initWithConstraints:@[ constraint ]];
}

+ (instancetype)groupForOptionNamed:(NSString *)option requiringDependencies:(NSArray<NSString *> *)dependencies
{
    CLKHardParameterAssert(option != nil);
    CLKHardParameterAssert((dependencies.count > 0), @"dependency groups require one or more options");
    CLKHardParameterAssert(![dependencies containsObject:option], @"dependent option '%@' found in dependency array", option);
    NSUInteger uniqueDependencyCount = [NSSet setWithArray:dependencies].count;
    CLKHardParameterAssert((uniqueDependencyCount == dependencies.count), @"dependency arrays should not contain duplicate options");
    
    NSMutableArray<CLKArgumentManifestConstraint *> *constraints = [NSMutableArray array];
    for (NSString *dependency in dependencies) {
        CLKArgumentManifestConstraint *constraint = [CLKArgumentManifestConstraint constraintForConditionallyRequiredOption:dependency causalOption:option];
        [constraints addObject:constraint];
    }
    
    return [[self alloc] _initWithConstraints:constraints];
}

- (instancetype)_initWithConstraints:(NSArray<CLKArgumentManifestConstraint *> *)constraints
{
    NSParameterAssert(constraints.count > 0);
    
    self = [super init];
    if (self != nil) {
        _constraints = [constraints copy];
    }
    
    return self;
}

#pragma mark -

- (NSSet<NSString *> *)allOptions
{
    NSMutableSet *allOptions = [NSMutableSet set];
    
    for (CLKArgumentManifestConstraint *constraint in _constraints) {
        [allOptions addObjectsFromArray:constraint.options.array];
        [allOptions addObjectsFromArray:constraint.auxOptions.array];
    }
    
    return allOptions;
}

@end
