//  Created by Karen Lusinyan on 02/03/15.
//  Copyright (c) 2015 Karen Lusinyan. All rights reserved.

#import "CSAnimation.h"
#import "CSAnimationView.h"

@interface CommonAnimation : NSObject

@property (nonatomic) NSTimeInterval duration;
@property (nonatomic) NSTimeInterval delay;
@property (nonatomic) CSAnimationType type;

+ (instancetype)animation;

@end
