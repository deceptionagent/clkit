//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "HangVerb.h"


@implementation HangVerb

- (NSString *)name
{
    return @"hang";
}

- (NSArray<CLKOption *> *)options
{
    return @[
        [CLKOption optionWithName:@"acme" flag:@"a"],
        [CLKOption optionWithName:@"station" flag:@"s"]
    ];
}

- (NSArray<CLKOptionGroup *> *)optionGroups
{
    return nil;
}

- (CLKCommandResult *)runWithManifest:(CLKArgumentManifest *)manifest
{
    fprintf(stdout, "=================================================\n");
    fprintf(stdout, "# %s\n", self.name.UTF8String);
    fprintf(stdout, "=================================================\n");
    fprintf(stdout, "%s\n", manifest.debugDescription.UTF8String);
    return [CLKCommandResult resultWithExitStatus:0];
}

@end
