//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <sysexits.h>

#import "NSArray+OptArgAdditions.h"
#import "Option.h"
#import "OptArgManifest.h"
#import "OptArgParser.h"


int main(int argc, const char *argv[])
{
    if (argc == 1) {
        fprintf(stderr, "usage: %s [--flarn | -f] [--bort | -b arg] remainder", getprogname());
        return EX_USAGE;
    }
    
    @autoreleasepool
    {
        NSArray *argvec = [NSArray arrayWithArgv:(argv + 1) argc:(argc - 1)];
        Option *flarnOption = [Option freeOptionWithLongName:@"flarn" shortName:@"f"];
        Option *bortOption = [Option optionWithLongName:@"bort" shortName:@"b"];
        NSArray *options = @[ flarnOption, bortOption ];
        OptArgParser *parser = [OptArgParser parserWithArgumentVector:argvec options:options];
        
        NSError *error;
        OptArgManifest *manifest = [parser parseArguments:&error];
        if (manifest == nil) {
            fprintf(stderr, "%s: %s (error %ld)\n", getprogname(), error.localizedDescription.UTF8String, (long)error.code);
            return 1;
        }
        
        fprintf(stdout, "%s\n", manifest.debugDescription.UTF8String);
    }
    
    return 0;
}
