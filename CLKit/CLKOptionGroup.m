//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "CLKOptionGroup.h"

#import "CLKArgumentManifestConstraint.h"
#import "NSMutableArray+CLKAdditions.h"


NS_ASSUME_NONNULL_BEGIN

@interface CLKOptionGroup ()

- (instancetype)_initWithOptionsNamed:(nullable NSArray<NSString *> *)options
                            subgroups:(nullable NSArray<CLKOptionGroup *> *)subgroups
                              mutexed:(BOOL)mutexed
                             required:(BOOL)required NS_DESIGNATED_INITIALIZER;

- (CLKArgumentManifestConstraint *)_requiredConstraint;
- (NSArray<CLKArgumentManifestConstraint *> *)_mutexConstraints;
- (nullable NSArray<NSString *> *)_allSubgroupOptions;

@end

NS_ASSUME_NONNULL_END


@implementation CLKOptionGroup
{
    NSArray<NSString *> *_options;
    NSArray<CLKOptionGroup *> *_subgroups;
    BOOL _mutexed;
    BOOL _required;
}

@synthesize options = _options;
@synthesize subgroups = _subgroups;
@synthesize mutexed = _mutexed;
@synthesize required = _required;

+ (instancetype)groupForOptionsNamed:(NSArray<NSString *> *)options required:(BOOL)required
{
    return [[[self alloc] _initWithOptionsNamed:options subgroups:nil mutexed:NO required:required] autorelease];
}

+ (instancetype)mutexedGroupForOptionsNamed:(NSArray<NSString *> *)options required:(BOOL)required
{
    return [[[self alloc] _initWithOptionsNamed:options subgroups:nil mutexed:YES required:required] autorelease];
}

+ (instancetype)mutexedGroupForOptionsNamed:(NSArray<NSString *> *)options subgroups:(NSArray<CLKOptionGroup *> *)subgroups required:(BOOL)required
{
    return [[[self alloc] _initWithOptionsNamed:options subgroups:subgroups mutexed:YES required:required] autorelease];
}

- (instancetype)_initWithOptionsNamed:(NSArray<NSString *> *)options subgroups:(NSArray<CLKOptionGroup *> *)subgroups mutexed:(BOOL)mutexed required:(BOOL)required
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
        [allSubgroupOptions addObjectsFromArray:subgroup.options];
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
    
    NSMutableArray<CLKArgumentManifestConstraint *> *constraints = [NSMutableArray array];
    
    /* primary options are mutually exclusive with each other */
    
    if (_options.count > 0) {
        CLKArgumentManifestConstraint *constraint = [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:_options];
        [constraints addObject:constraint];
    }
    
    /* each primary option is mutually exclusive with every subgroup */
    
    if (_options.count > 0) {
        NSArray *allSubgroupOptions = [self _allSubgroupOptions];
        if (allSubgroupOptions.count > 0) {
            for (NSString *option in _options) {
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
            for (NSString *currentSubgroupOption in currentSubgroup.options) {
                for (CLKOptionGroup *group in remainingSubgroups) {
                    for (NSString *option in group.options) {
                        CLKArgumentManifestConstraint *constraint = [CLKArgumentManifestConstraint constraintForMutuallyExclusiveOptions:@[ currentSubgroupOption, option ]];
                        [constraints addObject:constraint];
                    }
                }
            }
        }
    }
    
    return constraints;
}

@end
