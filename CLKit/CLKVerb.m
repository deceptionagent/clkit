//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import "CLKVerb.h"


NS_ASSUME_NONNULL_BEGIN

@interface CLKVerb ()

- (instancetype)_initWithName:(NSString *)name block:(CLKVerbBlock)block;

@end

NS_ASSUME_NONNULL_END


@implementation CLKVerb

@synthesize name = _name;
@synthesize block = _block;
@synthesize hidden = _hidden;

+ (instancetype)verbWithName:(NSString *)name block:(CLKVerbBlock)block
{
    return [[[self alloc] _initWithName:name block:block] autorelease];
}

- (instancetype)_initWithName:(NSString *)name block:(CLKVerbBlock)block
{
    self = [super init];
    if (self != nil) {
        _name = [name copy];
        _block = [block copy];
    }
    
    return self;
}

- (void)dealloc
{
    [_block release];
    [_name release];
    [super dealloc];
}

@end
