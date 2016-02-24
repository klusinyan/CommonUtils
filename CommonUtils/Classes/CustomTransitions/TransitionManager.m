//  Created by Karen Lusinyan on 21/04/14.

#import "TransitionManager.h"

#define kAnimateCornerRadius 1

@interface TransitionManager ()

@property(readwrite, nonatomic, strong) id<UIViewControllerContextTransitioning> transitionContext;
@property(readwrite, nonatomic, strong) UIView *animatedView;

@end

@implementation TransitionManager

- (id)init
{
    self = [super init];
    if (self) {
        
        //setup default values
        self.animationDuration = 1;
        self.modalSize = (iPad) ? (CGSize){540.0f, 620.0f} : (CGSize){200.0f, 300.0f};
        self.modalStartColor = [UIColor colorWithWhite:0.8 alpha:1];
        self.modalEndColor = [UIColor colorWithWhite:0.8 alpha:1];
        self.sourceCornerRadius = 20;
        self.animatedCornerRadius = NO;
    }
    return self;
}

//Define the transition duration
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return self.animationDuration;
}

//Animate transition either present or dismiss
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    if (self.presenting) {
        [self
         presentAddEntryViewController:toViewController
         overParentViewController:fromViewController
         usingContainerView:containerView
         transitionContext:transitionContext];
    }
    else {
        [self
         dismissAddEntryViewController:fromViewController
         fromParentViewController:toViewController
         usingContainerView:containerView
         transitionContext:transitionContext];
    }
}

- (void)presentAddEntryViewController:(UIViewController *)addEntryController
             overParentViewController:(UIViewController *)parentController
                   usingContainerView:(UIView *)containerView
                    transitionContext: (id<UIViewControllerContextTransitioning>)transitionContext
{
    [containerView addSubview:parentController.view];
    [containerView addSubview:addEntryController.view];
    
    UIView *addEntryView = addEntryController.view;
    UIView *parentView = parentController.view;
    CGPoint center = parentView.center;
    
    //configure addEntryView
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        addEntryView.frame = CGRectMake(0.0, 0.0, self.modalSize.width, self.modalSize.height);
    }
    else {
        addEntryView.frame = CGRectMake(0.0, 0.0, self.modalSize.height, self.modalSize.width);
    }

    addEntryView.center = center;
    addEntryView.alpha = 0;

    //first convert self.source.frame to parentView
    CGRect rect = [parentView convertRect:self.source.frame fromView:self.source];
    //DebugLog(@"step 1 %@", NSStringFromCGRect(rect));
    rect.origin.x -= 8;
    rect.origin.y -= 8;
    
    //then adjust rect by converting from parentView to containerView
    rect = [containerView convertRect:rect fromView:parentView];
    //DebugLog(@"step 2 %@", NSStringFromCGRect(rect));

    self.animatedView = [[UIView alloc] init];
    self.animatedView.frame = rect;
    self.animatedView.alpha = 1;
    if (self.animatedCornerRadius) {
        self.animatedView.layer.cornerRadius = self.sourceCornerRadius;
    }
    self.animatedView.layer.zPosition = 200;
    self.animatedView.backgroundColor = self.modalStartColor;
    self.animatedView.layer.transform = CATransform3DIdentity;
    [containerView addSubview:self.animatedView];
    
    __block float dx, dy;
    dx = center.x - CGRectGetMidX(rect);
    dy = center.y - CGRectGetMidY(rect);

    __block float sx, sy;
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        sx = self.modalSize.width/rect.size.width;
        sy = self.modalSize.height/rect.size.height;
    }
    else {
        sx = self.modalSize.height/rect.size.width;
        sy = self.modalSize.width/rect.size.height;
    }

    // start the animation
    [UIView animateKeyframesWithDuration:self.animationDuration
                                   delay:0
                                 options:UIViewKeyframeAnimationOptionCalculationModeCubicPaced
                              animations:^{
                                  
                                  //start of animation
                                  parentView.userInteractionEnabled = NO;
                                  
                                  if (self.animatedCornerRadius) {
                                      //change source's corner radius animated
                                      [self changeCornerRadius:self.animatedView
                                                     fromValue:self.sourceCornerRadius
                                                       toValue:0
                                                      duration:0.5];
                                  }
                                  
                                  [UIView addKeyframeWithRelativeStartTime:0
                                                          relativeDuration:1
                                                                animations:^{
                                                                    
                                                                    double m34 = 1.0/500;
                                                                    if (orientation == UIInterfaceOrientationPortrait ||
                                                                        orientation == UIInterfaceOrientationLandscapeLeft) {
                                                                        m34 = -m34;
                                                                    }
                                                                    else if (orientation == UIInterfaceOrientationPortraitUpsideDown ||
                                                                             orientation == UIInterfaceOrientationLandscapeRight) {
                                                                        m34 = m34;
                                                                    }
                                                                    
                                                                    //create concat animations
                                                                    CATransform3D tRotate = self.animatedView.layer.transform;
                                                                    tRotate.m34 = m34;
                                                                    BOOL rotateAxis = UIInterfaceOrientationIsPortrait(orientation);
                                                                    tRotate = CATransform3DRotate(tRotate, M_PI, !rotateAxis, rotateAxis, 0);
                                                                    
                                                                    CATransform3D tTranslate = self.animatedView.layer.transform;
                                                                    tTranslate = CATransform3DTranslate(tTranslate, dx, dy, 0);
                                                                    
                                                                    CATransform3D tScale = self.animatedView.layer.transform;
                                                                    tScale = CATransform3DScale(tScale, sx, sy, 1);
                                                                    
                                                                    CATransform3D tRotTtans = CATransform3DConcat(tRotate, tTranslate);
                                                                    CATransform3D tScaleRotTrans = CATransform3DConcat(tScale, tRotTtans);
                                                                    self.animatedView.layer.transform = tScaleRotTrans;
                                                                    
                                                                    //color transition
                                                                    self.animatedView.backgroundColor = self.modalEndColor;
                                                                }];
                              } completion:^(BOOL finished) {
                                  //show modal view
                                  addEntryView.alpha = 1.0;

                                  //hide and remove animated view
                                  self.animatedView.alpha = 0;
                                  [self.animatedView removeFromSuperview];
                                  
                                  //complete transition
                                  [transitionContext completeTransition:YES];
                              }];
}

- (void)dismissAddEntryViewController:(UIViewController *)addEntryController
             fromParentViewController:(UIViewController *)parentController
                   usingContainerView:(UIView *)containerView
                    transitionContext: (id<UIViewControllerContextTransitioning>)transitionContext
{
    [containerView addSubview:parentController.view];
    [containerView addSubview:addEntryController.view];
    
    UIView *addEntryView = addEntryController.view;
    UIView *parentView = parentController.view;
    CGPoint center = parentView.center;
    
    //configure addEntryView
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        addEntryView.frame = CGRectMake(0.0, 0.0, self.modalSize.width, self.modalSize.height);
    }
    else {
        addEntryView.frame = CGRectMake(0.0, 0.0, self.modalSize.height, self.modalSize.width);
    }
    
    addEntryView.center = center;
    addEntryView.alpha = 0;
    
    //first convert self.source.frame to parentView
    CGRect rect = [parentView convertRect:self.source.frame fromView:self.source];
    //DebugLog(@"step 1 %@", NSStringFromCGRect(rect));
    rect.origin.x -= 8;
    rect.origin.y -= 8;
    
    //then adjust rect by converting from parentView to containerView
    rect = [containerView convertRect:rect fromView:parentView];
    //DebugLog(@"step 2 %@", NSStringFromCGRect(rect));
    
    self.animatedView = [[UIView alloc] init];
    self.animatedView.frame = addEntryView.frame;
    self.animatedView.alpha = 1;
    if (self.animatedCornerRadius) {
        self.animatedView.layer.cornerRadius = 0;
    }
    self.animatedView.layer.zPosition = 200;
    self.animatedView.backgroundColor = self.modalEndColor;
    self.animatedView.layer.transform = CATransform3DIdentity;
    [containerView addSubview:self.animatedView];
    
    __block float dx, dy;
    dx = center.x - CGRectGetMidX(rect);
    dy = center.y - CGRectGetMidY(rect);
    
    __block float sx, sy;
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        sx = rect.size.width/self.modalSize.width;
        sy = rect.size.height/self.modalSize.height;
    }
    else {
        sx = rect.size.width/self.modalSize.height;
        sy = rect.size.height/self.modalSize.width;
    }

    [UIView animateKeyframesWithDuration:self.animationDuration
                                   delay:0
                                 options:UIViewKeyframeAnimationOptionCalculationModeCubicPaced
                              animations:^{
                                  
                                  [UIView addKeyframeWithRelativeStartTime:0
                                                          relativeDuration:1
                                                                animations:^{
                                                                    
                                                                    double m34 = 1.0/500;
                                                                    if (orientation == UIInterfaceOrientationPortrait ||
                                                                        orientation == UIInterfaceOrientationLandscapeLeft) {
                                                                        m34 = m34;
                                                                    }
                                                                    else if (orientation == UIInterfaceOrientationPortraitUpsideDown ||
                                                                             orientation == UIInterfaceOrientationLandscapeRight) {
                                                                        m34 = -m34;
                                                                    }
                                                                    
                                                                    //create concat animations
                                                                    CATransform3D tRotate = self.animatedView.layer.transform;
                                                                    tRotate.m34 = m34;
                                                                    BOOL rotateAxis = UIInterfaceOrientationIsPortrait(orientation);
                                                                    tRotate = CATransform3DRotate(tRotate, M_PI, !rotateAxis, rotateAxis, 0);
                                                                    
                                                                    CATransform3D tTranslate = self.animatedView.layer.transform;
                                                                    tTranslate = CATransform3DTranslate(tTranslate, -dx, -dy, 0);
                                                                    
                                                                    CATransform3D tScale = self.animatedView.layer.transform;
                                                                    tScale = CATransform3DScale(tScale, sx, sy, 1);
                                                                    
                                                                    CATransform3D tRotTtans = CATransform3DConcat(tRotate, tTranslate);
                                                                    CATransform3D tScaleRotTrans = CATransform3DConcat(tScale, tRotTtans);
                                                                    self.animatedView.layer.transform = tScaleRotTrans;
                                                                    
                                                                    //color transition
                                                                    self.animatedView.backgroundColor = self.modalStartColor;
                                                                }];
                              } completion:^(BOOL finished) {
                                  
                                  //hide and remove animated view
                                  self.animatedView.alpha = 0;
                                  [self.animatedView removeFromSuperview];

                                  [UIView animateWithDuration:0.3
                                                   animations:^{
                                                       
                                                       //make source view's corner radius to 0
                                                       self.source.layer.cornerRadius = 0;
                                                       
                                                       //change source's corner raidus to previous value
                                                       [self changeCornerRadius:self.source
                                                                      fromValue:0
                                                                        toValue:self.sourceCornerRadius
                                                                       duration:1];
                                                   } completion:^(BOOL finished) {
                                                       
                                                       [transitionContext completeTransition:YES];
                                                       
                                                       //end of animation
                                                       parentView.userInteractionEnabled = YES;
                                                   }];
                              }];
}

//Aimate corner raidus
- (void)changeCornerRadius:(UIView *)view fromValue:(float)fromValue toValue:(float)toValue duration:(NSTimeInterval)duration
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.fromValue = [NSNumber numberWithFloat:fromValue];
    animation.toValue = [NSNumber numberWithFloat:toValue];
    animation.duration = duration;
    [view.layer setCornerRadius:toValue];
    [view.layer addAnimation:animation forKey:@"cornerRadius"];
}

//not used
- (CATransform3D)firstTransform
{
    CATransform3D t1 = CATransform3DIdentity;
    t1.m34 = 1.0/-900;
    t1 = CATransform3DScale(t1, 0.95, 0.95, 1);
    t1 = CATransform3DRotate(t1, 15.0f*M_PI/180.0f, 1, 0, 0);
    
    return t1;
}

//not used
- (CATransform3D)secondTransformWithView:(UIView*)view
{
    CATransform3D t2 = CATransform3DIdentity;
    t2.m34 = [self firstTransform].m34;
    t2 = CATransform3DTranslate(t2, 0, view.frame.size.height*-0.08, 0);
    t2 = CATransform3DScale(t2, 0.8, 0.8, 1);
    
    return t2;
}

@end
