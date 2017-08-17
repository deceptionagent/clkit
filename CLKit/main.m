//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <sysexits.h>

#import "NSArray+CLKAdditions.h"
#import "CLKOption.h"
#import "CLKArgumentManifest.h"
#import "CLKArgumentParser.h"
#import "CLKVerb.h"
#import "CLKVerbDepot.h"


static int verb_flarn(NSArray<NSString *> *argvec, NSError **outError)
{
    NSArray *options = @[
        [CLKOption freeOptionWithName:@"alpha" flag:@"a"],
        [CLKOption optionWithName:@"bravo" flag:@"b"]
    ];
    
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:argvec options:options];
    CLKArgumentManifest *manifest = [parser parseArguments:outError];
    if (manifest == nil) {
        return 1;
    }
    
    fprintf(stdout, "*** verb_flarn ***\n\n%s\n", manifest.debugDescription.UTF8String);
    return 0;
}

static int verb_barf(NSArray<NSString *> *argvec, NSError **outError)
{
    NSArray *options = @[
        [CLKOption freeOptionWithName:@"charlie" flag:@"c"],
        [CLKOption optionWithName:@"delta" flag:@"d"]
    ];
    
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:argvec options:options];
    CLKArgumentManifest *manifest = [parser parseArguments:outError];
    if (manifest == nil) {
        return 1;
    }
    
    fprintf(stdout, "*** verb_barf ***\n\n%s\n", manifest.debugDescription.UTF8String);
    return 0;
}

int main(int argc, const char *argv[])
{
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
