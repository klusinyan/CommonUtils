//  Created by Karen Lusinyan on 22/09/16.
//  Copyright © 2016 Karen Lusinyan. All rights reserved.

#import "CommonAnimationView.h"

@implementation CommonAnimationView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.duration = 0.4;
    
    if (self.type && self.duration && ! self.pauseAnimationOnAwake) {
        [self startCommonAnimationCompletion:nil];
    }
}

- (void)startCommonAnimationCompletion:(void (^)(BOOL finished))completion
{
    Class <CommonAnimation> class = [CommonAnimation classForAnimationType:self.type];
    
    [class performAnimationOnView:self duration:self.duration delay:self.delay completion:completion];
    
    [super startCommonAnimationCompletion:completion];
}

- (void)startCommonAnimationWithType:(CommonAnimationType)type completion:(void (^)(BOOL finished))completion
{
    Class <CommonAnimation> class = [CommonAnimation classForAnimationType:type];
    
    [class performAnimationOnView:self duration:self.duration delay:self.delay completion:completion];
    
    [super startCommonAnimationCompletion:completion];
}

@end


@implementation UIView (CommonAnimationView)

- (void)startCommonAnimation
{
    [[self subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj startCommonAnimationCompletion:nil];
    }];
}

- (void)startCommonAnimationCompletion:(void(^)(BOOL))completion
{
    [[self subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj startCommonAnimationCompletion:completion];
    }];
}

- (void)startCommonAnimationWithType:(CommonAnimationType)type completion:(void (^)(BOOL finished))completion
{
    // do nothing
}


@end
