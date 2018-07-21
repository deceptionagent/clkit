//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CLKit.h"
#import "ConfoundVerb.h"


int main(int argc, const char *argv[])
{
    @autoreleasepool {
        NSArray *argvec = [NSArray clk_arrayWithArgv:argv+1 argc:argc-1];
        NSArray *verbs = @[
            [[[ConfoundVerb alloc] init] autorelease]
        ];
        
        CLKVerbDepot *depot = [[[CLKVerbDepot alloc] initWithArgumentVector:argvec verbs:verbs] autorelease];
        CLKCommandResult *result = [depot dispatchVerb];
        if (result.errors != nil) {
            fprintf(stderr, "%s\n", result.errorDescription.UTF8String);
        }
        
        return result.exitStatus;
    }
}
