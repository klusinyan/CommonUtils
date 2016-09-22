//  Created by Karen Lusinyan on 22/09/16.
//  Copyright © 2016 Karen Lusinyan. All rights reserved.

#import <UIKit/UIKit.h>
#import "CommonAnimation.h"

@interface CommonAnimationView : UIView

@property (nonatomic) NSTimeInterval delay;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic, copy) CommonAnimationType type;
@property (nonatomic) BOOL pauseAnimationOnAwake;

@end


@interface UIView (CommonAnimationView)

- (void)startCanvasAnimation __deprecated_msg("user: performAnimationOnView:duration:delay:completion");

- (void)startCanvasAnimationCompletion:(void(^)(BOOL finished))completion;

@end
