//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import "CLKArgumentManifestValidator.h"

#import "CLKArgumentIssue.h"
#import "CLKArgumentManifest_Private.h"
#import "CLKArgumentManifestConstraint.h"
#import "CLKAssert.h"
#import "CLKError.h"
#import "NSError+CLKAdditions.h"

NS_ASSUME_NONNULL_BEGIN

@interface CLKArgumentManifestValidator ()

- (void)_validateConstraint:(CLKArgumentManifestConstraint *)constraint issueHandler:(NS_NOESCAPE CLKAMVIssueHandler)issueHandler;
- (void)_validateStrictRequirement:(CLKArgumentManifestConstraint *)constraint issueHandler:(NS_NOESCAPE CLKAMVIssueHandler)issueHandler;
- (void)_validateConditionalRequirement:(CLKArgumentManifestConstraint *)constraint issueHandler:(NS_NOESCAPE CLKAMVIssueHandler)issueHandler;
- (void)_validateRepresentationRequirement:(CLKArgumentManifestConstraint *)constraint issueHandler:(NS_NOESCAPE CLKAMVIssueHandler)issueHandler;
- (void)_validateMutualExclusion:(CLKArgumentManifestConstraint *)constraint issueHandler:(NS_NOESCAPE CLKAMVIssueHandler)issueHandler;
- (void)_validateStandaloneExclusion:(CLKArgumentManifestConstraint *)constraint issueHandler:(NS_NOESCAPE CLKAMVIssueHandler)issueHandler;
- (void)_validateOccurrenceLimit:(CLKArgumentManifestConstraint *)constraint issueHandler:(NS_NOESCAPE CLKAMVIssueHandler)issueHandler;

@end

NS_ASSUME_NONNULL_END

@implementation CLKArgumentManifestValidator
{
    CLKArgumentManifest *_manifest;
}

@synthesize manifest = _manifest;

- (instancetype)initWithManifest:(CLKArgumentManifest *)manifest
{
    CLKParameterAssert(manifest != nil);
    
    self = [super init];
    if (self != nil) {
        _manifest = manifest;
    }
    
    return self;
}

#pragma mark -

- (void)validateConstraints:(NSArray<CLKArgumentManifestConstraint *> *)constraints issueHandler:(NS_NOESCAPE CLKAMVIssueHandler)issueHandler
{
    // eliminate redundant errors by deduplicating identical constraints.
    // use an ordered set to keep error emission deterministic and testing sane.
    NSOrderedSet<CLKArgumentManifestConstraint *> *uniqueConstraints = [[NSOrderedSet alloc] initWithArray:constraints];
    for (CLKArgumentManifestConstraint *constraint in uniqueConstraints) {
        @autoreleasepool {
            [self _validateConstraint:constraint issueHandler:issueHandler];
        }
    }
}

- (void)_validateConstraint:(CLKArgumentManifestConstraint *)constraint issueHandler:(NS_NOESCAPE CLKAMVIssueHandler)issueHandler
{
    switch (constraint.type) {
        case CLKConstraintTypeRequired:
            [self _validateStrictRequirement:constraint issueHandler:issueHandler];
            break;
        
        case CLKConstraintTypeConditionallyRequired:
            [self _validateConditionalRequirement:constraint issueHandler:issueHandler];
            break;
        
        case CLKConstraintTypeRepresentationRequired:
            [self _validateRepresentationRequirement:constraint issueHandler:issueHandler];
            break;
        
        case CLKConstraintTypeMutuallyExclusive:
            [self _validateMutualExclusion:constraint issueHandler:issueHandler];
            break;
        
        case CLKConstraintTypeStandalone:
            [self _validateStandaloneExclusion:constraint issueHandler:issueHandler];
            break;
        
        case CLKConstraintTypeOccurrencesLimited:
            [self _validateOccurrenceLimit:constraint issueHandler:issueHandler];
            break;
    }
}

- (void)_validateStrictRequirement:(CLKArgumentManifestConstraint *)constraint issueHandler:(NS_NOESCAPE CLKAMVIssueHandler)issueHandler
{
    NSParameterAssert(constraint.type == CLKConstraintTypeRequired);
    NSParameterAssert(constraint.options.count == 1);
    
    NSString *option = constraint.options.firstObject;
    if (![_manifest hasOptionNamed:option]) {
        NSError *error = [NSError clk_CLKErrorWithCode:CLKErrorRequiredOptionNotProvided description:@"--%@: required option not provided", option];
        CLKArgumentIssue *issue = [CLKArgumentIssue issueWithError:error salientOption:option];
        issueHandler(issue);
    }
}

- (void)_validateConditionalRequirement:(CLKArgumentManifestConstraint *)constraint issueHandler:(NS_NOESCAPE CLKAMVIssueHandler)issueHandler
{
    NSParameterAssert(constraint.type == CLKConstraintTypeConditionallyRequired);
    NSParameterAssert(constraint.options.count == 1);
    NSParameterAssert(constraint.auxOptions.count == 1);
    
    NSString *option = constraint.options.firstObject;
    NSString *causalOption = constraint.auxOptions.firstObject;
    if ([_manifest hasOptionNamed:causalOption] && ![_manifest hasOptionNamed:option]) {
        NSError *error = [NSError clk_CLKErrorWithCode:CLKErrorRequiredOptionNotProvided description:@"--%@ is required when using --%@", option, causalOption];
        CLKArgumentIssue *issue = [CLKArgumentIssue issueWithError:error salientOption:option];
        issueHandler(issue);
    }
}

- (void)_validateRepresentationRequirement:(CLKArgumentManifestConstraint *)constraint issueHandler:(NS_NOESCAPE CLKAMVIssueHandler)issueHandler
{
    NSParameterAssert(constraint.type == CLKConstraintTypeRepresentationRequired);
    
    for (NSString *option in constraint.options) {
        if ([_manifest hasOptionNamed:option]) {
            return;
        }
    }
    
    NSString *desc = [constraint.options.array componentsJoinedByString:@" --"];
    NSError *error = [NSError clk_CLKErrorWithCode:CLKErrorRequiredOptionNotProvided description:@"one or more of the following options must be provided: --%@", desc];
    CLKArgumentIssue *issue = [CLKArgumentIssue issueWithError:error salientOptions:constraint.options.array];
    issueHandler(issue);
}

- (void)_validateMutualExclusion:(CLKArgumentManifestConstraint *)constraint issueHandler:(NS_NOESCAPE CLKAMVIssueHandler)issueHandler
{
    NSParameterAssert(constraint.type == CLKConstraintTypeMutuallyExclusive);
    
    NSMutableArray<NSString *> *hits = nil;
    
    for (NSString *option in constraint.options) {
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
        CLKArgumentIssue *issue = [CLKArgumentIssue issueWithError:error salientOptions:hits];
        issueHandler(issue);
    }
}

- (void)_validateStandaloneExclusion:(CLKArgumentManifestConstraint *)constraint issueHandler:(NS_NOESCAPE CLKAMVIssueHandler)issueHandler
{
    NSParameterAssert(constraint.type == CLKConstraintTypeStandalone);
    NSParameterAssert(constraint.options.count == 1);
    
    NSString *option = constraint.options.firstObject;
    if ([_manifest hasOptionNamed:option]) {
        CLKArgumentIssue *issue = nil;
        NSSet<NSString *> *accumulatedOptions = _manifest.accumulatedOptionNames;
        if (accumulatedOptions.count > 1) {
            NSOrderedSet<NSString *> *whitelist = constraint.auxOptions;
            if (whitelist.count == 0) {
                NSError *error = [NSError clk_CLKErrorWithCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--%@ may not be provided with other options", option];
                issue = [CLKArgumentIssue issueWithError:error salientOption:option];
            } else {
                NSMutableSet<NSString *> *conflictedOptions = [accumulatedOptions mutableCopy];
                [conflictedOptions minusSet:whitelist.set];
                [conflictedOptions removeObject:option];
                if (conflictedOptions.count > 0) {
                    NSString *whitelistDesc = [whitelist.array componentsJoinedByString:@" --"];
                    NSError *error = [NSError clk_CLKErrorWithCode:CLKErrorMutuallyExclusiveOptionsPresent description:@"--%@ may not be provided with options other than the following: --%@", option, whitelistDesc];
                    issue = [CLKArgumentIssue issueWithError:error salientOption:option];
                }
            }
        }
        
        if (issue != nil) {
            issueHandler(issue);
        }
    }
}

- (void)_validateOccurrenceLimit:(CLKArgumentManifestConstraint *)constraint issueHandler:(NS_NOESCAPE CLKAMVIssueHandler)issueHandler
{
    NSParameterAssert(constraint.type == CLKConstraintTypeOccurrencesLimited);
    NSParameterAssert(constraint.options.count == 1);
    
    NSString *option = constraint.options.firstObject;
    if ([_manifest occurrencesOfOptionNamed:option] > 1) {
        NSError *error = [NSError clk_CLKErrorWithCode:CLKErrorTooManyOccurrencesOfOption description:@"--%@ may not be provided more than once", option];
        CLKArgumentIssue *issue = [CLKArgumentIssue issueWithError:error salientOption:option];
        issueHandler(issue);
    }
}

@end
