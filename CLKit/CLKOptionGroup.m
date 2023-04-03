//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "CLKOptionGroup_Private.h"

#import "CLKArgumentManifestConstraint.h"
#import "CLKAssert.h"
#import "NSArray+CLKAdditions.h"

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

+ (instancetype)groupRequiringAnyOfOptionsNamed:(NSArray<NSString *> *)options
{
    CLKHardParameterAssert(options.count > 0, @"one or more option names required for required group");
    NSOrderedSet<NSString *> *optionSet = [NSOrderedSet orderedSetWithArray:options];
    CLKArgumentManifestConstraint *constraint = [[CLKArgumentManifestConstraint alloc] initWithType:CLKConstraintTypeAnyRequired
                                                                                      bandedOptions:optionSet
                                                                                  significantOption:nil
                                                                                  predicatingOption:nil];
    
    return [[self alloc] _initWithConstraints:@[ constraint ]];
}

+ (instancetype)groupForOptionNamed:(NSString *)option requiringAnyOfDependents:(NSArray<NSString *> *)dependentOptions
{
    CLKHardParameterAssert(option != nil);
    CLKHardParameterAssert(dependentOptions.count > 0, @"one or more option names required for required dependents group");
    CLKHardParameterAssert(![dependentOptions containsObject:option], @"an option cannot be its own dependent");
    
    NSOrderedSet<NSString *> *optionSet = [NSOrderedSet orderedSetWithArray:dependentOptions];
    CLKArgumentManifestConstraint *constraint = [[CLKArgumentManifestConstraint alloc] initWithType:CLKConstraintTypeAnyRequired
                                                                                      bandedOptions:optionSet
                                                                                  significantOption:nil
                                                                                  predicatingOption:option];
    
    return [[self alloc] _initWithConstraints:@[ constraint ]];
}

+ (instancetype)mutexedGroupForOptionsNamed:(NSArray<NSString *> *)options
{
    CLKHardParameterAssert(options.count > 1, @"two or more option names required for mutexed group");
    NSOrderedSet<NSString *> *optionSet = [NSOrderedSet orderedSetWithArray:options];
    CLKArgumentManifestConstraint *constraint = [[CLKArgumentManifestConstraint alloc] initWithType:CLKConstraintTypeMutuallyExclusive
                                                                                      bandedOptions:optionSet
                                                                                  significantOption:nil
                                                                                  predicatingOption:nil];
    
    return [[self alloc] _initWithConstraints:@[ constraint ]];
}

+ (instancetype)standaloneGroupForOptionNamed:(NSString *)option allowing:(NSArray<NSString *> *)whitelistedOptions
{
    CLKHardParameterAssert(option != nil);
    CLKHardParameterAssert(![whitelistedOptions containsObject:option], @"an option cannot be its whitelist");
    
    NSOrderedSet<NSString *> *optionSet = [NSOrderedSet orderedSetWithArray:whitelistedOptions];
    CLKArgumentManifestConstraint *constraint = [[CLKArgumentManifestConstraint alloc] initWithType:CLKConstraintTypeStandalone
                                                                                      bandedOptions:optionSet
                                                                                  significantOption:option
                                                                                  predicatingOption:nil];
    
    return [[self alloc] _initWithConstraints:@[ constraint ]];
}

+ (instancetype)groupForOptionNamed:(NSString *)option requiringDependency:(NSString *)dependency
{
    CLKHardParameterAssert(option != nil);
    CLKHardParameterAssert(dependency != nil);
    CLKHardParameterAssert(![option isEqualToString:dependency], @"an option cannot be its own dependency");
    
    CLKArgumentManifestConstraint *constraint = [[CLKArgumentManifestConstraint alloc] initWithType:CLKConstraintTypeRequired
                                                                                      bandedOptions:nil
                                                                                  significantOption:dependency
                                                                                  predicatingOption:option];
    
    return [[self alloc] _initWithConstraints:@[ constraint ]];
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
        if (constraint.bandedOptions != nil) {
            [allOptions unionSet:constraint.bandedOptions.set];
        }
        
        if (constraint.significantOption != nil) {
            [allOptions addObject:constraint.significantOption];
        }
        
        if (constraint.predicatingOption != nil) {
            [allOptions addObject:constraint.predicatingOption];
        }
    }
    
    return allOptions;
}

@end
