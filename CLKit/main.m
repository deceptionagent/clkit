//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <sysexits.h>

#import "CLKArgumentManifest.h"
#import "CLKArgumentParser.h"
#import "CLKOption.h"
#import "CLKVerb.h"
#import "CLKVerbDepot.h"
#import "NSArray+CLKAdditions.h"


static int verb_flarn(NSArray<NSString *> *argvec)
{
    NSArray *options = @[
        [CLKOption optionWithName:@"alpha" flag:@"a"],
        [CLKOption parameterOptionWithName:@"bravo" flag:@"b" required:YES]
    ];
    
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:argvec options:options];
    CLKArgumentManifest *manifest = [parser parseArguments];
    if (manifest == nil) {
        fprintf(stderr, "%s\n", parser.errors.description.UTF8String);
        return 1;
    }
    
    fprintf(stdout, "*** verb_flarn ***\n\n%s\n", manifest.debugDescription.UTF8String);
    return 0;
}

static int verb_barf(NSArray<NSString *> *argvec)
{
    NSArray *options = @[
        [CLKOption optionWithName:@"charlie" flag:@"c"],
        [CLKOption parameterOptionWithName:@"delta" flag:@"d"]
    ];
    
    CLKArgumentParser *parser = [CLKArgumentParser parserWithArgumentVector:argvec options:options];
    CLKArgumentManifest *manifest = [parser parseArguments];
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
            int status_ = verb_flarn(argvec);
            if (status_ != 0) {
                *outError = [NSError errorWithDomain:@"clklab-error" code:status_ userInfo:nil];
            }
            
            return status_;
        }];
        
        CLKVerb *barf = [CLKVerb verbWithName:@"barf" block:^(NSArray<NSString *> *argvec, NSError **outError) {
            int status_ = verb_barf(argvec);
            if (status_ != 0) {
                *outError = [NSError errorWithDomain:@"clklab-error" code:status_ userInfo:nil];
            }
            
            return status_;
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
