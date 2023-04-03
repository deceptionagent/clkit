//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "DeliveryVerb.h"

@implementation DeliveryVerb

- (NSString *)name
{
    return @"delivery";
}

- (NSArray<CLKOption *> *)options
{
    return @[
        [CLKOption optionWithName:@"ex" flag:@"e"],
        [CLKOption optionWithName:@"cathedra" flag:@"c"]
    ];
}

- (NSArray<CLKOptionGroup *> *)optionGroups
{
    return @[
        [CLKOptionGroup groupRequiringAnyOfOptionsNamed:@[ @"ex", @"cathedra" ]],
        [CLKOptionGroup mutexedGroupForOptionsNamed:@[ @"ex", @"cathedra" ]],
    ];
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
