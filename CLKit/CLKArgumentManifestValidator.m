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
    
    if (option.required && ![_manifest hasOption:option]) {
        if (outError != nil) {
            *outError = [NSError clk_CLKErrorWithCode:CLKErrorRequiredOptionNotProvided description:@"--%@: required option not provided", option.name];
        }
        
        return NO;
    }
    
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

@end
