//  Created by Karen Lusinyan on 22/09/16.
//  Copyright © 2016 Karen Lusinyan. All rights reserved.

#import <Foundation/Foundation.h>

typedef NSString *CommonAnimationType;

static CommonAnimationType CommonAnimationTypeBounceLeft   = @"bounceLeft";
static CommonAnimationType CommonAnimationTypeBounceRight  = @"bounceRight";
static CommonAnimationType CommonAnimationTypeBounceDown   = @"bounceDown";
static CommonAnimationType CommonAnimationTypeBounceUp     = @"bounceUp";
static CommonAnimationType CommonAnimationTypeFadeIn       = @"fadeIn";
static CommonAnimationType CommonAnimationTypeFadeOut      = @"fadeOut";
static CommonAnimationType CommonAnimationTypeFadeInLeft   = @"fadeInLeft";
static CommonAnimationType CommonAnimationTypeFadeInRight  = @"fadeInRight";
static CommonAnimationType CommonAnimationTypeFadeInDown   = @"fadeInDown";
static CommonAnimationType CommonAnimationTypeFadeInUp     = @"fadeInUp";
static CommonAnimationType CommonAnimationTypeSlideLeft    = @"slideLeft";
static CommonAnimationType CommonAnimationTypeSlideRight   = @"slideRight";
static CommonAnimationType CommonAnimationTypeSlideDown    = @"slideDown";
static CommonAnimationType CommonAnimationTypeSlideUp      = @"slideUp";
static CommonAnimationType CommonAnimationTypePop          = @"pop";
static CommonAnimationType CommonAnimationTypeMorph        = @"morph";
static CommonAnimationType CommonAnimationTypeFlash        = @"flash";
static CommonAnimationType CommonAnimationTypeShake        = @"shake";
static CommonAnimationType CommonAnimationTypeZoomIn       = @"zoomIn";
static CommonAnimationType CommonAnimationTypeZoomOut      = @"zoomOut";
static CommonAnimationType CommonAnimationTypeSlideDownReverse  = @"slideDownReverse";
static CommonAnimationType CommonAnimationTypeFadeInSemi        = @"fadeInSemi";
static CommonAnimationType CommonAnimationTypeFadeOutSemi       = @"fadeOutSemi";
static CommonAnimationType CommonAnimationTypeFadeOutRight      = @"fadeOutRight";
static CommonAnimationType CommonAnimationTypeFadeOutLeft       = @"fadeOutLeft";
static CommonAnimationType CommonAnimationTypePopUp             = @"popUp";
static CommonAnimationType CommonAnimationTypePopDown           = @"popDown";
static CommonAnimationType CommonAnimationTypePopAlpha          = @"popAlpha";
static CommonAnimationType CommonAnimationTypePopAlphaUp        = @"popAlphaUp";
static CommonAnimationType CommonAnimationTypePopAlphaOut       = @"popAlphaOut";

extern NSString *const CommonAnimationExceptionMethodNotImplemented;

@protocol CommonAnimation <NSObject>

@property (nonatomic) NSTimeInterval duration;
@property (nonatomic) NSTimeInterval delay;

+ (void)performAnimationOnView:(UIView *)view
                      duration:(NSTimeInterval)duration
                         delay:(NSTimeInterval)delay __deprecated_msg("user: performAnimationOnView:duration:delay:completion");

+ (void)performAnimationOnView:(UIView *)view
                      duration:(NSTimeInterval)duration
                         delay:(NSTimeInterval)delay
                    completion:(void(^)(BOOL finished))completion;

@end


@interface CommonAnimation : NSObject <CommonAnimation>

+ (void)registerClass:(Class)class forAnimationType:(CommonAnimationType)animationType;
+ (Class)classForAnimationType:(CommonAnimationType)animationType;

@end
