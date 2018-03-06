//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "CEVariantTag.h"


NS_ASSUME_NONNULL_BEGIN

@interface CEVariantTag ()

@property (readonly) NSUUID *UUID;

@end

NS_ASSUME_NONNULL_END


@implementation CEVariantTag
{
    NSUUID *_uuid;
}

@synthesize UUID = _UUID;

+ (instancetype)tag
{
    return [[[self alloc] init] autorelease];
}

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        _uuid = [[NSUUID alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [_uuid release];
    [super dealloc];
}

- (id)copyWithZone:(__unused NSZone *)zone
{
    // CEVariantTag is immutable
    return [self retain];
}

- (NSUInteger)hash
{
    return _uuid.hash;
}

- (BOOL)isEqual:(id)obj
{
    if (obj == self) {
        return YES;
    }
    
    if (![obj isKindOfClass:[CEVariantTag class]]) {
        return NO;
    }
    
    return [self isEqualToVariantTag:obj];
}

- (BOOL)isEqualToVariantTag:(CEVariantTag *)tag
{
    return [_uuid isEqual:tag.UUID];
}

@end
