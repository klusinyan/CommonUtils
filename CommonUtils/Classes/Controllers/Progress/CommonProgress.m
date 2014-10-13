//  Created by Yiming Tang on 14-2-9.
//  Modified by Karen Lusinyan
//  Copyright (c) 2014 Yiming Tang. All rights reserved.

#import "CommonProgress.h"

@interface CommonProgress ()

@property (nonatomic, assign) BOOL animating;
@property (nonatomic, strong) UIImageView *indicatorImageView;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) id target;

@property (readwrite, nonatomic, copy) ShowCompletionHandler showCompetion;
@property (readwrite, nonatomic, copy) HideCompletionHandler hideCompetion;

@end

@implementation CommonProgress

#pragma mark - Accessors

@synthesize animating = _animating;
@synthesize indicatorImage = _indicatorImage;
@synthesize backgroundImage = _backgroundImage;
@synthesize indicatorImageView = _indicatorImageView;
@synthesize backgroundImageView = _backgroundImageView;
@synthesize hidesWhenStopped = _hidesWhenStopped;
@synthesize fullRotationDuration = _fullRotationDuration;
@synthesize progress = _progress;
@synthesize minProgressUnit = _minProgressUnit;
@synthesize activityIndicatorViewStyle = _activityIndicatorViewStyle;

- (UIImageView *)backgroundImageView
{
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _backgroundImageView;
}


- (UIImageView *)indicatorImageView
{
    if (!_indicatorImageView) {
        _indicatorImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _indicatorImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _indicatorImageView;
}


- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundImage = backgroundImage;
    self.backgroundImageView.image = _backgroundImage;
    [self setNeedsLayout];
}


- (void)setIndicatorImage:(UIImage *)indicatorImage
{
    _indicatorImage = indicatorImage;
    self.indicatorImageView.image = _indicatorImage;
    [self setNeedsLayout];
}


- (void)setActivityIndicatorViewStyle:(CommonProgressActivityIndicatorViewStyle)activityIndicatorViewStyle
{
    _activityIndicatorViewStyle = activityIndicatorViewStyle;
    
    NSString *backgroundImageName;
    NSString *indicatorImageName;
    switch (_activityIndicatorViewStyle) {
        case CommonProgressActivityIndicatorViewStyleSmall:
            backgroundImageName = @"ResourceBundle.bundle/CommonProgress.bundle/background-small";
            indicatorImageName = @"ResourceBundle.bundle/CommonProgress.bundle/spinner-small";
            break;
        case CommonProgressActivityIndicatorViewStyleNormal:
            backgroundImageName = @"ResourceBundle.bundle/CommonProgress.bundle/background-normal";
            indicatorImageName = @"ResourceBundle.bundle/CommonProgress.bundle/spinner-normal";
            break;
        case CommonProgressActivityIndicatorViewStyleLarge:
            backgroundImageName = @"ResourceBundle.bundle/CommonProgress.bundle/background-large";
            indicatorImageName = @"ResourceBundle.bundle/CommonProgress.bundle/spinner-large";
            break;
    }
    
    _backgroundImage = [UIImage imageNamed:backgroundImageName];
    _indicatorImage = [UIImage imageNamed:indicatorImageName];
    self.backgroundImageView.image = _backgroundImage;
    self.indicatorImageView.image = _indicatorImage;
    [self setNeedsLayout];
}


- (BOOL)isAnimating
{
    return self.animating;
}

#pragma mark - UIView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self _initialize];
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self _initialize];
    }
    return self;
}

- (id)init
{
    if ((self = [super init])) {
        [self _initialize];
    }
    return self;
}

- (id)initWithActivityIndicatorStyle:(CommonProgressActivityIndicatorViewStyle)style
{
    if ((self = [self initWithFrame:CGRectZero])) {
        self.activityIndicatorViewStyle = style;
        [self sizeToFit];
    }
    
    return self;
}

+ (instancetype)sharedProgress
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

+ (void)showWithTaregt:(id)target completion:(ShowCompletionHandler)completion
{
    //hides the old one
    [CommonProgress hideWithCompletion:nil];
    
    //shows the new one
    CommonProgress *sharedProgress = [CommonProgress sharedProgress];
    sharedProgress.translatesAutoresizingMaskIntoConstraints = NO;
    sharedProgress.target = target;
    sharedProgress.activityIndicatorViewStyle = CommonProgressActivityIndicatorViewStyleNormal; //default
    sharedProgress.showCompetion = completion;
    
    if (!target) {
        NSLog(@"Warning: please provide valid target for common progress");
        return;
    }
    
    //use NSAutoLayout to position in target view
    UIView *targetView = nil;
    if ([target isKindOfClass:[UIViewController class]]) {
        targetView = ((UIViewController *)target).view;
        [targetView addSubview:sharedProgress];
        [targetView addConstraint:[NSLayoutConstraint constraintWithItem:sharedProgress
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:[sharedProgress superview]
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1
                                                                constant:0]];
        
        [targetView addConstraint:[NSLayoutConstraint constraintWithItem:sharedProgress
                                                               attribute:NSLayoutAttributeCenterY
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:[sharedProgress superview]
                                                               attribute:NSLayoutAttributeCenterY
                                                              multiplier:1
                                                                constant:0]];
        
    }
    
    [sharedProgress startAnimating];
}

+ (void)hideWithCompletion:(HideCompletionHandler)completion
{
    if ([[CommonProgress sharedProgress] isAnimating]) {
        [CommonProgress sharedProgress].hideCompetion = completion;
        [[CommonProgress sharedProgress] stopAnimating];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize size = self.bounds.size;
    CGSize backgroundImageSize = self.backgroundImageView.image.size;
    CGSize indicatorImageSize = self.indicatorImageView.image.size;
    
    // Center
    self.backgroundImageView.frame = CGRectMake(roundf((size.width - backgroundImageSize.width) / 2.0f), roundf((size.height - backgroundImageSize.height) / 2.0f), backgroundImageSize.width, backgroundImageSize.height);
    self.indicatorImageView.frame = CGRectMake(roundf((size.width - indicatorImageSize.width) / 2.0f), roundf((size.height - indicatorImageSize.height) / 2.0f), indicatorImageSize.width, indicatorImageSize.height);
}


- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize backgroundImageSize = self.backgroundImageView.image.size;
    CGSize indicatorImageSize = self.indicatorImageView.image.size;
    
    return CGSizeMake(fmaxf(backgroundImageSize.width, indicatorImageSize.width), fmaxf(backgroundImageSize.height, indicatorImageSize.height));
}


#pragma mark - Public

- (void)startAnimating
{
    UIView *targetView = nil;
    if ([[CommonProgress sharedProgress].target isKindOfClass:[UIViewController class]]) {
        targetView = ((UIViewController *)[CommonProgress sharedProgress].target).view;
        targetView.userInteractionEnabled = NO;
    }
    
    if (self.animating) return;
    
    self.animating = YES;
    self.hidden = NO;
    [self _rotateImageViewFrom:0.0f to:M_PI*2 duration:self.fullRotationDuration repeatCount:HUGE_VALF];
}


- (void)stopAnimating
{
    UIView *targetView = nil;
    if ([[CommonProgress sharedProgress].target isKindOfClass:[UIViewController class]]) {
        targetView = ((UIViewController *)[CommonProgress sharedProgress].target).view;
        targetView.userInteractionEnabled = YES;
    }
    
    if (!self.animating) return;
    
    self.animating = NO;
    [self.indicatorImageView.layer removeAllAnimations];
    if (self.hidesWhenStopped) {
        self.hidden = YES;
    }
    
    if (self.hideCompetion) self.hideCompetion();
}


- (void)setProgress:(CGFloat)progress
{
    if (progress < 0.0f || progress > 1.0f) return;
    if (fabsf(_progress - progress) < self.minProgressUnit) return;
    
    CGFloat fromValue = M_PI * 2 * _progress;
    CGFloat toValue = M_PI * 2 * progress;
    [self _rotateImageViewFrom:fromValue to:toValue duration:0.15f repeatCount:0];
    
    _progress = progress;
}


#pragma mark - Private

- (void)_initialize
{
    self.userInteractionEnabled = NO;
    
    _animating = NO;
    _hidesWhenStopped = YES;
    _fullRotationDuration = 1.0f;
    _minProgressUnit = 0.01f;
    _progress = 0.0f;
    
    [self addSubview:self.backgroundImageView];
    [self addSubview:self.indicatorImageView];
}


- (void)_rotateImageViewFrom:(CGFloat)fromValue to:(CGFloat)toValue duration:(CFTimeInterval)duration repeatCount:(CGFloat)repeatCount
{
    CABasicAnimation *rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.fromValue = [NSNumber numberWithFloat:fromValue];
    rotationAnimation.toValue = [NSNumber numberWithFloat:toValue];
    rotationAnimation.duration = duration;
    rotationAnimation.RepeatCount = repeatCount;
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.fillMode = kCAFillModeForwards;
    rotationAnimation.delegate = self;
    [self.indicatorImageView.layer addAnimation:rotationAnimation forKey:@"rotation"];
}

- (void)animationDidStart:(CAAnimation *)anim
{
    if (self.showCompetion) self.showCompetion();
}

@end
