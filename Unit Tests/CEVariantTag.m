//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "CEVariantTag.h"

#import <stdatomic.h>


NS_ASSUME_NONNULL_BEGIN

@interface CEVariantTag ()

+ (uint64_t)_nextSerial;

- (instancetype)_initWithSerial:(uint64_t)serial NS_DESIGNATED_INITIALIZER;

@property (readonly) uint64_t serial;

@end

NS_ASSUME_NONNULL_END


@implementation CEVariantTag
{
    uint64_t _serial;
}

@synthesize serial = _serial;

+ (uint64_t)_nextSerial
{
    static _Atomic uint64_t sLastSerial;
    return atomic_fetch_add(&sLastSerial, 1);
}

+ (instancetype)tag
{
    uint64_t serial = [self _nextSerial];
    return [[[self alloc] _initWithSerial:serial] autorelease];
}

- (instancetype)_initWithSerial:(uint64_t)serial
{
    self = [super init];
    if (self != nil) {
        _serial = serial;
    }
    
    return self;
}

- (id)copyWithZone:(__unused NSZone *)zone
{
    // CEVariantTag is immutable
    return [self retain];
}

- (NSUInteger)hash
{
    return _serial;
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
    return (_serial == tag.serial);
}

- (NSComparisonResult)compare:(CEVariantTag *)tag
{
    if (_serial == tag.serial) {
        return NSOrderedSame;
    }
    
    return (_serial > tag.serial ? NSOrderedDescending : NSOrderedAscending);
}

@end
