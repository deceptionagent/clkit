//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <sysexits.h>

#import "NSArray+CLKAdditions.h"
#import "CLKOption.h"
#import "CLKOptArgManifest.h"
#import "CLKOptArgParser.h"


int main(int argc, const char *argv[])
{
    if (argc == 1) {
        fprintf(stderr, "usage: %s [--flarn | -f] [--bort | -b arg] remainder", getprogname());
        return EX_USAGE;
    }
    
    @autoreleasepool
    {
        NSArray *argvec = [NSArray clk_arrayWithArgv:(argv + 1) argc:(argc - 1)];
        CLKOption *flarnOption = [CLKOption freeOptionWithLongName:@"flarn" shortName:@"f"];
        CLKOption *bortOption = [CLKOption optionWithLongName:@"bort" shortName:@"b"];
        NSArray *options = @[ flarnOption, bortOption ];
        CLKOptArgParser *parser = [CLKOptArgParser parserWithArgumentVector:argvec options:options];
        
        NSError *error;
        CLKOptArgManifest *manifest = [parser parseArguments:&error];
        if (manifest == nil) {
            fprintf(stderr, "%s: %s (error %ld)\n", getprogname(), error.localizedDescription.UTF8String, (long)error.code);
            return 1;
        }
        
        fprintf(stdout, "%s\n", manifest.debugDescription.UTF8String);
    }
    
    return 0;
}
