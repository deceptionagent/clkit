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
            [[ConfoundVerb alloc] init],
            [[DeliveryVerb alloc] init]
        ];
        
        NSArray<id<CLKVerb>> *thrudVerbs = @[
            [[BrainVerb alloc] init],
            [[HangVerb alloc] init]
        ];
        
        CLKVerbFamily *thrud = [CLKVerbFamily familyWithName:@"thrud" verbs:thrudVerbs];
        CLKVerbDepot *depot = [[CLKVerbDepot alloc] initWithArgumentVector:argvec verbs:topLevelVerbs verbFamilies:@[ thrud ]];
        CLKCommandResult *result = [depot dispatchVerb];
        if (result.errors != nil) {
            fprintf(stderr, "%s\n", result.errorDescription.UTF8String);
        }
        
        return result.exitStatus;
    }
}
