//
//  Copyright (c) 2017 Plastic Pulse. All rights reserved.
//

#import <Foundation/Foundation.h>


@class CLKConstraint;


@protocol CLKConstraintProviding <NSObject>

@required
@property (nullable, readonly) NSArray<CLKConstraint *> *constraints;

@end
