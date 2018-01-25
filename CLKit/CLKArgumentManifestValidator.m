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

- (BOOL)_validateConstraint:(CLKArgumentManifestConstraint *)constraint error:(NSError **)outError;
- (BOOL)_validateStrictRequirement:(CLKArgumentManifestConstraint *)constraint error:(NSError **)outError;
- (BOOL)_validateConditionalRequirement:(CLKArgumentManifestConstraint *)constraint error:(NSError **)outError;
- (BOOL)_validateRepresentativeRequirement:(CLKArgumentManifestConstraint *)constraint error:(NSError **)outError;
- (BOOL)_validateMutualExclusion:(CLKArgumentManifestConstraint *)constraint error:(NSError **)outError;
- (BOOL)_validateOccurrenceRestriction:(CLKArgumentManifestConstraint *)constraint error:(NSError **)outError;

@end

NS_ASSUME_NONNULL_END


@implementation CLKArgumentManifestValidator
{
    CLKArgumentManifest *_manifest;
}

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

- (BOOL)validateConstraints:(NSArray<CLKArgumentManifestConstraint *> *)constraints error:(NSError **)outError
{
    for (CLKArgumentManifestConstraint *constraint in constraints) {
        if (![self _validateConstraint:constraint error:outError]) {
            return NO;
        }
    }
    
    return YES;
}

#warning consider: this method should unpack constraints into semantically meaningful variables and individual validators should take those as parameters
- (BOOL)_validateConstraint:(CLKArgumentManifestConstraint *)constraint error:(NSError **)outError
{
    BOOL result;
    
    switch (constraint.type) {
        case CLKConstraintTypeRequired:
            result = [self _validateStrictRequirement:constraint error:outError];
            break;
        case CLKConstraintTypeConditionallyRequired:
            result = [self _validateConditionalRequirement:constraint error:outError];
            break;
        case CLKConstraintTypeRepresentativeRequired:
            result = [self _validateRepresentativeRequirement:constraint error:outError];
            break;
        case CLKConstraintTypeMutuallyExclusive:
            result = [self _validateMutualExclusion:constraint error:outError];
            break;
        case CLKConstraintTypeOccurrencesRestricted:
            result = [self _validateOccurrenceRestriction:constraint error:outError];
            break;
    }
    
    return result;
}

- (BOOL)_validateStrictRequirement:(CLKArgumentManifestConstraint *)constraint error:(NSError **)outError
{
    if (![_manifest hasOptionNamed:constraint.option]) {
        CLKSetOutError(outError, ([NSError clk_CLKErrorWithCode:CLKErrorRequiredOptionNotProvided description:@"--%@: required option not provided", constraint.option]));
        return NO;
    }
    
    return YES;
}

- (BOOL)_validateConditionalRequirement:(CLKArgumentManifestConstraint *)constraint error:(NSError **)outError
{
    if ([_manifest hasOptionNamed:constraint.associatedOption] && ![_manifest hasOptionNamed:constraint.option]) {
        CLKSetOutError(outError, ([NSError clk_CLKErrorWithCode:CLKErrorRequiredOptionNotProvided description:@"--%@ is required when using --%@", constraint.option, constraint.associatedOption]));
        return NO;
    }
    
    return YES;
}

- (BOOL)_validateRepresentativeRequirement:(CLKArgumentManifestConstraint *)constraint error:(NSError **)outError
{
#warning implement me
    return YES;
}

- (BOOL)_validateMutualExclusion:(CLKArgumentManifestConstraint *)constraint error:(NSError **)outError
{
#warning implement me
    return YES;
}

- (BOOL)_validateOccurrenceRestriction:(CLKArgumentManifestConstraint *)constraint error:(NSError **)outError
{
    if ([_manifest occurrencesOfOptionNamed:constraint.option] > 1) {
        CLKSetOutError(outError, ([NSError clk_CLKErrorWithCode:CLKErrorTooManyOccurrencesOfOption description:@"--%@ may not be provided more than once", constraint.option]));
        return NO;
    }
    
    return YES;
}

@end
