//  Created by Karen Lusinyan on 02/03/15.
//  Copyright (c) 2015 Karen Lusinyan. All rights reserved.

#import "CommonAnimation.h"

@implementation CommonAnimation

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
