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
{
    NSString *_name;
    CLKVerbBlock _block;
}

@synthesize name = _name;
@synthesize block = _block;

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
