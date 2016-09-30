//  Created by Karen Lusinyan on 22/09/16.
//  Copyright © 2016 Karen Lusinyan. All rights reserved.

#import <UIKit/UIKit.h>
#import "CommonAnimation.h"

@interface CommonAnimationView : UIView

@property (nonatomic) NSTimeInterval delay;
@property (nonatomic) NSTimeInterval duration; // default 0.4
@property (nonatomic, copy) CommonAnimationType type;
@property (nonatomic) BOOL pauseAnimationOnAwake;

@end

@interface UIView (CommonAnimationView)

- (void)startCommonAnimation __deprecated_msg("user: performAnimationOnView:duration:delay:completion");

- (void)startCommonAnimationCompletion:(void(^)(BOOL finished))completion;

- (void)startCommonAnimationWithType:(CommonAnimationType)type completion:(void (^)(BOOL finished))completion;

@end
