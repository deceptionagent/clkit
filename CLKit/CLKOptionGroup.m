//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "CLKOptionGroup.h"

#import "CLKArgumentManifestConstraint.h"
#import "CLKOption.h"
#import "NSMutableArray+CLKAdditions.h"


NS_ASSUME_NONNULL_BEGIN

@interface CLKOptionGroup ()

- (instancetype)_initWithOptions:(nullable NSArray<CLKOption *> *)options
                       subgroups:(nullable NSArray<CLKOptionGroup *> *)subgroups
                         mutexed:(BOOL)mutexed
                        required:(BOOL)required NS_DESIGNATED_INITIALIZER;

- (CLKArgumentManifestConstraint *)_requiredConstraint;
- (NSArray<CLKArgumentManifestConstraint *> *)_mutexConstraints;

@end

NS_ASSUME_NONNULL_END


@implementation CLKOptionGroup
{
    NSArray<CLKOption *> *_options;
    NSArray<CLKOptionGroup *> *_subgroups;
    BOOL _mutexed;
    BOOL _required;
}

@synthesize options = _options;
@synthesize subgroups = _subgroups;
@synthesize mutexed = _mutexed;
@synthesize required = _required;

+ (instancetype)groupWithOptions:(NSArray<CLKOption *> *)options required:(BOOL)required
{
    return [[[self alloc] _initWithOptions:options subgroups:nil mutexed:NO required:required] autorelease];
}

+ (instancetype)mutexedGroupWithOptions:(NSArray<CLKOption *> *)options required:(BOOL)required
{
    return [[[self alloc] _initWithOptions:options subgroups:nil mutexed:YES required:required] autorelease];
}

+ (instancetype)mutexedGroupWithOptions:(NSArray<CLKOption *> *)options subgroups:(NSArray<CLKOptionGroup *> *)subgroups required:(BOOL)required
{
    return [[[self alloc] _initWithOptions:options subgroups:subgroups mutexed:YES required:required] autorelease];
}

- (instancetype)_initWithOptions:(NSArray<CLKOption *> *)options subgroups:(NSArray<CLKOptionGroup *> *)subgroups mutexed:(BOOL)mutexed required:(BOOL)required
{
    self = [super init];
    if (self != nil) {
        _options = [options copy];
        _subgroups = [subgroups copy];
        _mutexed = mutexed;
        _required = required;
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
    
    return constraints;
}

- (CLKArgumentManifestConstraint *)_requiredConstraint
{
    NSAssert(_required, @"constructing required constraint for non-required group");
    
    NSMutableArray<NSString *> *allOptions = [NSMutableArray arrayWithArray:[self _allOptionNames]];
    [allOptions addObjectsFromArray:[self _allSubgroupOptionNames]];
    return [CLKArgumentManifestConstraint constraintRequiringRepresentativeForOptions:allOptions];
}

- (NSArray<CLKArgumentManifestConstraint *> *)_mutexConstraints
{
    NSAssert(_mutexed, @"constructing mutex constraints for non-mutexed group");
    
    NSMutableArray<CLKArgumentManifestConstraint *> *constraints = [NSMutableArray array];
    
    /* primary options are mutually exclusive with each other */
    
    NSArray<NSString *> *options = [self _allOptionNames];
    if (options.count > 0) {
        CLKArgumentManifestConstraint *constraint = [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:options];
        [constraints addObject:constraint];
    }
    
    /* each primary option is mutually exclusive with every subgroup */
    
    if (options.count > 0) {
        NSArray<NSString *> *allSubgroupOptions = [self _allSubgroupOptionNames];
        if (allSubgroupOptions.count > 0) {
            for (NSString *option in options) {
                for (NSString *subgroupOption in allSubgroupOptions) {
                    CLKArgumentManifestConstraint *constraint = [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ option, subgroupOption ]];
                    [constraints addObject:constraint];
                }
            }
        }
    }
    
    /* subgroups are mutually exclusive with each other */
    
    if (_subgroups.count > 1) {
        NSMutableArray<CLKOptionGroup *> *remainingSubgroups = [[_subgroups mutableCopy] autorelease];
        CLKOptionGroup *currentSubgroup;
        while ((currentSubgroup = [remainingSubgroups clk_popFirstObject]) != nil) {
            for (CLKOption *currentSubgroupOption in currentSubgroup.options) {
                for (CLKOptionGroup *group in remainingSubgroups) {
                    for (CLKOption *option in group.options) {
                        CLKArgumentManifestConstraint *constraint = [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ currentSubgroupOption.name, option.name ]];
                        [constraints addObject:constraint];
                    }
                }
            }
        }
    }
    
    return constraints;
}

- (NSArray<NSString *> *)_allOptionNames
{
    NSMutableArray<NSString *> *optionNames = [NSMutableArray array];
    
    for (CLKOption *option in _options) {
        [optionNames addObject:option.name];
    }
    
    return optionNames;
}

- (NSArray<NSString *> *)_allSubgroupOptionNames
{
    NSMutableArray<NSString *> *allSubgroupOptionNames = [NSMutableArray array];
    
    for (CLKOptionGroup *subgroup in _subgroups) {
        [allSubgroupOptionNames addObjectsFromArray:[subgroup _allOptionNames]];
    }
    
    return allSubgroupOptionNames;
}

@end
