//  Created by Karen Lusinyan on 22/09/16.
//  Copyright © 2016 Karen Lusinyan. All rights reserved.

#import "CommonAnimation.h"

@interface CommonAnimationPrototype : NSObject

@property (nonatomic) NSTimeInterval duration;
@property (nonatomic) NSTimeInterval delay;
@property (nonatomic) CommonAnimationType type;

+ (instancetype)animation;

@end
