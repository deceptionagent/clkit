//
//  Copyright © 2018 Plastic Pulse. All rights reserved.
//

#import "CEGenerator+Building.h"
#import "CEGenerator_Private.h"

#import "CETemplate.h"
#import "CEVariant.h"
#import "CEVariantBuilder.h"


@implementation CEGenerator (Building)

+ (CEGenerator *)generatorWithTemplate:(CETemplate *)template
{
    NSArray<CEVariant *> *variants = [CEVariantBuilder variantsFromTemplate:template];
    return [[CEGenerator alloc] initWithVariants:variants];
}

@end
