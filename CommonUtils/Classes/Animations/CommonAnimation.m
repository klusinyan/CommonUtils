//  Created by Karen Lusinyan on 22/09/16.
//  Copyright © 2016 Karen Lusinyan. All rights reserved.

#import "CommonAnimation.h"

NSString *const CommonAnimationExceptionMethodNotImplemented = @"CommonAnimationExceptionMethodNotImplemented";

@interface CommonAnimation ()


@end

@implementation CommonAnimation

@synthesize duration = _duration;
@synthesize delay    = _delay;

static NSMutableDictionary *_animationClasses;

+ (void)load
{
    _animationClasses = [[NSMutableDictionary alloc] init];
}

+ (void)performAnimationOnView:(UIView *)view
                      duration:(NSTimeInterval)duration
                         delay:(NSTimeInterval)delay
{
    [self performAnimationOnView:view
                        duration:duration
                           delay:delay
                      completion:nil];
}

+ (void)performAnimationOnView:(UIView *)view
                      duration:(NSTimeInterval)duration
                         delay:(NSTimeInterval)delay
                    completion:(void(^)(BOOL finished))completion
{
    [NSException raise:CommonAnimationExceptionMethodNotImplemented format:@"+[%@ performAnimationOnView:duration:delay:] needed to be implemented", NSStringFromClass(self)];
}

+ (void)registerClass:(Class)class forAnimationType:(CommonAnimationType)animationType
{
    [_animationClasses setObject:class forKey:animationType];
}

+ (Class)classForAnimationType:(CommonAnimationType)animationType
{
    return [_animationClasses objectForKey:animationType];
}

@end

#pragma mark - Bounce

@interface CommonBounceLeft : CommonAnimation
@end
@implementation CommonBounceLeft
+ (void)load
{
    [self registerClass:self forAnimationType:CommonAnimationTypeBounceLeft];
}
+ (void)performAnimationOnView:(UIView *)view
                      duration:(NSTimeInterval)duration
                         delay:(NSTimeInterval)delay
                    completion:(void (^)(BOOL finished))completion
{
    // Start
    view.transform = CGAffineTransformMakeTranslation(300, 0);
    [UIView animateKeyframesWithDuration:duration/4 delay:delay options:0 animations:^{
        // End
        view.transform = CGAffineTransformMakeTranslation(-10, 0);
    } completion:^(BOOL finished) {
        [UIView animateKeyframesWithDuration:duration/4 delay:0 options:0 animations:^{
            // End
            view.transform = CGAffineTransformMakeTranslation(5, 0);
        } completion:^(BOOL finished) {
            [UIView animateKeyframesWithDuration:duration/4 delay:0 options:0 animations:^{
                // End
                view.transform = CGAffineTransformMakeTranslation(-2, 0);
            } completion:^(BOOL finished) {
                [UIView animateKeyframesWithDuration:duration/4 delay:0 options:0 animations:^{
                    // End
                    view.transform = CGAffineTransformMakeTranslation(0, 0);
                } completion:^(BOOL finished) {
                    if (completion) completion(finished);
                }];
            }];
        }];
    }];
}
@end

@interface CommonBounceRight : CommonAnimation
@end
@implementation CommonBounceRight
+ (void)load
{
    [self registerClass:self forAnimationType:CommonAnimationTypeBounceRight];
}
+ (void)performAnimationOnView:(UIView *)view
                      duration:(NSTimeInterval)duration
                         delay:(NSTimeInterval)delay
                    completion:(void (^)(BOOL finished))completion
{
    // Start
    view.transform = CGAffineTransformMakeTranslation(-300, 0);
    [UIView animateKeyframesWithDuration:duration/4 delay:delay options:0 animations:^{
        // End
        view.transform = CGAffineTransformMakeTranslation(10, 0);
    } completion:^(BOOL finished) {
        [UIView animateKeyframesWithDuration:duration/4 delay:0 options:0 animations:^{
            // End
            view.transform = CGAffineTransformMakeTranslation(-5, 0);
        } completion:^(BOOL finished) {
            [UIView animateKeyframesWithDuration:duration/4 delay:0 options:0 animations:^{
                // End
                view.transform = CGAffineTransformMakeTranslation(2, 0);
            } completion:^(BOOL finished) {
                [UIView animateKeyframesWithDuration:duration/4 delay:0 options:0 animations:^{
                    // End
                    view.transform = CGAffineTransformMakeTranslation(0, 0);
                } completion:^(BOOL finished) {
                    if (completion) completion(finished);
                }];
            }];
        }];
    }];
}
@end

@interface CommonBounceDown : CommonAnimation
@end
@implementation CommonBounceDown
+ (void)load
{
    [self registerClass:self forAnimationType:CommonAnimationTypeBounceDown];
}
+ (void)performAnimationOnView:(UIView *)view
                      duration:(NSTimeInterval)duration
                         delay:(NSTimeInterval)delay
                    completion:(void (^)(BOOL finished))completion
{
    // Start
    view.transform = CGAffineTransformMakeTranslation(0, -300);
    [UIView animateKeyframesWithDuration:duration/4 delay:delay options:0 animations:^{
        // End
        view.transform = CGAffineTransformMakeTranslation(0, -10);
    } completion:^(BOOL finished) {
        [UIView animateKeyframesWithDuration:duration/4 delay:0 options:0 animations:^{
            // End
            view.transform = CGAffineTransformMakeTranslation(0, 5);
        } completion:^(BOOL finished) {
            [UIView animateKeyframesWithDuration:duration/4 delay:0 options:0 animations:^{
                // End
                view.transform = CGAffineTransformMakeTranslation(0, -2);
            } completion:^(BOOL finished) {
                [UIView animateKeyframesWithDuration:duration/4 delay:0 options:0 animations:^{
                    // End
                    view.transform = CGAffineTransformMakeTranslation(0, 0);
                } completion:^(BOOL finished) {
                    if (completion) completion(finished);
                }];
            }];
        }];
    }];
}
@end

@interface CommonBounceUp : CommonAnimation
@end
@implementation CommonBounceUp
+ (void)load
{
    [self registerClass:self forAnimationType:CommonAnimationTypeBounceUp];
}
+ (void)performAnimationOnView:(UIView *)view
                      duration:(NSTimeInterval)duration
                         delay:(NSTimeInterval)delay
                    completion:(void (^)(BOOL finished))completion
{
    // Start
    view.transform = CGAffineTransformMakeTranslation(0, 300);
    [UIView animateKeyframesWithDuration:duration/4 delay:delay options:0 animations:^{
        // End
        view.transform = CGAffineTransformMakeTranslation(0, 10);
    } completion:^(BOOL finished) {
        [UIView animateKeyframesWithDuration:duration/4 delay:0 options:0 animations:^{
            // End
            view.transform = CGAffineTransformMakeTranslation(0, -5);
        } completion:^(BOOL finished) {
            [UIView animateKeyframesWithDuration:duration/4 delay:0 options:0 animations:^{
                // End
                view.transform = CGAffineTransformMakeTranslation(0, 2);
            } completion:^(BOOL finished) {
                [UIView animateKeyframesWithDuration:duration/4 delay:0 options:0 animations:^{
                    // End
                    view.transform = CGAffineTransformMakeTranslation(0, 0);
                } completion:^(BOOL finished) {
                    if (completion) completion(finished);
                }];
            }];
        }];
    }];
}
@end


#pragma mark - Slide
@interface CommonSlideLeft : CommonAnimation
@end
@implementation CommonSlideLeft
+ (void)load
{
    [self registerClass:self forAnimationType:CommonAnimationTypeSlideLeft];
}
+ (void)performAnimationOnView:(UIView *)view
                      duration:(NSTimeInterval)duration
                         delay:(NSTimeInterval)delay
                    completion:(void (^)(BOOL finished))completion
{
    // Start
    view.transform = CGAffineTransformMakeTranslation(300, 0);
    [UIView animateKeyframesWithDuration:duration delay:delay options:0 animations:^{
        // End
        view.transform = CGAffineTransformMakeTranslation(0, 0);
    } completion:^(BOOL finished) {
        if (completion) completion(finished);
    }];
}
@end

@interface CommonSlideRight : CommonAnimation
@end
@implementation CommonSlideRight
+ (void)load
{
    [self registerClass:self forAnimationType:CommonAnimationTypeSlideRight];
}
+ (void)performAnimationOnView:(UIView *)view
                      duration:(NSTimeInterval)duration
                         delay:(NSTimeInterval)delay
                    completion:(void (^)(BOOL finished))completion
{
    // Start
    view.transform = CGAffineTransformMakeTranslation(-300, 0);
    [UIView animateKeyframesWithDuration:duration delay:delay options:0 animations:^{
        // End
        view.transform = CGAffineTransformMakeTranslation(0, 0);
    } completion:^(BOOL finished) {
        if (completion) completion(finished);
    }];
}
@end

@interface CommonSlideDown : CommonAnimation
@end
@implementation CommonSlideDown
+ (void)load
{
    [self registerClass:self forAnimationType:CommonAnimationTypeSlideDown];
}
+ (void)performAnimationOnView:(UIView *)view
                      duration:(NSTimeInterval)duration
                         delay:(NSTimeInterval)delay
                    completion:(void (^)(BOOL finished))completion
{
    // Start
    view.transform = CGAffineTransformMakeTranslation(0, -300);
    [UIView animateKeyframesWithDuration:duration delay:delay options:0 animations:^{
        // End
        view.transform = CGAffineTransformMakeTranslation(0, 0);
    } completion:^(BOOL finished) {
        if (completion) completion(finished);
    }];
}
@end

@interface CommonSlideUp : CommonAnimation
@end
@implementation CommonSlideUp
+ (void)load
{
    [self registerClass:self forAnimationType:CommonAnimationTypeSlideUp];
}
+ (void)performAnimationOnView:(UIView *)view
                      duration:(NSTimeInterval)duration
                         delay:(NSTimeInterval)delay
                    completion:(void (^)(BOOL finished))completion
{
    // Start
    view.transform = CGAffineTransformMakeTranslation(0, 300);
    [UIView animateKeyframesWithDuration:duration delay:delay options:0 animations:^{
        // End
        view.transform = CGAffineTransformMakeTranslation(0, 0);
    } completion:^(BOOL finished) {
        if (completion) completion(finished);
    }];
}
@end


#pragma mark - Fade
@interface CommonFadeIn : CommonAnimation
@end
@implementation CommonFadeIn
+ (void)load
{
    [self registerClass:self forAnimationType:CommonAnimationTypeFadeIn];
}
+ (void)performAnimationOnView:(UIView *)view
                      duration:(NSTimeInterval)duration
                         delay:(NSTimeInterval)delay
                    completion:(void (^)(BOOL finished))completion
{
    // Start
    view.alpha = 0;
    [UIView animateKeyframesWithDuration:duration delay:delay options:0 animations:^{
        // End
        view.alpha = 1;
    } completion:^(BOOL finished) {
        if (completion) completion(finished);
    }];
}
@end

@interface CommonFadeOut : CommonAnimation
@end
@implementation CommonFadeOut
+ (void)load
{
    [self registerClass:self forAnimationType:CommonAnimationTypeFadeOut];
}
+ (void)performAnimationOnView:(UIView *)view
                      duration:(NSTimeInterval)duration
                         delay:(NSTimeInterval)delay
                    completion:(void (^)(BOOL finished))completion
{
    // Start
    view.alpha = 1;
    [UIView animateKeyframesWithDuration:duration delay:delay options:0 animations:^{
        // End
        view.alpha = 0;
    } completion:^(BOOL finished) {
        if (completion) completion(finished);
    }];
}
@end

@interface CommonFadeInLeft : CommonAnimation
@end
@implementation CommonFadeInLeft
+ (void)load
{
    [self registerClass:self forAnimationType:CommonAnimationTypeFadeInLeft];
}
+ (void)performAnimationOnView:(UIView *)view
                      duration:(NSTimeInterval)duration
                         delay:(NSTimeInterval)delay
                    completion:(void (^)(BOOL finished))completion
{
    // Start
    view.alpha = 0;
    view.transform = CGAffineTransformMakeTranslation(300, 0);
    [UIView animateKeyframesWithDuration:duration delay:delay options:0 animations:^{
        // End
        view.alpha = 1;
        view.transform = CGAffineTransformMakeTranslation(0, 0);
    } completion:^(BOOL finished) {
        if (completion) completion(finished);
    }];
}
@end

@interface CommonFadeInRight : CommonAnimation
@end
@implementation CommonFadeInRight
+ (void)load
{
    [self registerClass:self forAnimationType:CommonAnimationTypeFadeInRight];
}
+ (void)performAnimationOnView:(UIView *)view
                      duration:(NSTimeInterval)duration
                         delay:(NSTimeInterval)delay
                    completion:(void (^)(BOOL finished))completion
{
    // Start
    view.alpha = 0;
    view.transform = CGAffineTransformMakeTranslation(-300, 0);
    [UIView animateKeyframesWithDuration:duration delay:delay options:0 animations:^{
        // End
        view.alpha = 1;
        view.transform = CGAffineTransformMakeTranslation(0, 0);
    } completion:^(BOOL finished) {
        if (completion) completion(finished);
    }];
}
@end

@interface CommonFadeInDown : CommonAnimation
@end
@implementation CommonFadeInDown
+ (void)load
{
    [self registerClass:self forAnimationType:CommonAnimationTypeFadeInDown];
}
+ (void)performAnimationOnView:(UIView *)view
                      duration:(NSTimeInterval)duration
                         delay:(NSTimeInterval)delay
                    completion:(void (^)(BOOL finished))completion
{
    // Start
    view.alpha = 0;
    view.transform = CGAffineTransformMakeTranslation(0, -300);
    [UIView animateKeyframesWithDuration:duration delay:delay options:0 animations:^{
        // End
        view.alpha = 1;
        view.transform = CGAffineTransformMakeTranslation(0, 0);
    } completion:^(BOOL finished) {
        if (completion) completion(finished);
    }];
}
@end

@interface CommonFadeInUp : CommonAnimation
@end
@implementation CommonFadeInUp
+ (void)load
{
    [self registerClass:self forAnimationType:CommonAnimationTypeFadeInUp];
}
+ (void)performAnimationOnView:(UIView *)view
                      duration:(NSTimeInterval)duration
                         delay:(NSTimeInterval)delay
                    completion:(void (^)(BOOL finished))completion
{
    // Start
    view.alpha = 0;
    view.transform = CGAffineTransformMakeTranslation(0, 300);
    [UIView animateKeyframesWithDuration:duration delay:delay options:0 animations:^{
        // End
        view.alpha = 1;
        view.transform = CGAffineTransformMakeTranslation(0, 0);
    } completion:^(BOOL finished) {
        if (completion) completion(finished);
    }];
}
@end

#pragma mark - Fun
@interface CommonPop : CommonAnimation
@end
@implementation CommonPop
+ (void)load
{
    [self registerClass:self forAnimationType:CommonAnimationTypePop];
}
+ (void)performAnimationOnView:(UIView *)view
                      duration:(NSTimeInterval)duration
                         delay:(NSTimeInterval)delay
                    completion:(void (^)(BOOL finished))completion
{
    // Start
    view.transform = CGAffineTransformMakeScale(1, 1);
    [UIView animateKeyframesWithDuration:duration/3 delay:delay options:0 animations:^{
        // End
        view.transform = CGAffineTransformMakeScale(1.2, 1.2);
    } completion:^(BOOL finished) {
        [UIView animateKeyframesWithDuration:duration/3 delay:0 options:0 animations:^{
            // End
            view.transform = CGAffineTransformMakeScale(0.9, 0.9);
        } completion:^(BOOL finished) {
            [UIView animateKeyframesWithDuration:duration/3 delay:0 options:0 animations:^{
                // End
                view.transform = CGAffineTransformMakeScale(1, 1);
            } completion:^(BOOL finished) {
                if (completion) completion(finished);
            }];
        }];
    }];
}
@end

@interface CommonMorph : CommonAnimation
@end
@implementation CommonMorph
+ (void)load
{
    [self registerClass:self forAnimationType:CommonAnimationTypeMorph];
}
+ (void)performAnimationOnView:(UIView *)view
                      duration:(NSTimeInterval)duration
                         delay:(NSTimeInterval)delay
                    completion:(void (^)(BOOL finished))completion
{
    // Start
    view.transform = CGAffineTransformMakeScale(1, 1);
    [UIView animateKeyframesWithDuration:duration/4 delay:delay options:0 animations:^{
        // End
        view.transform = CGAffineTransformMakeScale(1, 1.2);
    } completion:^(BOOL finished) {
        [UIView animateKeyframesWithDuration:duration/4 delay:0 options:0 animations:^{
            // End
            view.transform = CGAffineTransformMakeScale(1.2, 0.9);
        } completion:^(BOOL finished) {
            [UIView animateKeyframesWithDuration:duration/4 delay:0 options:0 animations:^{
                // End
                view.transform = CGAffineTransformMakeScale(0.9, 0.9);
            } completion:^(BOOL finished) {
                [UIView animateKeyframesWithDuration:duration/4 delay:0 options:0 animations:^{
                    // End
                    view.transform = CGAffineTransformMakeScale(1, 1);
                } completion:^(BOOL finished) {
                    if (completion) completion(finished);
                }];
            }];
        }];
    }];
}
@end

@interface CommonFlash : CommonAnimation
@end
@implementation CommonFlash
+ (void)load
{
    [self registerClass:self forAnimationType:CommonAnimationTypeFlash];
}
+ (void)performAnimationOnView:(UIView *)view
                      duration:(NSTimeInterval)duration
                         delay:(NSTimeInterval)delay
                    completion:(void (^)(BOOL finished))completion
{
    // Start
    view.alpha = 0;
    [UIView animateKeyframesWithDuration:duration/3 delay:delay options:0 animations:^{
        // End
        view.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateKeyframesWithDuration:duration/3 delay:0 options:0 animations:^{
            // End
            view.alpha = 0;
        } completion:^(BOOL finished) {
            [UIView animateKeyframesWithDuration:duration/3 delay:0 options:0 animations:^{
                // End
                view.alpha = 1;
            } completion:^(BOOL finished) {
                if (completion) completion(finished);
            }];
        }];
    }];
}
@end

@interface CommonShake : CommonAnimation
@end
@implementation CommonShake
+ (void)load
{
    [self registerClass:self forAnimationType:CommonAnimationTypeShake];
}
+ (void)performAnimationOnView:(UIView *)view
                      duration:(NSTimeInterval)duration
                         delay:(NSTimeInterval)delay
                    completion:(void (^)(BOOL finished))completion
{
    // Start
    view.transform = CGAffineTransformMakeTranslation(0, 0);
    [UIView animateKeyframesWithDuration:duration/5 delay:delay options:0 animations:^{
        // End
        view.transform = CGAffineTransformMakeTranslation(30, 0);
    } completion:^(BOOL finished) {
        [UIView animateKeyframesWithDuration:duration/5 delay:0 options:0 animations:^{
            // End
            view.transform = CGAffineTransformMakeTranslation(-30, 0);
        } completion:^(BOOL finished) {
            [UIView animateKeyframesWithDuration:duration/5 delay:0 options:0 animations:^{
                // End
                view.transform = CGAffineTransformMakeTranslation(15, 0);
            } completion:^(BOOL finished) {
                [UIView animateKeyframesWithDuration:duration/5 delay:0 options:0 animations:^{
                    // End
                    view.transform = CGAffineTransformMakeTranslation(-15, 0);
                } completion:^(BOOL finished) {
                    [UIView animateKeyframesWithDuration:duration/5 delay:0 options:0 animations:^{
                        // End
                        view.transform = CGAffineTransformMakeTranslation(0, 0);
                    } completion:^(BOOL finished) {
                        if (completion) completion(finished);
                    }];
                }];
            }];
        }];
    }];
}
@end

@interface CommonZoomIn : CommonAnimation
@end
@implementation CommonZoomIn
+ (void)load
{
    [self registerClass:self forAnimationType:CommonAnimationTypeZoomIn];
}
+ (void)performAnimationOnView:(UIView *)view
                      duration:(NSTimeInterval)duration
                         delay:(NSTimeInterval)delay
                    completion:(void (^)(BOOL finished))completion
{
    // Start
    view.transform = CGAffineTransformMakeScale(1, 1);
    view.alpha = 1;
    [UIView animateKeyframesWithDuration:duration delay:delay options:0 animations:^{
        // End
        view.transform = CGAffineTransformMakeScale(2, 2);
        view.alpha = 0;
    } completion:^(BOOL finished) {
        if (completion) completion(finished);
    }];
}
@end

@interface CommonZoomOut : CommonAnimation
@end
@implementation CommonZoomOut
+ (void)load
{
    [self registerClass:self forAnimationType:CommonAnimationTypeZoomOut];
}
+ (void)performAnimationOnView:(UIView *)view
                      duration:(NSTimeInterval)duration
                         delay:(NSTimeInterval)delay
                    completion:(void (^)(BOOL finished))completion
{
    // Start
    view.transform = CGAffineTransformMakeScale(2, 2);
    view.alpha = 0;
    [UIView animateKeyframesWithDuration:duration delay:delay options:0 animations:^{
        // End
        view.transform = CGAffineTransformMakeScale(1, 1);
        view.alpha = 1;
    } completion:^(BOOL finished) {
        if (completion) completion(finished);
    }];
}
@end

@interface CommonSlideDownReverse : CommonAnimation
@end
@implementation CommonSlideDownReverse
+ (void)load
{
    [self registerClass:self forAnimationType:CommonAnimationTypeSlideDownReverse];
}
+ (void)performAnimationOnView:(UIView *)view
                      duration:(NSTimeInterval)duration
                         delay:(NSTimeInterval)delay
                    completion:(void (^)(BOOL finished))completion
{
    // Start
    view.transform = CGAffineTransformMakeTranslation(0, 0);
    
    [UIView animateKeyframesWithDuration:duration delay:delay options:0 animations:^{
        // End
        view.transform = CGAffineTransformMakeTranslation(0, -568);
    } completion:^(BOOL finished) {
        if (completion) completion(finished);
    }];
}
@end

@interface CommonFadeInSemi : CommonAnimation
@end
@implementation CommonFadeInSemi
+ (void)load
{
    [self registerClass:self forAnimationType:CommonAnimationTypeFadeInSemi];
}
+ (void)performAnimationOnView:(UIView *)view
                      duration:(NSTimeInterval)duration
                         delay:(NSTimeInterval)delay
                    completion:(void (^)(BOOL finished))completion
{
    // Start
    view.alpha = 0;
    [UIView animateKeyframesWithDuration:duration delay:delay options:0 animations:^{
        // End
        view.alpha = 0.4;
    } completion:^(BOOL finished) {
        if (completion) completion(finished);
    }];
}
@end

@interface CommonFadeOutSemi : CommonAnimation
@end
@implementation CommonFadeOutSemi
+ (void)load
{
    [self registerClass:self forAnimationType:CommonAnimationTypeFadeOutSemi];
}
+ (void)performAnimationOnView:(UIView *)view
                      duration:(NSTimeInterval)duration
                         delay:(NSTimeInterval)delay
                    completion:(void (^)(BOOL finished))completion
{
    // Start
    view.alpha = 0.4;
    [UIView animateKeyframesWithDuration:duration delay:delay options:0 animations:^{
        // End
        view.alpha = 0;
    } completion:^(BOOL finished) {
        if (completion) completion(finished);
    }];
}
@end

@interface CommonFadeOutRight : CommonAnimation
@end
@implementation CommonFadeOutRight
+ (void)load
{
    [self registerClass:self forAnimationType:CommonAnimationTypeFadeOutRight];
}
+ (void)performAnimationOnView:(UIView *)view
                      duration:(NSTimeInterval)duration
                         delay:(NSTimeInterval)delay
                    completion:(void (^)(BOOL finished))completion
{
    // Start
    view.alpha = 1;
    view.transform = CGAffineTransformMakeTranslation(0, 0);
    [UIView animateKeyframesWithDuration:duration delay:delay options:0 animations:^{
        // End
        view.alpha = 0;
        view.transform = CGAffineTransformMakeTranslation(300, 0);
    } completion:^(BOOL finished) {
        if (completion) completion(finished);
    }];
}
@end

@interface CommonFadeOutLeft : CommonAnimation
@end
@implementation CommonFadeOutLeft
+ (void)load
{
    [self registerClass:self forAnimationType:CommonAnimationTypeFadeOutLeft];
}
+ (void)performAnimationOnView:(UIView *)view
                      duration:(NSTimeInterval)duration
                         delay:(NSTimeInterval)delay
                    completion:(void (^)(BOOL finished))completion
{
    // Start
    view.alpha = 1;
    view.transform = CGAffineTransformMakeTranslation(0, 0);
    [UIView animateKeyframesWithDuration:duration delay:delay options:0 animations:^{
        // End
        view.alpha = 0;
        view.transform = CGAffineTransformMakeTranslation(-300, 0);
    } completion:^(BOOL finished) {
        if (completion) completion(finished);
    }];
}
@end

@interface CommonPopAlpha : CommonAnimation
@end
@implementation CommonPopAlpha
+ (void)load
{
    [self registerClass:self forAnimationType:CommonAnimationTypePopAlpha];
}
+ (void)performAnimationOnView:(UIView *)view
                      duration:(NSTimeInterval)duration
                         delay:(NSTimeInterval)delay
                    completion:(void (^)(BOOL finished))completion
{
    // Start
    view.alpha = 0;
    view.transform = CGAffineTransformMakeScale(1, 1);
    [UIView animateKeyframesWithDuration:duration/3 delay:delay options:0 animations:^{
        // End
        view.alpha = 1;
        view.transform = CGAffineTransformMakeScale(1.2, 1.2);
    } completion:^(BOOL finished) {
        [UIView animateKeyframesWithDuration:duration/3 delay:0 options:0 animations:^{
            // End
            view.transform = CGAffineTransformMakeScale(0.9, 0.9);
        } completion:^(BOOL finished) {
            [UIView animateKeyframesWithDuration:duration/3 delay:0 options:0 animations:^{
                // End
                view.transform = CGAffineTransformMakeScale(1, 1);
            } completion:^(BOOL finished) {
                if (completion) completion(finished);
            }];
        }];
    }];
}
@end

@interface CommonPopAlphaOut : CommonAnimation
@end
@implementation CommonPopAlphaOut
+ (void)load
{
    [self registerClass:self forAnimationType:CommonAnimationTypePopAlphaOut];
}
+ (void)performAnimationOnView:(UIView *)view
                      duration:(NSTimeInterval)duration
                         delay:(NSTimeInterval)delay
                    completion:(void (^)(BOOL finished))completion
{
    // Start
    view.transform = CGAffineTransformMakeScale(1, 1);
    [UIView animateKeyframesWithDuration:duration/3 delay:delay options:0 animations:^{
        // End
        view.alpha = 1;
        view.transform = CGAffineTransformMakeScale(0.9, 0.9);
    } completion:^(BOOL finished) {
        [UIView animateKeyframesWithDuration:duration/3 delay:0 options:0 animations:^{
            // End
            view.transform = CGAffineTransformMakeScale(1.2, 1.2);
        } completion:^(BOOL finished) {
            [UIView animateKeyframesWithDuration:duration/3 delay:0 options:0 animations:^{
                // End
                view.alpha = 0;
                view.transform = CGAffineTransformMakeScale(1, 1);
            } completion:^(BOOL finished) {
                if (completion) completion(finished);
            }];
        }];
    }];
}
@end

@interface CommonPopDown : CommonAnimation
@end
@implementation CommonPopDown
+ (void)load
{
    [self registerClass:self forAnimationType:CommonAnimationTypePopDown];
}
+ (void)performAnimationOnView:(UIView *)view
                      duration:(NSTimeInterval)duration
                         delay:(NSTimeInterval)delay
                    completion:(void (^)(BOOL finished))completion
{
    // Start
    view.transform = CGAffineTransformMakeScale(1, 1);
    [UIView animateKeyframesWithDuration:duration/3 delay:delay options:0 animations:^{
        // End
        view.transform = CGAffineTransformMakeScale(0.9, 0.9);
    } completion:^(BOOL finished) {
        if (completion) completion(finished);
    }];
}
@end

@interface CommonPopUp : CommonAnimation
@end
@implementation CommonPopUp
+ (void)load
{
    [self registerClass:self forAnimationType:CommonAnimationTypePopUp];
}
+ (void)performAnimationOnView:(UIView *)view
                      duration:(NSTimeInterval)duration
                         delay:(NSTimeInterval)delay
                    completion:(void (^)(BOOL finished))completion
{
    // Start
    view.transform = CGAffineTransformMakeScale(0.9, 0.9);
    [UIView animateKeyframesWithDuration:duration/3 delay:delay options:0 animations:^{
        // End
        view.transform = CGAffineTransformMakeScale(1, 1);
    } completion:^(BOOL finished) {
        if (completion) completion(finished);
    }];
}
@end

@interface CommonPopAlphaUp : CommonAnimation
@end
@implementation CommonPopAlphaUp
+ (void)load
{
    [self registerClass:self forAnimationType:CommonAnimationTypePopAlphaUp];
}
+ (void)performAnimationOnView:(UIView *)view
                      duration:(NSTimeInterval)duration
                         delay:(NSTimeInterval)delay
                    completion:(void (^)(BOOL finished))completion
{
    // Start
    view.alpha = 1;
    view.transform = CGAffineTransformMakeScale(0.9, 0.9);
    
    [UIView animateKeyframesWithDuration:duration/3 delay:delay options:0 animations:^{
        // End
        view.alpha = 0;
        view.transform = CGAffineTransformMakeScale(1.2, 1.2);
    } completion:^(BOOL finished) {
        if (completion) completion(finished);
    }];
}
@end
