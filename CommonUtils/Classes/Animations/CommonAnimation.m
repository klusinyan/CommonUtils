//  Created by Karen Lusinyan on 27/02/15.
//  Copyright (c) 2015 Karen Lusinyan. All rights reserved.

#import "CommonAnimation.h"

@implementation CommonAnimation

- (id)init
{
    if (self = [super init]) {
        //custom init
    }
    return self;
}

+ (instancetype)animation
{
    return [[self alloc] init];
}

@end
