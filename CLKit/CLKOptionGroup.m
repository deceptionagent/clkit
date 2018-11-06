//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "CLKOptionGroup_Private.h"

#import "CLKArgumentManifestConstraint.h"
#import "NSMutableArray+CLKAdditions.h"


NS_ASSUME_NONNULL_BEGIN

@interface CLKOptionGroup ()

- (instancetype)_initWithOptionsNamed:(nullable NSArray<NSString *> *)options
                            subgroups:(nullable NSArray<CLKOptionGroup *> *)subgroups
                             required:(BOOL)required
                              mutexed:(BOOL)mutexed NS_DESIGNATED_INITIALIZER;

@property (nullable, readonly) NSArray<NSString *> *options;

- (nullable NSArray<NSString *> *)_allSubgroupOptions;

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
}

@synthesize options = _options;

+ (instancetype)groupForOptionsNamed:(NSArray<NSString *> *)options
{
    return [[[self alloc] _initWithOptionsNamed:options subgroups:nil required:NO mutexed:NO] autorelease];
}

+ (instancetype)requiredGroupForOptionsNamed:(NSArray<NSString *> *)options
{
    return [[[self alloc] _initWithOptionsNamed:options subgroups:nil required:YES mutexed:NO] autorelease];
}

+ (instancetype)mutexedGroupForOptionsNamed:(NSArray<NSString *> *)options
{
    return [[[self alloc] _initWithOptionsNamed:options subgroups:nil required:NO mutexed:YES] autorelease];
}

+ (instancetype)groupForOptionsNamed:(NSArray<NSString *> *)options required:(BOOL)required mutexed:(BOOL)mutexed
{
    return [[[self alloc] _initWithOptionsNamed:options subgroups:nil required:required mutexed:mutexed] autorelease];
}

+ (instancetype)mutexedGroupWithSubgroups:(NSArray<CLKOptionGroup *> *)subgroups
{
    return [[[self alloc] _initWithOptionsNamed:nil subgroups:subgroups required:NO mutexed:YES] autorelease];
}

+ (instancetype)standaloneGroupForOptionNamed:(NSString *)option allowing:(NSArray<NSString *> *)whitelistedOptionNames
{
    [NSException raise:@"CLKNotImplementedError" format:@"not implemented"];
    return nil;
}

- (instancetype)_initWithOptionsNamed:(NSArray<NSString *> *)options subgroups:(NSArray<CLKOptionGroup *> *)subgroups required:(BOOL)required mutexed:(BOOL)mutexed
{
    NSParameterAssert(!(options != nil && subgroups != nil));
    NSParameterAssert(!(options == nil && subgroups == nil));
    
    self = [super init];
    if (self != nil) {
        _options = [options copy];
        _subgroups = [subgroups copy];
        _required = required;
        _mutexed = mutexed;
    }
    
    return self;
}

- (void)dealloc
{
    [_subgroups release];
    [_options release];
    [super dealloc];
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

- (CLKArgumentManifestConstraint *)_requiredConstraint
{
    NSAssert(_required, @"constructing required constraint for non-required group");
    return [CLKArgumentManifestConstraint constraintRequiringRepresentativeForOptions:self.allOptions];
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
    
    NSMutableArray<CLKOptionGroup *> *remainingSubgroups = [[_subgroups mutableCopy] autorelease];
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
