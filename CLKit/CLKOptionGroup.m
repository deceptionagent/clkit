//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "CLKOptionGroup_Private.h"

#import "CLKArgumentManifestConstraint.h"
#import "CLKAssert.h"
#import "NSMutableArray+CLKAdditions.h"


NS_ASSUME_NONNULL_BEGIN

@interface CLKOptionGroup ()

- (instancetype)_initWithOptionsNamed:(nullable NSArray<NSString *> *)options
                            subgroups:(nullable NSArray<CLKOptionGroup *> *)subgroups
                             required:(BOOL)required
                              mutexed:(BOOL)mutexed;

- (instancetype)_initWithOptionsNamed:(nullable NSArray<NSString *> *)options
                            subgroups:(nullable NSArray<CLKOptionGroup *> *)subgroups
                             required:(BOOL)required
                              mutexed:(BOOL)mutexed
                           standalone:(BOOL)standalone NS_DESIGNATED_INITIALIZER;

@property (nullable, readonly) NSArray<NSString *> *options;

- (nullable NSArray<NSString *> *)_allSubgroupOptions;

- (CLKArgumentManifestConstraint *)_standaloneConstraint;
- (CLKArgumentManifestConstraint *)_requiredConstraint;
- (NSArray<CLKArgumentManifestConstraint *> *)_mutexConstraints;
- (NSArray<CLKArgumentManifestConstraint *> *)_mutexConstraintsForSubgroups;
- (NSArray<CLKArgumentManifestConstraint *> *)_subgroupConstraints;

@end

NS_ASSUME_NONNULL_END

@implementation CLKOptionGroup
{
    NSArray<NSString *> *_options;
    NSArray<CLKOptionGroup *> *_subgroups;
    BOOL _mutexed;
    BOOL _required; // at least one member of this group is required
    
    /*
        for standalone groups, the standalone option is stored as the sole option in _options,
        and the whitelist is stored as the sole group in _subgroups.
    */
    BOOL _standalone;
}

@synthesize options = _options;

+ (instancetype)groupForOptionsNamed:(NSArray<NSString *> *)options
{
    return [[self alloc] _initWithOptionsNamed:options subgroups:nil required:NO mutexed:NO];
}

+ (instancetype)requiredGroupForOptionsNamed:(NSArray<NSString *> *)options
{
    return [[self alloc] _initWithOptionsNamed:options subgroups:nil required:YES mutexed:NO];
}

+ (instancetype)mutexedGroupForOptionsNamed:(NSArray<NSString *> *)options
{
    return [[self alloc] _initWithOptionsNamed:options subgroups:nil required:NO mutexed:YES];
}

+ (instancetype)groupForOptionsNamed:(NSArray<NSString *> *)options required:(BOOL)required mutexed:(BOOL)mutexed
{
    return [[self alloc] _initWithOptionsNamed:options subgroups:nil required:required mutexed:mutexed];
}

+ (instancetype)mutexedGroupWithSubgroups:(NSArray<CLKOptionGroup *> *)subgroups
{
    return [[self alloc] _initWithOptionsNamed:nil subgroups:subgroups required:NO mutexed:YES];
}

+ (instancetype)standaloneGroupForOptionNamed:(NSString *)option allowing:(NSArray<NSString *> *)whitelistedOptionNames
{
    CLKOptionGroup *whitelist = [CLKOptionGroup groupForOptionsNamed:whitelistedOptionNames];
    return [[self alloc] _initWithOptionsNamed:@[ option ] subgroups:@[ whitelist ] required:NO mutexed:NO standalone:YES];
}

- (instancetype)_initWithOptionsNamed:(NSArray<NSString *> *)options
                            subgroups:(NSArray<CLKOptionGroup *> *)subgroups
                             required:(BOOL)required
                              mutexed:(BOOL)mutexed
{
    return [self _initWithOptionsNamed:options subgroups:subgroups required:required mutexed:mutexed standalone:NO];
}

- (instancetype)_initWithOptionsNamed:(NSArray<NSString *> *)options
                            subgroups:(NSArray<CLKOptionGroup *> *)subgroups
                             required:(BOOL)required
                              mutexed:(BOOL)mutexed
                           standalone:(BOOL)standalone
{
    NSParameterAssert(!(options == nil && subgroups == nil));
    CLKParameterAssert(!(standalone && (required || mutexed)), @"standalone groups cannot be required or mutexed");
    
    self = [super init];
    if (self != nil) {
        _options = [options copy];
        _subgroups = [subgroups copy];
        _required = required;
        _mutexed = mutexed;
        _standalone = standalone;
    }
    
    return self;
}

#pragma mark -

- (NSArray<NSString *> *)allOptions
{
    NSMutableArray *allOptions = [NSMutableArray arrayWithArray:_options];
    [allOptions addObjectsFromArray:[self _allSubgroupOptions]];
    return allOptions;
}

- (NSArray<NSString *> *)_allSubgroupOptions
{
    if (_subgroups == nil) {
        return nil;
    }
    
    NSMutableArray<NSString *> *allSubgroupOptions = [NSMutableArray array];
    
    for (CLKOptionGroup *subgroup in _subgroups) {
        [allSubgroupOptions addObjectsFromArray:subgroup.allOptions];
    }
    
    return allSubgroupOptions;
}

#pragma mark -
#pragma mark Constraints

- (NSArray<CLKArgumentManifestConstraint *> *)constraints
{
    if (_standalone) {
        return @[ [self _standaloneConstraint] ];
    }
    
    NSMutableArray<CLKArgumentManifestConstraint *> *constraints = [NSMutableArray array];
    
    if (_required) {
        [constraints addObject:[self _requiredConstraint]];
    }
    
    if (_mutexed) {
        [constraints addObjectsFromArray:[self _mutexConstraints]];
    }
    
    if (_subgroups != nil) {
        [constraints addObjectsFromArray:[self _subgroupConstraints]];
    }
    
    return constraints;
}

- (CLKArgumentManifestConstraint *)_standaloneConstraint
{
    NSAssert(_standalone, @"constructing standalone constraint for non-standalone group");
    NSAssert(_options.count == 1, @"standalone groups should have exactly one primary option");
    NSAssert(_subgroups.count < 2, @"standalone groups should have no more than one whitelist group");
    return [CLKArgumentManifestConstraint constraintForStandaloneOption:_options.firstObject allowingOptions:_subgroups.firstObject.options];
}

- (CLKArgumentManifestConstraint *)_requiredConstraint
{
    NSAssert(_required, @"constructing required constraint for non-required group");
    return [CLKArgumentManifestConstraint constraintRequiringRepresentationForOptions:self.allOptions];
}

- (NSArray<CLKArgumentManifestConstraint *> *)_mutexConstraints
{
    NSAssert(_mutexed, @"constructing mutex constraints for non-mutexed group");
    NSAssert(!(_options != nil && _subgroups != nil), @"cannot have both primary options and subgroups");
    NSAssert(!(_options == nil && _subgroups == nil), @"must have either primary options or subgroups");
    
    // primary options are mutually exclusive with each other
    if (_options != nil) {
        if (_options.count > 1) {
            CLKArgumentManifestConstraint *constraint = [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:_options];
            return @[ constraint ];
        } else {
            return @[];
        }
    }
    
    // if we didn't have primary options, we have subgroups to mutex against each other
    return [self _mutexConstraintsForSubgroups];
}

- (NSArray<CLKArgumentManifestConstraint *> *)_mutexConstraintsForSubgroups
{
    // subgroups are only mutexed against each other, so return early if for some reason we don't have at least two subgroups
    if (_subgroups.count < 2) {
        return @[];
    }
    
    NSMutableArray<CLKArgumentManifestConstraint *> *constraints = [NSMutableArray array];
    
    NSMutableArray<CLKOptionGroup *> *remainingSubgroups = [_subgroups mutableCopy];
    CLKOptionGroup *currentSubgroup;
    while ((currentSubgroup = [remainingSubgroups clk_popFirstObject]) != nil) {
        for (NSString *currentSubgroupOption in currentSubgroup.options) {
            for (CLKOptionGroup *group in remainingSubgroups) {
                for (NSString *option in group.options) {
                    CLKArgumentManifestConstraint *constraint = [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ currentSubgroupOption, option ]];
                    [constraints addObject:constraint];
                }
            }
        }
    }
    
    return constraints;
}

- (NSArray<CLKArgumentManifestConstraint *> *)_subgroupConstraints
{
    NSMutableArray<CLKArgumentManifestConstraint *> *subgroupConstraints = [NSMutableArray array];

    for (CLKOptionGroup *subgroup in _subgroups) {
        [subgroupConstraints addObjectsFromArray:subgroup.constraints];
    }

    return subgroupConstraints;
}

@end
