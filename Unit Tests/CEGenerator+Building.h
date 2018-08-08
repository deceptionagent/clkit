//
//  Copyright (c) 2018 Plastic Pulse. All rights reserved.
//

#import "CEGenerator.h"


@class CETemplate;

@interface CEGenerator (Building)

+ (CEGenerator *)generatorWithTemplate:(CETemplate *)template;

@end
