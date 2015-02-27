//  Created by Karen Lusinyan on 27/02/15.
//  Copyright (c) 2015 Karen Lusinyan. All rights reserved.

#import "CSAnimationView.h"

typedef NS_ENUM(NSInteger, CommonAnimationRule) {
    CommonAnimationRuleNone=0,
    CommonAnimationRuleShowOnce,
    CommonAnimationRuleShowAlways,
};

@protocol CommonAnimationDelegate <NSObject>

@optional
@property (nonatomic) CommonAnimationRule animationRule;
@property (nonatomic, getter=isAnimated) BOOL animated;

@end

@interface CommonAnimation : NSObject

@property (nonatomic) CSAnimationType type;
@property (nonatomic) CGFloat delay;
@property (nonatomic) CGFloat duration;

+ (instancetype)animation;

@end
