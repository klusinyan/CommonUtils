//  Created by Lukas Lipka 05/04/14.
//  Modified by Karen Lusinyan on 30/01/15.

#import "CommonSpinner.h"

static NSString *kLLARingSpinnerAnimationKey = @"llaringspinnerview.rotation";

@interface CommonSpinner ()

@property (readonly, nonatomic, strong) CAShapeLayer *progressLayer;
@property (readwrite, nonatomic, assign) BOOL isAnimating;
@property (readwrite, nonatomic, assign) id target;

@property (readwrite, nonatomic, copy) CommonSpinnerShowCompletionHandler showCompetion;
@property (readwrite, nonatomic, copy) CommonSpinnerHideCompletionHandler hideCompetion;

@end

@implementation CommonSpinner

@synthesize progressLayer = _progressLayer;
@synthesize isAnimating = _isAnimating;

- (instancetype)init
{
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    //defaults
    _timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    _size = (CGSize){40.0, 40.0};
    self.tintColor = [UIColor grayColor];
    
    [self.layer addSublayer:self.progressLayer];
}

+ (instancetype)sharedSpinner
{
    static dispatch_once_t pred = 0;
    __strong static CommonSpinner *_sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

+ (void)showWithTaregt:(id)target completion:(CommonSpinnerShowCompletionHandler)completion
{
    //hides the old one
    [CommonSpinner hideWithCompletion:^{
        
        //shows the new one
        CommonSpinner *sharedSpinner = [CommonSpinner sharedSpinner];
        sharedSpinner.translatesAutoresizingMaskIntoConstraints = NO;
        sharedSpinner.target = target;
        sharedSpinner.showCompetion = completion;
        
        if (!target) {
            NSLog(@"Warning: please provide valid target for common progress");
            return;
        }
        
        //use NSAutoLayout to position in target view
        UIView *targetView = nil;
        if ([target isKindOfClass:[UIViewController class]]) {
            targetView = ((UIViewController *)target).view;
            [targetView addSubview:sharedSpinner];
            [targetView addConstraint:[NSLayoutConstraint constraintWithItem:sharedSpinner
                                                                   attribute:NSLayoutAttributeWidth
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                                  multiplier:1
                                                                    constant:[CommonSpinner sharedSpinner].size.width]];
            [targetView addConstraint:[NSLayoutConstraint constraintWithItem:sharedSpinner
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                                  multiplier:1
                                                                    constant:[CommonSpinner sharedSpinner].size.height]];
            [targetView addConstraint:[NSLayoutConstraint constraintWithItem:sharedSpinner
                                                                   attribute:NSLayoutAttributeCenterX
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:[sharedSpinner superview]
                                                                   attribute:NSLayoutAttributeCenterX
                                                                  multiplier:1
                                                                    constant:0]];
            [targetView addConstraint:[NSLayoutConstraint constraintWithItem:sharedSpinner
                                                                   attribute:NSLayoutAttributeCenterY
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:[sharedSpinner superview]
                                                                   attribute:NSLayoutAttributeCenterY
                                                                  multiplier:1
                                                                    constant:0]];
            
        }
        
        [sharedSpinner startAnimating];
    }];
}

+ (void)hideWithCompletion:(CommonSpinnerHideCompletionHandler)completion;
{
    [CommonSpinner sharedSpinner].hideCompetion = completion;
    [[CommonSpinner sharedSpinner] stopAnimating];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.progressLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    [self updatePath];
}

- (void)tintColorDidChange
{
    [super tintColorDidChange];
    
    self.progressLayer.strokeColor = self.tintColor.CGColor;
}

- (void)startAnimating
{
    if (!self.isAnimating) {
        CABasicAnimation *animation = [CABasicAnimation animation];
        animation.keyPath = @"transform.rotation";
        animation.duration = 1.0f;
        animation.fromValue = @(0.0f);
        animation.toValue = @(2 * M_PI);
        animation.repeatCount = INFINITY;
        animation.timingFunction = self.timingFunction;
        
        [self.progressLayer addAnimation:animation forKey:kLLARingSpinnerAnimationKey];
        self.isAnimating = true;
        
        if (self.hidesWhenStopped) {
            self.hidden = NO;
        }
    }
}

- (void)stopAnimating
{
    if (self.isAnimating) {
        [self.progressLayer removeAnimationForKey:kLLARingSpinnerAnimationKey];
        self.isAnimating = false;
        
        if (self.hidesWhenStopped) {
            self.hidden = YES;
        }
    }
    
    //calling completion done in any case
    if (self.hideCompetion) self.hideCompetion();
}

#pragma mark - Private

- (void)updatePath
{
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGFloat radius = MIN(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2) - self.progressLayer.lineWidth / 2;
    CGFloat startAngle = (CGFloat)(-M_PI_4);
    CGFloat endAngle = (CGFloat)(3 * M_PI_2);
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    self.progressLayer.path = path.CGPath;
}

#pragma mark - Properties

- (CAShapeLayer *)progressLayer
{
    if (!_progressLayer) {
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.strokeColor = self.tintColor.CGColor;
        _progressLayer.fillColor = nil;
        _progressLayer.lineWidth = 1.5f;
    }
    return _progressLayer;
}

- (BOOL)isAnimating
{
    return _isAnimating;
}

- (CGFloat)lineWidth
{
    return self.progressLayer.lineWidth;
}

- (void)setLineWidth:(CGFloat)lineWidth
{
    self.progressLayer.lineWidth = lineWidth;
    [self updatePath];
}

- (void)setHidesWhenStopped:(BOOL)hidesWhenStopped
{
    _hidesWhenStopped = hidesWhenStopped;
    self.hidden = !self.isAnimating && hidesWhenStopped;
}

@end
