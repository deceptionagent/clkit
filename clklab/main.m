//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CLKit.h"

#import "BrainVerb.h"
#import "ConfoundVerb.h"
#import "DeliveryVerb.h"
#import "HangVerb.h"


int main(int argc, const char *argv[])
{
    @autoreleasepool {
        NSArray *argvec = [NSArray clk_arrayWithArgv:argv+1 argc:argc-1];
        NSArray<id<CLKVerb>> *topLevelVerbs = @[
            [[[ConfoundVerb alloc] init] autorelease],
            [[[DeliveryVerb alloc] init] autorelease]
        ];
        
        NSArray<id<CLKVerb>> *thrudVerbs = @[
            [[[BrainVerb alloc] init] autorelease],
            [[[HangVerb alloc] init] autorelease]
        ];
        
        CLKVerbFamily *thrud = [CLKVerbFamily familyWithName:@"thrud" verbs:thrudVerbs];
        CLKVerbDepot *depot = [[[CLKVerbDepot alloc] initWithArgumentVector:argvec verbs:topLevelVerbs verbFamilies:@[ thrud ]] autorelease];
        CLKCommandResult *result = [depot dispatchVerb];
        if (result.errors != nil) {
            fprintf(stderr, "%s\n", result.errorDescription.UTF8String);
        }
        
        return result.exitStatus;
    }
}
