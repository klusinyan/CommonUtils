//  Created by Karen Lusinyan on 22/09/16.
//  Copyright © 2016 Karen Lusinyan. All rights reserved.

#import "CommonAnimationView.h"

@implementation CommonAnimationView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    if (self.type && self.duration && ! self.pauseAnimationOnAwake) {
        [self startCanvasAnimationCompletion:nil];
    }
}

- (void)startCanvasAnimationCompletion:(void (^)(BOOL))completion
{
    Class <CommonAnimation> class = [CommonAnimation classForAnimationType:self.type];
    
    [class performAnimationOnView:self duration:self.duration delay:self.delay completion:completion];
    
    [super startCanvasAnimationCompletion:completion];
}

@end


@implementation UIView (CommonAnimationView)

- (void)startCanvasAnimation
{
    [[self subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj startCanvasAnimation];
    }];
}

- (void)startCanvasAnimationCompletion:(void (^)(BOOL))completion
{
    [[self subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj startCanvasAnimationCompletion:completion];
    }];
}

@end
