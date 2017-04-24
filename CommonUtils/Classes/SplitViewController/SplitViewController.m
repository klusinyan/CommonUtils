//  Created by Adrian Bardasu on 9/11/11.
//  Modified by Karen Lusinyan on 5/14/13.

NSString * const NotificationMenuWillStartOpening = @"NotificationMenuWillStartOpening";
NSString * const NotificationMenuWillStartClosing = @"NotificationMenuWillStartClosing";
NSString * const NotificationMenuDidFinishOpening = @"NotificationMenuDidFinishOpening";
NSString * const NotificationMenuDidFinishClosing = @"NotificationMenuDidFinishClosing";

#import "SplitViewController.h"
#import <QuartzCore/QuartzCore.h>

#define SAFE_DEL(x) { [x release]; x = nil; }

@interface SplitViewController ()
<
CAAnimationDelegate
>

{
    UIBarButtonItem *open;
    UIBarButtonItem *close;
    UIViewController *masterController;
    UIViewController *detailController;
    UIGestureRecognizer *panGesture;
}

@property (nonatomic, retain) UINavigationController *masterNavigationController;
@property (nonatomic, retain) UINavigationController *detailNavigationController;

@property (nonatomic, retain) UIView *masterView;
@property (nonatomic, retain) UIView *detailView;
@property (nonatomic, retain) UIView *separatorView;

@end

@implementation SplitViewController

@synthesize masterNavigationController;
@synthesize detailNavigationController;
@synthesize masterView;
@synthesize detailView;
@synthesize menuState;
@synthesize menuMode;
@synthesize imageCloseMenu;
@synthesize imageOpenMenu;

- (id) init
{
    if (!(self = [super init])) return nil;
    
    self.shadowEnabled = YES;
    self.menuShadow = YES;
    self.resizeDetail = NO;
    self.menuWidth = 320.0;
    self.menuOverlay = 3.0;
    self.shadowRadius = 10.0;
    self.shadowOpacity = 0.75;
    self.shadowColor = [UIColor blackColor];
    self.openningAnimationDuration = 0.3;
    self.closingAnimationDuration = 0.1;
    self.openningTimingFunctionName = kCAMediaTimingFunctionEaseOut;
    self.closingTimingFunctionName = kCAMediaTimingFunctionEaseOut;
    self.menuMode = MenuModeHiddenInPortrait;
    self.menuState = MenuStateOpen;
    
    self.imageCloseMenu = [UIImage imageNamed:@"ResourceBundle.bundle/Split.bundle/ico_close_nav_bar"];
    self.imageOpenMenu = [UIImage imageNamed:@"ResourceBundle.bundle/Split.bundle/ico_open_nav_bar"];
    
    return self;
}

- (void) dealloc
{
#if !__has_feature(objc_arc)
    SAFE_DEL(masterNavigationController);
    SAFE_DEL(detailNavigationController);
    SAFE_DEL(masterView);
    SAFE_DEL(detailView);
    [super dealloc];
#endif
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (UIInterfaceOrientation)statusBarOrientation
{
    return [[UIApplication sharedApplication] statusBarOrientation];
}

#pragma mark - 
#pragma mark public methods

- (void) addMasterController:(UIViewController*)controller animated:(BOOL)animated
{
#if !__has_feature(objc_arc)
    SAFE_DEL(masterNavigationController);
#endif

    masterNavigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    masterNavigationController.navigationBar.translucent = NO;
    masterNavigationController.navigationBar.opaque = YES;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        masterNavigationController.navigationBar.tintColor = [UIColor blueColor];
    }

    if (menuMode == MenuModeHiddenInPortrait || menuMode == MenuModeHidden) {
        close = [[UIBarButtonItem alloc] initWithImage:imageCloseMenu
                                                 style:UIBarButtonItemStyleDone
                                                target:self
                                                action:@selector(revealMenu:)];
        
        if (menuMode == MenuModeHiddenInPortrait || menuMode == MenuModeHidden) {
            controller.navigationItem.rightBarButtonItem = close;
        }
        
        panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(toggleSlideBar:)];
        panGesture.cancelsTouchesInView = YES;
        panGesture.delaysTouchesBegan = YES;
        [masterNavigationController.navigationBar addGestureRecognizer:panGesture];
        
#if !__has_feature(objc_arc)
        [panGesture autorelease];
#endif
    }
    
    masterController = controller;
    masterNavigationController.view.frame = masterView.bounds;
    controller.view.frame = masterNavigationController.view.bounds;
    [masterView addSubview:masterNavigationController.view];
}

- (void) addDetailController:(UIViewController *)controller animated:(BOOL)animated
{
#if !__has_feature(objc_arc)
    SAFE_DEL(detailNavigationController);
#endif
    
    detailNavigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    detailNavigationController.navigationBar.translucent = NO;
    detailNavigationController.navigationBar.opaque = YES;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        detailNavigationController.navigationBar.tintColor = [UIColor blueColor];
    }

    if (menuMode == MenuModeHiddenInPortrait || menuMode == MenuModeHidden) {
        open = [[UIBarButtonItem alloc] initWithImage:imageOpenMenu
                                                style:UIBarButtonItemStyleDone
                                               target:self
                                               action:@selector(revealMenu:)];
        
        if (menuMode == MenuModeHiddenInPortrait || menuMode == MenuModeHidden) {
            controller.navigationItem.leftBarButtonItem = open;
        }
    }
    
    detailController = controller;
    detailNavigationController.view.frame = detailView.bounds;
    controller.view.frame = detailNavigationController.view.bounds;
    [detailView addSubview:detailNavigationController.view];
}

- (void) addChildToMasterController:(UIViewController *)childController
{
    [masterController addChildViewController:childController];
    childController.view.frame = masterController.view.frame;
    [masterController.view addSubview:childController.view];
    [childController didMoveToParentViewController:masterController];
}

- (void) addChildToDetailController:(UIViewController *)childController
{
    [detailController addChildViewController:childController];
    childController.view.frame = detailController.view.frame;
    [detailController.view addSubview:childController.view];
    [childController didMoveToParentViewController:detailController];
}

- (void) removeChildFromParentController:(UIViewController *)childController
{
    [[childController navigationController] popToRootViewControllerAnimated:YES];
    [childController willMoveToParentViewController:nil];
    [childController.view removeFromSuperview];
    [childController removeFromParentViewController];
}

- (MenuMode) menuMode
{
    return menuMode;
}

- (void) openMenu:(BOOL)animated
{
    if (animated) {
        [self openMenu];
    }
    else {
        menuState = MenuStateOpen;
        masterView.hidden = NO;
        [self configureFramesForMenuState:MenuStateOpen];
        [self changeRevealButtonState:RevealButtonStateOpenHidden];
        [self changeRevealButtonState:RevealButtonStateCloseShown];
    }
}

- (void) closeMenu:(BOOL)animated
{
    if (animated) {
        [self closeMenu];
    }
    else {
        menuState = MenuStateClosed;
        masterView.hidden = YES;
        [self configureFramesForMenuState:MenuStateClosed];
        [self changeRevealButtonState:RevealButtonStateOpenShown];
        [self changeRevealButtonState:RevealButtonStateCloseHidden];
    }
}

- (void) changeRevealButtonState:(RevealButtonState)state
{
    switch (state) {
        case RevealButtonStateOpenShown:
            detailController.navigationItem.leftBarButtonItem = open;
            break;
        case RevealButtonStateOpenHidden:
            detailController.navigationItem.leftBarButtonItem = nil;
            break;
        case RevealButtonStateCloseShown:
            masterController.navigationItem.rightBarButtonItem = close;
            break;
        case RevealButtonStateCloseHidden:
            masterController.navigationItem.rightBarButtonItem = nil;
            break;
            
        default:
            break;
    }
}

#pragma mark - 
#pragma mark Utiliy methods

- (void) configureMenuState
{
    if (menuMode == MenuModeHiddenInPortrait) {
        if (UIInterfaceOrientationIsPortrait([self statusBarOrientation])) {
            menuState = MenuStateClosed;
        }
        else if (UIInterfaceOrientationIsLandscape([self statusBarOrientation])) {
            menuState = MenuStateOpen;
        }
    }
    else if (menuMode == MenuModeHidden) {
        menuState = MenuStateClosed;
    }
    else if (menuMode == MenuModeShownAlways) {
        menuState = MenuStateOpen;
    }
}

- (void) configureLayoutForMenuMode:(MenuMode)_menuMode
{
    if (_menuMode == MenuModeHiddenInPortrait) {
        if (UIInterfaceOrientationIsPortrait([self statusBarOrientation])) {
            masterView.hidden = YES;
            [self changeRevealButtonState:RevealButtonStateOpenShown];
            [self changeRevealButtonState:RevealButtonStateCloseShown];
        }
        else if (UIInterfaceOrientationIsLandscape([self statusBarOrientation])) {
            masterView.hidden = NO;
            [self changeRevealButtonState:RevealButtonStateOpenHidden];
            [self changeRevealButtonState:RevealButtonStateCloseHidden];
        }
    }
    else if (_menuMode == MenuModeHidden) {
        masterView.hidden = YES;
        [self changeRevealButtonState:RevealButtonStateOpenHidden];
        [self changeRevealButtonState:RevealButtonStateCloseHidden];
    }
    else if (_menuMode == MenuModeShownAlways) {
        masterView.hidden = NO;
        [self changeRevealButtonState:RevealButtonStateOpenHidden];
        [self changeRevealButtonState:RevealButtonStateCloseHidden];
    }
}

- (void) configureFramesForMenuState:(MenuState)state
{
    CGRect bounds = self.view.bounds;
    if (state == MenuStateOpen) {
        masterView.frame = (CGRect){0, 0, _menuWidth, bounds.size.height};
        detailView.frame = (CGRect){_menuWidth, 0, bounds.size.width - _menuWidth, bounds.size.height};
    }
    else if (state == MenuStateClosed) {
        masterView.frame = (CGRect){-_menuWidth, 0, _menuWidth, bounds.size.height};
        detailView.frame = (CGRect){0, 0, bounds.size.width, bounds.size.height};
    }
}

- (void) configureFrames
{
    if (menuMode == MenuModeHiddenInPortrait) {
        if (UIInterfaceOrientationIsPortrait([self statusBarOrientation])) {
            [self configureFramesForMenuState:MenuStateClosed];
        }
        else if (UIInterfaceOrientationIsLandscape([self statusBarOrientation])) {
            [self configureFramesForMenuState:MenuStateOpen];
        }
    }
    else if (menuMode == MenuModeHidden) {
        [self configureFramesForMenuState:menuState];
    }
    else if (menuMode == MenuModeShownAlways) {
        [self configureFramesForMenuState:MenuStateOpen];
    }
}

- (void) configureLayout
{
    if (menuMode == MenuModeHiddenInPortrait) {
        [self configureLayoutForMenuMode:MenuModeHiddenInPortrait];
    }
    
    [self configureFrames];
}

#pragma mark - View lifecycle

- (void) loadView
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    view.autoresizesSubviews = YES;
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view = view;
    
#if !__has_feature(objc_arc)
    [view autorelease];
#endif

}

- (void) viewDidLoad
{
    [super viewDidLoad];

    masterView = [[UIView alloc] init];
    masterView.backgroundColor = [UIColor clearColor];
    masterView.autoresizesSubviews = YES;
    masterView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    detailView = [[UIView alloc] init];
    detailView.backgroundColor = [UIColor clearColor];
    detailView.autoresizesSubviews = YES;
    detailView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:detailView];
    [self.view addSubview:masterView];
    
    if (!_menuShadow) {
        [self.view bringSubviewToFront:detailView];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [self configureLayout];
    [self configureMenuState];
    [self configureLayoutForMenuMode:menuMode];
   
    if (self.shadowEnabled) [self drawMenuShadows];

	[masterNavigationController viewWillAppear:animated];
	[detailNavigationController viewWillAppear:animated];
	[super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated
{
	[masterNavigationController viewDidAppear:animated];
	[detailNavigationController viewDidAppear:animated];
	[super viewDidAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
	[masterNavigationController viewWillDisappear:animated];
	[detailNavigationController viewWillDisappear:animated];
	[super viewWillDisappear:animated];
}

- (void) viewDidDisappear:(BOOL)animated
{
	[masterNavigationController viewDidDisappear:animated];
	[detailNavigationController viewDidDisappear:animated];
	[super viewDidDisappear:animated];
}

- (BOOL) shouldAutorotate
{
    // Return YES for supported orientations
    return YES;
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[masterNavigationController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	[detailNavigationController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    //if (self.shadowEnabled) [self drawMenuShadows];

	[masterNavigationController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	[detailNavigationController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // redraw shadow
    CGPathRef oldCommentsContainerShadowPath = [self shadowedView].layer.shadowPath;
    
    if (oldCommentsContainerShadowPath)
        CFRetain(oldCommentsContainerShadowPath);
    
    //  Updates shadow path for the view
    [self shadowedView].layer.shadowPath = [UIBezierPath bezierPathWithRect:[self shadowedView].bounds].CGPath;
    
    if (oldCommentsContainerShadowPath) {
        [[self shadowedView].layer addAnimation:((^ {
            CABasicAnimation *transition = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
            transition.fromValue = (__bridge id)oldCommentsContainerShadowPath;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.duration = duration;
            return transition;
        })()) forKey:@"transition"];
        CFRelease(oldCommentsContainerShadowPath);
    }
    // redraw shadow

    if (menuMode == MenuModeHiddenInPortrait) {
        if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            
            if (menuState == MenuStateClosed) {
                [self openMenu];
            }
        }
        else if (toInterfaceOrientation == UIInterfaceOrientationPortrait ||
                 toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {

            if (menuState == MenuStateOpen) {
                [self closeMenu];
            }
        }
    
        [self configureLayout];
    }
        
	[masterNavigationController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
	[detailNavigationController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

#pragma mark -
#pragma Draw shadow

- (void) setShadowRadius:(CGFloat)shadowRadius
{
    _shadowRadius = shadowRadius;
    [self drawMenuShadows];
}

- (void) setShadowColor:(UIColor *)shadowColor
{
    _shadowColor = shadowColor;
    [self drawMenuShadows];
}

- (void) setShadowOpacity:(CGFloat)shadowOpacity
{
    _shadowOpacity = shadowOpacity;
    [self drawMenuShadows];
}

- (UIView *) shadowedView
{
    return (_menuShadow) ? masterView : detailView;
}

- (void) drawMenuShadows
{
    if(_shadowEnabled) {
        // we draw the shadow on the rootViewController, because it might not always be the uinavigationcontroller
        // i.e. it could be a uitabbarcontroller
        [self drawRootControllerShadowPath];
        [self shadowedView].layer.shadowOpacity = self.shadowOpacity;
        [self shadowedView].layer.shadowRadius = self.shadowRadius;
        [self shadowedView].layer.shadowColor = [self.shadowColor CGColor];
    }
}

// draw a shadow between the navigation controller and the menu
- (void) drawRootControllerShadowPath
{
    if(_shadowEnabled) {
        CGRect pathRect = [self shadowedView].bounds;
        [self shadowedView].layer.shadowPath = [UIBezierPath bezierPathWithRect:pathRect].CGPath;
    }
}

#pragma mark -
#pragma Reveal menu

- (void) openMenu
{
    menuState = MenuStateOpen;
    if (self.resizeDetail) {
        detailView.contentMode = UIViewContentModeRedraw;
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = detailView.frame;
            frame.origin.x = self.menuWidth-self.menuOverlay;
            if ([panGesture state] != UIGestureRecognizerStateEnded)
                frame.size.width -= (self.menuWidth-self.menuOverlay);
            else
                frame.size.width = self.view.bounds.size.width-self.menuWidth+self.menuOverlay;
            detailView.frame = frame;
            
            [self moveLayer:masterView.layer
                         to:CGPointMake(self.menuWidth/2, masterView.bounds.size.height/2)
          animationDuration:self.openningAnimationDuration
         timingFunctionName:self.openningTimingFunctionName];
            
        }];
    }
    else {
        [self moveLayer:masterView.layer
                     to:CGPointMake(self.menuWidth/2, masterView.bounds.size.height/2)
      animationDuration:self.openningAnimationDuration
     timingFunctionName:self.openningTimingFunctionName];
    }
}

- (void) closeMenu
{
    menuState = MenuStateClosed;    
    if (self.resizeDetail) {
        detailView.contentMode = UIViewContentModeRedraw;
        [UIView animateWithDuration:0.1 animations:^{
            CGRect frame = detailView.frame;
            frame.origin.x = 0;
            if ([panGesture state] != UIGestureRecognizerStateEnded)
                frame.size.width += self.menuWidth-self.menuOverlay;
            else
                frame.size.width = self.view.bounds.size.width;
            detailView.frame = frame;

            [self moveLayer:masterView.layer
                         to:CGPointMake(-self.menuWidth/2, masterView.bounds.size.height/2)
          animationDuration:self.closingAnimationDuration
         timingFunctionName:self.closingTimingFunctionName];
            
        }];
    }
    else {
        [self moveLayer:masterView.layer
                     to:CGPointMake(-self.menuWidth/2, masterView.bounds.size.height/2)
      animationDuration:self.closingAnimationDuration
     timingFunctionName:self.closingTimingFunctionName];
    }
}

- (void) bounceMenu
{
    if (menuMode == MenuModeHiddenInPortrait) {
        if (menuState == MenuStateOpen) {
            if (UIInterfaceOrientationIsPortrait([self statusBarOrientation])) {
                CABasicAnimation *bounceAnimation = [CABasicAnimation animationWithKeyPath:@"position.x"];
                bounceAnimation.duration = 0.2;
                bounceAnimation.fromValue = [NSNumber numberWithFloat:masterView.center.x];
                bounceAnimation.toValue = [NSNumber numberWithFloat:masterView.center.x - self.menuOverlay];
                bounceAnimation.repeatCount = 1;
                bounceAnimation.autoreverses = YES;
                bounceAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
                bounceAnimation.fillMode = kCAFillModeBackwards;
                [masterView.layer addAnimation:bounceAnimation forKey:@"bounceAnimation"];
            }
        }
    }
    else if (menuMode == MenuModeHidden) {
        CABasicAnimation *bounceAnimation = [CABasicAnimation animationWithKeyPath:@"position.x"];
        bounceAnimation.duration = 0.2;
        bounceAnimation.fromValue = [NSNumber numberWithFloat:masterView.center.x];
        bounceAnimation.toValue = [NSNumber numberWithFloat:masterView.center.x - self.menuOverlay];
        bounceAnimation.repeatCount = 1;
        bounceAnimation.autoreverses = YES;
        bounceAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        bounceAnimation.fillMode = kCAFillModeBackwards;
        [masterView.layer addAnimation:bounceAnimation forKey:@"bounceAnimation"];
    }
}

- (void) revealMenu:(id)sender
{
    if (menuMode == MenuModeHiddenInPortrait) {
        [masterView.layer removeAllAnimations];
        if (UIInterfaceOrientationIsPortrait([self statusBarOrientation])) {
            if (menuState == MenuStateClosed) {
                [self openMenu];
            }
            else if (menuState == MenuStateOpen) {
                [self closeMenu];
            }
        }
    }
    else if (menuMode == MenuModeHidden) {
        [masterView.layer removeAllAnimations];
        if (menuState == MenuStateClosed) {
            [self openMenu];
        }
        else if (menuState == MenuStateOpen) {
            [self closeMenu];
        }
    }
}

-(void) moveLayer:(CALayer*)layer
               to:(CGPoint)point
animationDuration:(NSTimeInterval)animationDuration
timingFunctionName:(NSString *)timingFunctionName
{
    // Prepare the animation from the current position to the new position
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.fromValue = [layer valueForKey:@"position"];
    
    // Mac OS X
    // NSValue/+valueWithPoint:(NSPoint)point is available on Mac OS X
    // NSValue/+valueWithCGPoint:(CGPoint)point is available on iOS
    // comment/uncomment the corresponding lines depending on which platform you're targeting
    
    // iOS
    animation.toValue = [NSValue valueWithCGPoint:point];
    
    // Specifies ease-out pacing.
    // An ease-out pacing causes the animation to begin quickly, and then slow as it completes.
    animation.timingFunction = [CAMediaTimingFunction functionWithName:timingFunctionName];
    
    // Set animation duration.
    animation.duration = animationDuration;
    // Update the layer's position so that the layer doesn't snap back when the animation completes.
    layer.position = point;
    
    animation.delegate = self;
    
    // Add the animation, overriding the implicit animation.
    [layer addAnimation:animation forKey:@"position"];
}

// not used
-(void) resizeLayer:(CALayer*)layer to:(CGSize)size
{
    // Prepare the animation from the old size to the new size
    CGRect oldBounds = layer.bounds;
    CGRect newBounds = oldBounds;
    newBounds.size = size;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    
    // NSValue/+valueWithRect:(NSRect)rect is available on Mac OS X
    // NSValue/+valueWithCGRect:(CGRect)rect is available on iOS
    // comment/uncomment the corresponding lines depending on which platform you're targeting
    
    // Mac OS X
    //animation.fromValue = [NSValue valueWithRect:NSRectFromCGRect(oldBounds)];
    //animation.toValue = [NSValue valueWithRect:NSRectFromCGRect(newBounds)];
    // iOS
    animation.fromValue = [NSValue valueWithCGRect:oldBounds];
    animation.toValue = [NSValue valueWithCGRect:newBounds];
    
    // Update the layer's bounds so the layer doesn't snap back when the animation completes.
    layer.bounds = newBounds;
    
    // Add the animation, overriding the implicit animation.
    [layer addAnimation:animation forKey:@"bounds"];
}

- (void) animationDidStart:(CAAnimation *)anim
{
    if (menuState == MenuStateOpen) {
        masterView.hidden = NO;

        if (menuMode == MenuModeHiddenInPortrait) {
            if (UIInterfaceOrientationIsPortrait([self statusBarOrientation])) {
                [self changeRevealButtonState:RevealButtonStateOpenHidden];
                [self changeRevealButtonState:RevealButtonStateCloseShown];
            }
        }
        else if (menuMode == MenuModeHidden) {
            [self changeRevealButtonState:RevealButtonStateOpenHidden];
            [self changeRevealButtonState:RevealButtonStateCloseShown];            
        }

        // Notify all observers when menu will start opening
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationMenuWillStartOpening
                                                            object:nil];
    }
    else if (menuState == MenuStateClosed) {
        
        if (menuMode == MenuModeHiddenInPortrait || menuMode == MenuModeHidden) {
            [self changeRevealButtonState:RevealButtonStateOpenShown];
            [self changeRevealButtonState:RevealButtonStateCloseHidden];
        }

        // Notify all observers when menu will start closing
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationMenuWillStartClosing
                                                            object:nil];
    }
}

- (void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (menuState == MenuStateOpen) {
        [self bounceMenu];
        
        // Notify all observers when menu did finish opening
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationMenuDidFinishOpening
                                                            object:nil];
    }
    else if (menuState == MenuStateClosed) {
        masterView.hidden = YES; // needs to hide also the shadow
        
        // Notify all observers when menu did finish closing
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationMenuDidFinishClosing
                                                            object:nil];
    }
}

- (void) toggleSlideBar:(UIPanGestureRecognizer *)_panGesture
{
    if (menuMode == MenuModeHiddenInPortrait) {
        if (UIInterfaceOrientationIsPortrait([self statusBarOrientation])) {
            CGFloat translation = [_panGesture translationInView:masterView].x;
            if (_panGesture.state == UIGestureRecognizerStateChanged) {
                if (translation < 0.0) { // continues with touches that start when moving to left <- and continues also to right ->
                    masterView.frame = CGRectOffset(masterView.bounds, translation, 0.0);
                    if (self.resizeDetail) {
                        CGRect rect = detailView.frame;
                        rect.origin.x = translation+self.menuWidth;
                        rect.size.width = self.view.bounds.size.width-rect.origin.x;
                        detailView.frame = rect;
                    }
                }
            }
            else if (_panGesture.state == UIGestureRecognizerStateEnded) {
                if (translation < 0.0) { // prevent to go from right -> to left
                    if (fabs(translation) > self.menuWidth/2) { // close bound (self.menuWidth/2) is achivied
                        [self closeMenu];
                    }
                    else if (fabs(translation) < self.menuWidth/2) { // reposition if menu is not closed
                        [self openMenu];
                    }                    
                }
            }
        }
    }
    else if (menuMode == MenuModeHidden) {
        CGFloat translation = [_panGesture translationInView:masterView].x;
        if (_panGesture.state == UIGestureRecognizerStateChanged) {
            if (translation < 0.0) { // continues with touches that start when moving to left <- and continues also to right ->
                masterView.frame = CGRectOffset(masterView.bounds, translation, 0.0);
                if (self.resizeDetail) {
                    CGRect rect = detailView.frame;
                    rect.origin.x = translation+self.menuWidth;
                    rect.size.width = self.view.bounds.size.width-rect.origin.x;
                    detailView.frame = rect;
                }
            }
        }
        else if (_panGesture.state == UIGestureRecognizerStateEnded) {
            if (translation < 0.0) { // prevent to go from right -> to left
                if (fabs(translation) > self.menuWidth/2) { // close bound (self.menuWidth/2) is achivied
                    [self closeMenu];
                }
                else if (fabs(translation) < self.menuWidth/2) { // reposition if menu is not closed
                    [self openMenu];
                }
            }
        }
    }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (menuMode == MenuModeHidden || menuMode == MenuModeHiddenInPortrait) {

        UITouch *touch = [touches anyObject];
		CGPoint touchPoint = [touch locationInView:detailView];
        if (CGRectContainsPoint(detailView.frame, touchPoint)) {
            if (menuState == MenuStateOpen) {
                [self closeMenu:YES];
            }
        }
    }
}

@end
