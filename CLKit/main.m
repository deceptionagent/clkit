//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <sysexits.h>

#import "NSArray+CLKAdditions.h"
#import "CLKOption.h"
#import "CLKOptArgManifest.h"
#import "CLKOptArgParser.h"
#import "CLKVerb.h"
#import "CLKVerbDepot.h"


static int verb_flarn(NSArray<NSString *> *argvec, NSError **outError)
{
    CLKOption *alpha = [CLKOption freeOptionWithLongName:@"alpha" shortName:@"a"];
    CLKOption *bravo = [CLKOption optionWithLongName:@"bravo" shortName:@"b"];
    NSArray *options = @[ alpha, bravo ];
    
    CLKOptArgParser *parser = [CLKOptArgParser parserWithArgumentVector:argvec options:options];
    CLKOptArgManifest *manifest = [parser parseArguments:outError];
    if (manifest == nil) {
        return 1;
    }
    
    fprintf(stdout, "*** verb_flarn ***\n\n%s\n", manifest.debugDescription.UTF8String);
    return 0;
}

static int verb_barf(NSArray<NSString *> *argvec, NSError **outError)
{
    CLKOption *charlie = [CLKOption freeOptionWithLongName:@"charlie" shortName:@"c"];
    CLKOption *delta = [CLKOption optionWithLongName:@"delta" shortName:@"d"];
    NSArray *options = @[ charlie, delta ];
    
    CLKOptArgParser *parser = [CLKOptArgParser parserWithArgumentVector:argvec options:options];
    CLKOptArgManifest *manifest = [parser parseArguments:outError];
    if (manifest == nil) {
        return 1;
    }
    
    fprintf(stdout, "*** verb_barf ***\n\n%s\n", manifest.debugDescription.UTF8String);
    return 0;
}

int main(int argc, const char *argv[])
{
    if (argc == 1) {
        fprintf(stderr, "usage: %s [--flarn | -f] [--bort | -b arg] remainder", getprogname());
        return EX_USAGE;
    }
    
    int status = 0;
    
    @autoreleasepool
    {
        CLKVerb *flarn = [CLKVerb verbWithName:@"flarn" block:^(NSArray<NSString *> *argvec, NSError **outError) {
            return verb_flarn(argvec, outError);
        }];
        
        CLKVerb *barf = [CLKVerb verbWithName:@"barf" block:^(NSArray<NSString *> *argvec, NSError **outError) {
            return verb_barf(argvec, outError);
        }];
        
        NSArray *verbs = @[ flarn, barf ];
        NSArray *argvec = [NSArray clk_arrayWithArgv:argv argc:argc];
        CLKVerbDepot *depot = [[[CLKVerbDepot alloc] initWithArgumentVector:argvec verbs:verbs] autorelease];
        
        NSError *error;
        status = [depot dispatch:&error];
        if (status != 0) {
            fprintf(stderr, "%s: %s (error %ld)\n", getprogname(), error.localizedDescription.UTF8String, (long)error.code);
        }
    }
    
    return status;
}
