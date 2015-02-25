//  Created by Lukas Lipka 05/04/14.
//  Modified by Karen Lusinyan on 30/01/15.

#import "CommonSpinner.h"
#import "NetworkUtils.h"

#define kMaxWidth 300.0f
#define kOffset 5.0f

NSString * const kCommonSpinnerKeyTintColor     = @"kCommonSpinnerKeyTintColor";
NSString * const kCommonSpinnerKeySize          = @"kCommonSpinnerKeySize";
NSString * const kCommonSpinnerKeyLineWidth     = @"kCommonSpinnerKeyLineWidth";

static NSString *kLLARingSpinnerAnimationKey = @"llaringspinnerview.rotation";

//TODO::
static NSMutableDictionary *appearance = nil;

@interface CommonSpinner ()

@property (readwrite, nonatomic, strong) NSString *titleFont;
@property (readwrite, nonatomic, assign) CGFloat  titleFontSize;
@property (readwrite, nonatomic, strong) CATextLayer *titleLayer;
@property (readwrite, nonatomic, strong) CAShapeLayer *progressLayer;
@property (readwrite, nonatomic, assign) BOOL isAnimating;
@property (readwrite, nonatomic, getter=isTitleOnly) BOOL titleOnly;
@property (readwrite, nonatomic, assign) id target;

//bg execution
@property (readwrite, nonatomic, assign)  UIBackgroundTaskIdentifier bgTask;

@property (readwrite, nonatomic, copy) CommonSpinnerShowCompletionHandler showCompetion;
@property (readwrite, nonatomic, copy) CommonSpinnerHideCompletionHandler hideCompetion;

@end

@implementation CommonSpinner
@synthesize lineWidth = _lineWidth;
@synthesize isAnimating = _isAnimating;

- (void)dealloc
{
    [self removeObservers];
}

- (instancetype)init
{
    if (self = [super init]) {
        [self initialize];
        [self addObservers];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initialize];
        [self addObservers];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
        [self addObservers];
    }
    return self;
}

- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
}

- (void)initialize
{
    //-----------------SETUP DEFAULTS-----------------//
    _hidesWhenStopped = NO;
    _runInBackgroud = YES;
    _networkActivityIndicatorVisible = YES;
    _timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    _size = (CGSize){20.0f, 20.0f};
    _lineWidth = 1.5f;
    
    _titleFont = @"HelveticaNeue-Light";
    _titleFontSize = 20.0f;
    _title = nil;

    //tint color setups separately
    self.tintColor = [UIColor grayColor];
    
    [self.layer addSublayer:self.progressLayer];
    [self.layer addSublayer:self.titleLayer];
}

+ (instancetype)instance
{
    return [[self alloc] init];
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

#pragma mark -
#pragma mark static configuration

+ (void)setTintColor:(UIColor *)tintColor
{
    [CommonSpinner sharedSpinner].tintColor = tintColor;
}

+ (void)setTitle:(NSString *)title
{
    [CommonSpinner sharedSpinner].title = title;
    [CommonSpinner sharedSpinner].progressLayer.hidden = NO;
    [[CommonSpinner sharedSpinner] layoutSubviews];
}

+ (void)setTitleOnly:(NSString *)title
{
    [CommonSpinner sharedSpinner].title = title;
    [CommonSpinner sharedSpinner].progressLayer.hidden = YES;
    [[CommonSpinner sharedSpinner] layoutSubviews];
}

+ (void)setHidesWhenStopped:(BOOL)hidesWhenStopped
{
    [CommonSpinner sharedSpinner].hidesWhenStopped = hidesWhenStopped;
}

+ (void)setRunInBackground:(BOOL)runInBackgroud
{
    [CommonSpinner sharedSpinner].runInBackgroud = runInBackgroud;
}

+ (void)setNetworkActivityIndicatorVisible:(BOOL)networkActivityIndicatorVisible
{
    [CommonSpinner sharedSpinner].networkActivityIndicatorVisible = networkActivityIndicatorVisible;
}

+ (void)setTimingFunction:(CAMediaTimingFunction *)timingFunction
{
    [CommonSpinner sharedSpinner].timingFunction = timingFunction;
}

+ (void)setSize:(CGSize)size
{
    [CommonSpinner sharedSpinner].size = size;
}

+ (void)setLineWidth:(CGFloat)lineWidth
{
    [CommonSpinner sharedSpinner].lineWidth = lineWidth;
}

+ (BOOL)isAnimating
{
   return [CommonSpinner sharedSpinner].isAnimating;
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
        sharedSpinner.progressLayer.hidden = NO;
        
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
            CGFloat offset = 0;
            if ([CommonSpinner sharedSpinner].title) {
                offset = -([CommonSpinner sharedSpinner].titleFontSize+kOffset);
            }
            [targetView addConstraint:[NSLayoutConstraint constraintWithItem:sharedSpinner
                                                                   attribute:NSLayoutAttributeCenterY
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:[sharedSpinner superview]
                                                                   attribute:NSLayoutAttributeCenterY
                                                                  multiplier:1
                                                                    constant:offset]];
            
        }
        
        UIApplication *application = [UIApplication sharedApplication];
        [CommonSpinner sharedSpinner].bgTask = [application beginBackgroundTaskWithName:@"bgTask" expirationHandler:^{
            // Clean up any unfinished task business by marking where you
            // stopped or ending the task outright.
            [application endBackgroundTask:[CommonSpinner sharedSpinner].bgTask];
            [CommonSpinner sharedSpinner].bgTask = UIBackgroundTaskInvalid;
        }];
        
        // Start the long-running task and return immediately.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [sharedSpinner startAnimating];
            });
            [application endBackgroundTask:[CommonSpinner sharedSpinner].bgTask];
            [CommonSpinner sharedSpinner].bgTask = UIBackgroundTaskInvalid;
        });
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
    
    /*-----LABEL----*/
    UIFont *font = [UIFont fontWithName:self.titleFont size:self.titleFontSize];
    CGSize size = [self.titleLayer.string sizeWithAttributes:@{NSFontAttributeName : font}];
    self.titleLayer.frame = CGRectMake(0, 0, MIN(size.width+kOffset, kMaxWidth), size.height+kOffset);
    self.titleLayer.position = (CGPoint){CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)};
    
    /*-----SPINNER----*/
    self.progressLayer.frame = CGRectMake(0, CGRectGetHeight(self.titleLayer.bounds), CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    
    [self updatePath];
    [self updateTitle];
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
        animation.delegate = self;
        
        [self.progressLayer addAnimation:animation forKey:kLLARingSpinnerAnimationKey];
        self.isAnimating = true;
        
        if (self.networkActivityIndicatorVisible) {
            [NetworkUtils setNetworkActivityIndicatorVisible:YES];
        }

        if (self.hidesWhenStopped) {
            self.hidden = NO;
        }
    }
}

- (void)animationDidStart:(CAAnimation *)anim
{
    if (anim == [self.progressLayer animationForKey:kLLARingSpinnerAnimationKey]) {
        if (self.showCompetion) self.showCompetion();
    }
}

- (void)stopAnimating
{
    if (self.isAnimating) {
        [self.progressLayer removeAnimationForKey:kLLARingSpinnerAnimationKey];
        self.isAnimating = false;
        
        if (self.networkActivityIndicatorVisible) {
            [NetworkUtils setNetworkActivityIndicatorVisible:NO];
        }

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

- (void)updateTitle
{
    self.titleLayer.font = (__bridge CFTypeRef)(self.titleFont);
    self.titleLayer.fontSize = self.titleFontSize;
    self.titleLayer.foregroundColor = self.tintColor.CGColor;
    self.titleLayer.string = self.title;
}

#pragma mark - Properties

- (CATextLayer *)titleLayer
{
    if (!_titleLayer) {
        _titleLayer = [CATextLayer layer];
        _titleLayer.font = (__bridge CFTypeRef)(self.titleFont);
        _titleLayer.fontSize = self.titleFontSize;
        _titleLayer.alignmentMode = kCAAlignmentCenter;
        _titleLayer.foregroundColor = [UIColor darkTextColor].CGColor;
        _titleLayer.contentsScale = [UIScreen mainScreen].scale;
    }
    return _titleLayer;
}


- (CAShapeLayer *)progressLayer
{
    if (!_progressLayer) {
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.strokeColor = self.tintColor.CGColor;
        _progressLayer.fillColor = nil;
        _progressLayer.lineWidth = self.lineWidth;
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

#pragma mark -
#pragma mark NSNotificationCenter

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    if (self.runInBackgroud && self.isAnimating) {
        [self stopAnimating];
        [self startAnimating];
    }
}

#pragma mark -
#pragma mark TODO list

+ (id)sharedAppearance
{
    if (!appearance) {
        appearance = [[NSMutableDictionary alloc] init];
    }
    return appearance;
}

@end
