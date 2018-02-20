//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "CombinationEngine.h"

#import "CombinationTumbler.h"


id CEPrototypeNoValue;


__attribute__((constructor))
static void _init(void)
{
    CEPrototypeNoValue = [[NSUUID alloc] init];
}


@interface CombinationEngine () <CombinationTumblerDelegate>

@end


@implementation CombinationEngine
{
    NSMutableArray<CombinationTumbler *> *_tumblers;
    NSMapTable<CombinationTumbler *, CombinationTumbler *> *_tumblerOrderSiblings; // tumbler -> next highest order tumbler
    BOOL _exhausted;
}

- (instancetype)initWithPrototype:(NSDictionary<NSString *, NSArray *> *)prototype
{
    NSParameterAssert(prototype.count > 0);
    
    self = [super init];
    if (self != nil) {
        _tumblers = [[NSMutableArray alloc] init];
        for (NSString *key in prototype) {
            id values = prototype[key];
            CombinationTumbler *tumbler = [[CombinationTumbler alloc] initWithIdentifier:key values:values delegate:self];
            [_tumblers addObject:tumbler];
            [tumbler release];
        }
        
        _tumblerOrderSiblings = [[NSMapTable weakToWeakObjectsMapTable] retain];
        for (NSUInteger i = 0, j = 1 ; j < _tumblers.count ; i++, j++) {
            [_tumblerOrderSiblings setObject:_tumblers[j] forKey:_tumblers[i]];
        }
    }
    
    return self;
}

- (void)dealloc
{
    [_tumblerOrderSiblings release];
    [_tumblers release];
    [super dealloc];
}

- (void)enumerateCombinations:(void (^)(NSDictionary<NSString *, id> *))combinationBlock
{
    NSAssert(!_exhausted, @"attempting to re-run an engine");
    
    do {
        @autoreleasepool {
            // build a combination
            NSMutableDictionary *combination = [[NSMutableDictionary alloc] init];
            for (CombinationTumbler *tumbler in _tumblers) {
                if (tumbler.currentValue == CEPrototypeNoValue) {
                    // skip this tumbler
                    continue;
                }
                
                combination[tumbler.identifier] = tumbler.currentValue;
            }
            
            // dispatch the combination to the client and advance the machine
            combinationBlock(combination);
            [_tumblers[0] turn];
            [combination release];
        }
    } while (!_exhausted);
}

#pragma mark -
#pragma mark <CombinationTumblerDelegate>

- (void)tumblerDidTurnOver:(CombinationTumbler *)tumbler
{
    CombinationTumbler *nextTumbler = [_tumblerOrderSiblings objectForKey:tumbler];
    if (nextTumbler == nil) {
        _exhausted = YES;
        return;
    } else {
        [nextTumbler turn];
    }
}

@end
