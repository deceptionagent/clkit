//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import "CLKArgumentManifestValidator.h"

#import "CLKArgumentManifest.h"
#import "CLKArgumentManifest_Private.h"
#import "CLKArgumentManifestConstraint.h"
#import "CLKAssert.h"
#import "CLKError.h"
#import "CLKError_Private.h"
#import "NSError+CLKAdditions.h"


NS_ASSUME_NONNULL_BEGIN

@interface CLKArgumentManifestValidator ()

- (void)_validateConstraint:(CLKArgumentManifestConstraint *)constraint issueHandler:(CLKAMVIssueHandler)issueHandler;
- (void)_validateStrictRequirement:(CLKArgumentManifestConstraint *)constraint issueHandler:(CLKAMVIssueHandler)issueHandler;
- (void)_validateConditionalRequirement:(CLKArgumentManifestConstraint *)constraint issueHandler:(CLKAMVIssueHandler)issueHandler;
- (void)_validateRepresentativeRequirement:(CLKArgumentManifestConstraint *)constraint issueHandler:(CLKAMVIssueHandler)issueHandler;
- (void)_validateMutualExclusion:(CLKArgumentManifestConstraint *)constraint issueHandler:(CLKAMVIssueHandler)issueHandler;
- (void)_validateOccurrenceRestriction:(CLKArgumentManifestConstraint *)constraint issueHandler:(CLKAMVIssueHandler)issueHandler;

@end

NS_ASSUME_NONNULL_END


@implementation CLKArgumentManifestValidator
{
    CLKArgumentManifest *_manifest;
}

@synthesize manifest = _manifest;

- (instancetype)initWithManifest:(CLKArgumentManifest *)manifest
{
    CLKHardParameterAssert(manifest != nil);
    
    self = [super init];
    if (self != nil) {
        [_manifest = manifest retain];
    }
    
    return self;
}

- (void)dealloc
{
    [_manifest release];
    [super dealloc];
}

#pragma mark -

- (void)validateConstraints:(NSArray<CLKArgumentManifestConstraint *> *)constraints issueHandler:(CLKAMVIssueHandler)issueHandler
{
    // eliminate redundant errors by deduplicating identical constraints
    NSOrderedSet<CLKArgumentManifestConstraint *> *uniqueConstraints = [[NSOrderedSet alloc] initWithArray:constraints];
    
    for (CLKArgumentManifestConstraint *constraint in uniqueConstraints) {
        [self _validateConstraint:constraint issueHandler:issueHandler];
    }
    
    [uniqueConstraints release];
}

- (void)_validateConstraint:(CLKArgumentManifestConstraint *)constraint issueHandler:(CLKAMVIssueHandler)issueHandler
{
    switch (constraint.type) {
        case CLKConstraintTypeRequired:
            [self _validateStrictRequirement:constraint issueHandler:issueHandler];
            break;
        case CLKConstraintTypeConditionallyRequired:
            [self _validateConditionalRequirement:constraint issueHandler:issueHandler];
            break;
        case CLKConstraintTypeRepresentativeRequired:
            [self _validateRepresentativeRequirement:constraint issueHandler:issueHandler];
            break;
        case CLKConstraintTypeMutuallyExclusive:
            [self _validateMutualExclusion:constraint issueHandler:issueHandler];
            break;
        case CLKConstraintTypeOccurrencesRestricted:
            [self _validateOccurrenceRestriction:constraint issueHandler:issueHandler];
            break;
    }
}

- (void)_validateStrictRequirement:(CLKArgumentManifestConstraint *)constraint issueHandler:(CLKAMVIssueHandler)issueHandler
{
    if (![_manifest hasOptionNamed:constraint.option]) {
        NSError *error = [NSError clk_CLKErrorWithCode:CLKErrorRequiredOptionNotProvided description:@"--%@: required option not provided", constraint.option];
        issueHandler(error);
    }
}

- (void)_validateConditionalRequirement:(CLKArgumentManifestConstraint *)constraint issueHandler:(CLKAMVIssueHandler)issueHandler
{
    if ([_manifest hasOptionNamed:constraint.associatedOption] && ![_manifest hasOptionNamed:constraint.option]) {
        NSError *error = [NSError clk_CLKErrorWithCode:CLKErrorRequiredOptionNotProvided description:@"--%@ is required when using --%@", constraint.option, constraint.associatedOption];
        issueHandler(error);
    }
}

- (void)_validateRepresentativeRequirement:(CLKArgumentManifestConstraint *)constraint issueHandler:(CLKAMVIssueHandler)issueHandler
{
    for (NSString *option in constraint.linkedOptions) {
        if ([_manifest hasOptionNamed:option]) {
            return;
        }
    }
    
    NSString *desc = [constraint.linkedOptions componentsJoinedByString:@" --"];
    NSError *error = [NSError clk_CLKErrorWithCode:CLKErrorRequiredOptionNotProvided description:@"one or more of the following options must be provided: --%@", desc];
    issueHandler(error);
}

- (void)_validateMutualExclusion:(CLKArgumentManifestConstraint *)constraint issueHandler:(CLKAMVIssueHandler)issueHandler
{
    NSMutableArray *hits = nil;
    
    for (NSString *option in constraint.linkedOptions) {
        if ([_manifest hasOptionNamed:option]) {
            // we can skip array allocation if no linked options are present
            // [TACK] still not great -- we could create and destroy a lot of arrays that contain only one option
            if (hits == nil) {
                hits = [NSMutableArray array];
            }
            
            [hits addObject:option];
        }
    }
    
    if (hits != nil && hits.count > 1) {
        NSString *desc = [hits componentsJoinedByString:@" --"];
        NSError *error = [NSError clk_CLKErrorWithCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--%@: mutually exclusive options encountered", desc];
        issueHandler(error);
    }
}

- (void)_validateOccurrenceRestriction:(CLKArgumentManifestConstraint *)constraint issueHandler:(CLKAMVIssueHandler)issueHandler
{
    if ([_manifest occurrencesOfOptionNamed:constraint.option] > 1) {
        NSError *error = [NSError clk_CLKErrorWithCode:CLKErrorTooManyOccurrencesOfOption description:@"--%@ may not be provided more than once", constraint.option];
        issueHandler(error);
    }
}

@end
