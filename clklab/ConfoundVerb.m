//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "ConfoundVerb.h"


@implementation ConfoundVerb

- (NSString *)name
{
    return @"confound";
}

- (NSArray<CLKOption *> *)options
{
    CLKIntArgumentTransformer *intTransformer = [CLKIntArgumentTransformer new];
    
    return @[
        [CLKOption optionWithName:@"acme" flag:@"a"],
        [CLKOption optionWithName:@"station" flag:@"s"],
        [CLKOption parameterOptionWithName:@"oxygen" flag:@"o" required:YES recurrent:YES transformer:intTransformer]
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
