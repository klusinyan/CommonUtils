//  Created by Karen Lusinyan on 22/09/16.
//  Copyright © 2016 Karen Lusinyan. All rights reserved.

#import "CommonAnimationPrototype.h"

@implementation CommonAnimationPrototype

- (id)init
{
    self = [super init];
    if (self) {
        //custom init
    }
    return self;
}

+ (instancetype)animation
{
    return [[self alloc] init];
}

@end
