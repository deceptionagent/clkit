//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "CEVariantSourceView.h"

#import "CETemplateSeries.h"
#import "CEVariantSource.h"


NS_ASSUME_NONNULL_BEGIN

@interface CEVariantSourceView ()

- (void)_notifyObservers_variantSourceViewDidAdvanceToInitialValue;

@end

NS_ASSUME_NONNULL_END

@implementation CEVariantSourceView
{
    CEVariantSource *_source;
    NSUInteger _currentPosition;
    NSHashTable<id<CEVariantSourceViewObserver>> *_observers;
}

@synthesize variantSource = _source;

- (instancetype)initWithVariantSource:(CEVariantSource *)variantSource
{
    NSParameterAssert(variantSource != nil);
    
    self = [super init];
    if (self != nil) {
        _source = [variantSource retain];
        _observers = [[NSHashTable alloc] initWithOptions:(NSPointerFunctionsWeakMemory | NSPointerFunctionsObjectPointerPersonality) capacity:1];
    }
    
    return self;
}

- (void)dealloc
{
    [_observers release];
    [_source release];
    [super dealloc];
}

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"%@ { identifier: '%@' | pos: %llu | value: %@ }", super.debugDescription, _source.identifier, (unsigned long long)_currentPosition, self.value];
}

#pragma mark -

- (id)value
{
    id value = _source.values[_currentPosition];
    return (value == CEVariantSource.noValueMarker ? nil : value);
}

- (void)advance
{
    _currentPosition++;
    if (_currentPosition >= _source.values.count) {
        _currentPosition = 0;
        [self _notifyObservers_variantSourceViewDidAdvanceToInitialValue];
    }
}

#pragma mark -

- (void)addObserver:(id<CEVariantSourceViewObserver>)observer
{
    [_observers addObject:observer];
}

- (void)removeObserver:(id<CEVariantSourceViewObserver>)observer
{
    [_observers removeObject:observer];
}

- (void)_notifyObservers_variantSourceViewDidAdvanceToInitialValue
{
    for (id<CEVariantSourceViewObserver> observer in _observers) {
        [observer variantSourceViewDidAdvanceToInitialValue:self];
    }
}

@end
