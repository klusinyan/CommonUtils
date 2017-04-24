//  Created by Karen Lusinyan on 16/07/14.

#import "CommonProgress.h"
#import "UIImage+Color.h"
#import "NetworkUtils.h"
#import "DirectoryUtils.h"

#define kBundleName @"CommonUtils.bundle/CommonProgress.bundle"

@interface CommonProgress ()
<
CAAnimationDelegate
>

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
    
    UIImage *backgroundImage = nil;
    UIImage *indicatorImage = nil;
    switch (_activityIndicatorViewStyle) {
        case CommonProgressActivityIndicatorViewStyleNormal:
            backgroundImage = [DirectoryUtils imageWithName:@"background-normal" bundleName:kBundleName];
            indicatorImage = [DirectoryUtils imageWithName:@"spinner-normal" bundleName:kBundleName];
            break;
        case CommonProgressActivityIndicatorViewStyleSmall:
            backgroundImage = [DirectoryUtils imageWithName:@"background-small" bundleName:kBundleName];
            indicatorImage = [DirectoryUtils imageWithName:@"spinner-small" bundleName:kBundleName];
            break;
        case CommonProgressActivityIndicatorViewStyleLarge:
            backgroundImage = [DirectoryUtils imageWithName:@"background-large" bundleName:kBundleName];
            indicatorImage = [DirectoryUtils imageWithName:@"spinner-large" bundleName:kBundleName];
            break;
    }
    
    self.backgroundImage = backgroundImage;
    self.indicatorImage = indicatorImage;

    self.backgroundImageView.image = self.backgroundImage;
    self.indicatorImageView.image = self.indicatorImage;

    if (self.backgroundImageColor) {
        self.backgroundImage = [self.backgroundImage imageWithColor:self.backgroundImageColor];
    }
    if (self.indicatorImageColor) {
        self.indicatorImage = [self.indicatorImage imageWithColor:self.indicatorImageColor];
    }

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
    __strong static CommonProgress *_sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
        
        //defualts
        _sharedObject.activityIndicatorViewStyle = CommonProgressActivityIndicatorViewStyleNormal;
        _sharedObject.networkActivityIndicatorVisible = NO;
    });
    return _sharedObject;
}

+ (void)showWithTarget:(id)target completion:(ShowCompletionHandler)completion
{
    //hides the old one
    [CommonProgress hideWithCompletion:^{
        
        //shows the new one
        CommonProgress *sharedProgress = [CommonProgress sharedProgress];
        sharedProgress.translatesAutoresizingMaskIntoConstraints = NO;
        sharedProgress.target = target;
        sharedProgress.showCompetion = completion;
        
        if (!target) {
            NSLog(@"Warning: please provide valid target for common progress");
            return;
        }
        
        //use NSAutoLayout to position in target view
        UIView *targetView = nil;
        if ([target isKindOfClass:[UIViewController class]]) {
            targetView = ((UIViewController *)target).view;
            
        }else if ([target isKindOfClass:[UIView class]]){
            targetView = target;
        }
        
        if (targetView) {
            
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
    }];
}

+ (void)hideWithCompletion:(HideCompletionHandler)completion
{
    [CommonProgress sharedProgress].hideCompetion = completion;
    [[CommonProgress sharedProgress] stopAnimating];
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


#pragma mark -
#pragma mark - Public

- (void)startAnimating
{
    //start if not animating
    if (!self.animating) {
        
        UIView *targetView = nil;
        if ([[CommonProgress sharedProgress].target isKindOfClass:[UIViewController class]]) {
            targetView = ((UIViewController *)[CommonProgress sharedProgress].target).view;
            targetView.userInteractionEnabled = NO;
        }
        
        if (self.networkActivityIndicatorVisible) {
            [NetworkUtils setNetworkActivityIndicatorVisible:YES];
        }
        
        self.animating = YES;
        self.hidden = NO;
        [self _rotateImageViewFrom:0.0f to:M_PI*2 duration:self.fullRotationDuration repeatCount:HUGE_VALF];
    }
}

- (void)stopAnimating
{
    //stop if animating
    if (self.animating) {
        
        UIView *targetView = nil;
        if ([[CommonProgress sharedProgress].target isKindOfClass:[UIViewController class]]) {
            targetView = ((UIViewController *)[CommonProgress sharedProgress].target).view;
            targetView.userInteractionEnabled = YES;
        }
        
        if (self.networkActivityIndicatorVisible) {
            [NetworkUtils setNetworkActivityIndicatorVisible:NO];
        }
        
        self.animating = NO;
        [self.indicatorImageView.layer removeAllAnimations];
        if (self.hidesWhenStopped) {
            self.hidden = YES;
        }
    }
    
    //calling completion done in any case
    if (self.hideCompetion) self.hideCompetion();
}


- (void)setProgress:(CGFloat)progress
{
    if (progress < 0.0f || progress > 1.0f) return;
    if (fabs(_progress - progress) < self.minProgressUnit) return;
    
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
    rotationAnimation.repeatCount = repeatCount;
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.fillMode = kCAFillModeForwards;
    rotationAnimation.delegate = self;
    [self.indicatorImageView.layer addAnimation:rotationAnimation forKey:@"rotation"];
}

- (void)animationDidStart:(CAAnimation *)anim
{
    if (self.showCompetion) self.showCompetion();
}

#pragma mark -
#pragma mark  getter/setter

- (void)setBackgroundImageColor:(UIColor *)backgroundImageColor
{
    if (backgroundImageColor) {
        _backgroundImageColor = backgroundImageColor;
        self.backgroundImage = [self.backgroundImage imageWithColor:backgroundImageColor];
    }
}

- (void)setIndicatorImageColor:(UIColor *)indicatorImageColor
{
    if (indicatorImageColor) {
        _indicatorImageColor = indicatorImageColor;
        self.indicatorImage = [self.indicatorImage imageWithColor:indicatorImageColor];
    }
}

//not used__deprecated("now using networkutils")
+ (void)setNetworkActivityIndicatorVisible:(BOOL)setVisible
{
    static NSInteger NumberOfCallsToSetVisible = 0;
    if (setVisible)
        NumberOfCallsToSetVisible++;
    else
        NumberOfCallsToSetVisible--;
    
    // The assertion helps to find programmer errors in activity indicator management.
    // Since a negative NumberOfCallsToSetVisible is not a fatal error,
    // it should probably be removed from production code.
    //NSAssert(NumberOfCallsToSetVisible >= 0, @"Network Activity Indicator was asked to hide more often than shown");
    
    // Display the indicator as long as our static counter is > 0.
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:(NumberOfCallsToSetVisible > 0)];
}

@end
