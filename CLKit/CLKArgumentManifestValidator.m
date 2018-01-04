//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import "CLKArgumentManifestValidator.h"

#import "CLKArgumentManifest.h"
#import "CLKArgumentManifest_Private.h"
#import "CLKAssert.h"
#import "CLKError.h"
#import "CLKOption.h"
#import "NSError+CLKAdditions.h"


NS_ASSUME_NONNULL_BEGIN

@interface CLKArgumentManifestValidator ()

- (BOOL)_validateStrictRequirementForOption:(CLKOption *)option error:(NSError **)outError;
- (BOOL)_validateDependenciesForOption:(CLKOption *)option error:(NSError **)outError;
- (BOOL)_validateRecurrencyForOption:(CLKOption *)option error:(NSError **)outError;

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

- (BOOL)validateOption:(CLKOption *)option error:(NSError **)outError
{
    NSParameterAssert(option != nil);
    
    if (![self _validateStrictRequirementForOption:option error:outError]) {
        return NO;
    }
    
    if (![self _validateDependenciesForOption:option error:outError]) {
        return NO;
    }
    
    if (![self _validateRecurrencyForOption:option error:outError]) {
        return NO;
    }
    
    return YES;
}

- (BOOL)_validateStrictRequirementForOption:(CLKOption *)option error:(NSError **)outError
{
    if (option.required && ![_manifest hasOption:option]) {
        if (outError != nil) {
            *outError = [NSError clk_CLKErrorWithCode:CLKErrorRequiredOptionNotProvided description:@"--%@: required option not provided", option.name];
        }
        
        return NO;
    }
    
    return YES;
}

- (BOOL)_validateDependenciesForOption:(CLKOption *)option error:(NSError **)outError
{
    if ([_manifest hasOption:option]) {
        for (CLKOption *dependency in option.dependencies) {
            if (![_manifest hasOption:dependency]) {
                if (outError != nil) {
                    *outError = [NSError clk_CLKErrorWithCode:CLKErrorRequiredOptionNotProvided description:@"--%@ is required when using --%@", dependency.name, option.name];
                }
                
                return NO;
            }
        }
    }
    
    return YES;
}

- (BOOL)_validateRecurrencyForOption:(CLKOption *)option error:(NSError **)outError
{
    if (!option.recurrent && [_manifest occurrencesOfOption:option] > 1) {
        if (outError != nil) {
            *outError = [NSError clk_CLKErrorWithCode:CLKErrorTooManyOccurrencesOfOption description:@"--%@ may not be provided more than once", option.name];
        }
        
        return NO;
    }
    
    return YES;
}

@end
