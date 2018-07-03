//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "CEVariantBuilder.h"

#import "CETemplate.h"
#import "CETemplateSeries.h"
#import "CEVariant.h"
#import "CEVariantSource.h"
#import "CEVariantTag.h"


@implementation CEVariantBuilder

+ (NSArray<CEVariant *> *)variantsFromTemplate:(CETemplate *)template
{
    NSMutableDictionary<NSString *, NSMutableArray<CEVariantSource *> *> *workspace = [NSMutableDictionary dictionary];
    
    for (CETemplateSeries *series in template.allSeries) {
        NSArray *values;
        if (series.elidable) {
            values = [series.values arrayByAddingObject:CEVariantSource.noValueMarker];
        } else {
            values = series.values;
        }
        
        CEVariantSource *source = [CEVariantSource sourceWithIdentifier:series.identifier values:values];
        for (NSString *tag in series.variants) {
            // if this tag hasn't already been set up in the workspace, add it
            NSMutableArray *sources = workspace[tag];
            if (sources == nil) {
                sources = [NSMutableArray array];
                workspace[tag] = sources;
            }
            
            [sources addObject:source];
        }
    }
    
    // variants are constructed deterministically to aid in testing and debugging.
    // variants are sorted by tag. each variant's sources are sorted alphabetically by identifier.
    
    NSArray *sortedTags = [[workspace allKeys] sortedArrayUsingComparator:^(NSString *tagA, NSString *tagB) {
        return [tagA compare:tagB];
    }];
    
    NSMutableArray<CEVariant *> *variants = [NSMutableArray array];
    
    for (NSString *tag in sortedTags) {
        NSArray *sources = workspace[tag];
        NSArray *sortedSources = [sources sortedArrayUsingComparator:^(CEVariantSource *sourceA, CEVariantSource *sourceB) {
            return [sourceA.identifier compare:sourceB.identifier options:NSLiteralSearch];
        }];
        
        CEVariant *variant = [CEVariant variantWithTag:tag sources:sortedSources];
        [variants addObject:variant];
    }
    
    return variants;
}

@end
