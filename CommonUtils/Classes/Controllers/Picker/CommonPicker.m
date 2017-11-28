//  Created by Karen Lusinyan on 6/21/12.
//  Copyright (c) 2012 Home. All rights reserved.

#import "CommonPicker.h"
#import "BlurView.h"

#define kAutoLayout 1
#define kDoubleOverlayPermitted 1

#if !kDoubleOverlayPermitted
    static BOOL VISIBLE = NO;
#endif

#if !kAutoLayout
@interface UIView (Frame)

- (void)centerX;

- (void)centerY;

@end

@implementation UIView (Frame)

- (void)centerX
{
    self.frame = [self centeredFrameX];
}

- (void)centerY
{
    self.frame = [self centeredFrameY];
}

- (CGRect)centeredFrameX
{
    CGRect frame = self.frame;
    frame.origin.x = CGRectGetMidX([self superview].frame) - CGRectGetWidth(self.frame) / 2;
    return frame;
}

- (CGRect)centeredFrameY
{
    CGRect frame = self.frame;
    frame.origin.y = CGRectGetMidY([self superview].frame) - CGRectGetWidth(self.frame) / 2;
    return frame;
}

@end
#endif

#define kPickerWidth self.window.frame.size.width
#define kPickerHeight 260.0f

typedef void(^ShowCompletionHandler)(void);
typedef void(^HideCompletionHandler)(void);

@interface CommonPicker ()

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
<
UIPopoverControllerDelegate
>
#else
<
UIPopoverPresentationControllerDelegate
>
#endif

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
@property (nonatomic, strong) UIPopoverController *myPopoverController;
#else 
@property (nonatomic, strong) UIViewController *controller;
@property (nonatomic, strong) UIPopoverPresentationController *popoverPresentationController;
#endif
@property (nonatomic, strong) UIView *overlay;
@property (nonatomic, strong) UIView *pickerView;
@property (nonatomic, strong) UIView *toolbar;
@property (nonatomic, strong) UIView *picker;
@property (nonatomic, assign) CGFloat customToolbarHeight;
@property (nonatomic, getter = isVisible) BOOL visible;
@property (nonatomic, getter = isTapped) BOOL tapped;

@property (nonatomic, copy) ShowCompletionHandler showCompetion;
@property (nonatomic, copy) HideCompletionHandler hideCompetion;

@property (nonatomic, strong) NSLayoutConstraint *constraintOriginY;
@property (nonatomic, strong) NSLayoutConstraint *constraintSizeHeight;

@end

@implementation CommonPicker

#pragma mark -
#pragma mark public methods

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init
{
    self = [super init];
    if (self) {
        //defaults
        self.visible = NO;
        self.tapped = NO;
        self.presentFromTop = NO;
        self.notificationMode = NO;
        self.needsOverlay = NO;
        self.tappableOverlay = YES;
        self.applyBlurEffect = NO;
        self.blurEffectStyle = UIBlurEffectStyleLight;
        self.toolbarHidden = NO;
        self.pickerCornerradius = 0.0f;
        self.customToolbarHeight = 0.0f;
        self.bounceEnabled = NO;
        self.bounceDuration = 0.15;
        self.bouncePosition = 5.0;
        self.expectedHeight = 0.0;
        self.dynamicContentHeight = NO;
   
#if !kAutoLayout
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(statusBarOrientationDidChange:)
                                                     name:UIApplicationDidChangeStatusBarFrameNotification
                                                   object:nil];
#endif
    }
    return self;
}

- (id)initWithTarget:(UIViewController *)target
              sender:(id)sender
   relativeSuperview:(UIView *)relativeSuperview
{
    self = [super init];
    if (self) {
        if (!target) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ Please, provide valid target of kind of class UIViewController.", NSStringFromClass([self class])] userInfo:nil];
        }
        
        self.target = target;
        self.sender = sender;
        self.relativeSuperview = relativeSuperview;
        
        //defaults
        self.visible = NO;
        self.tapped = NO;
        self.presentFromTop = NO;
        self.notificationMode = NO;
        self.needsOverlay = NO;
        self.tappableOverlay = YES;
        self.applyBlurEffect = NO;
        self.blurEffectStyle = UIBlurEffectStyleLight;
        self.toolbarHidden = NO;
        self.pickerCornerradius = 0.0f;
        self.customToolbarHeight = 0.0f;
        self.bounceEnabled = NO;
        self.bounceDuration = 0.15;
        self.bouncePosition = 5.0;
        self.expectedHeight = 0.0;
        self.dynamicContentHeight = NO;
        
#if !kAutoLayout
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(statusBarOrientationDidChange:)
                                                     name:UIApplicationDidChangeStatusBarFrameNotification
                                                   object:nil];
#endif
    }
    return self;
}

#if !kAutoLayout
- (void)statusBarOrientationDidChange:(NSNotification *)notificaion
{
    if (iPhone || self.notificationMode) {
        if (self.isVisible) {
            CGRect frame = self.pickerView.frame;
            frame.size.width = [self getPickerWidth] - 2 * [self getPickerPadding];
            CGFloat positionY;
            if (self.presentFromTop) {
                positionY = [self getPickerPadding];
            }
            else {
                positionY = self.window.bounds.size.height - [self getPickerHeight] - [self getPickerPadding];
            }
            frame.origin.y = positionY;
            self.pickerView.frame = frame;
            if (iPad) {
                [self.pickerView centerX];
            }
        }
    }
}
#endif

- (void)showPickerWithCompletion:(void (^)(void))completion
{
    [self setupPicker];
    
    self.showCompetion = completion;
    
    if (iPhone || self.notificationMode) {
        [self slideUp];
    }
    else {
        [self showPopover];
    }
}

- (void)dismissPickerWithCompletion:(void (^)(void))completion
{
    self.hideCompetion = completion;
    
    if (iPhone || self.notificationMode) {
        [self slideDown];
    }
    else {
        [self dismissPopover];
    }
}

#pragma mark -
#pragma mark private methods

- (UIView *)window
{
    if (_window == nil) {
        _window = [UIApplication sharedApplication].keyWindow;
    }
    return _window;
}

- (UIToolbar *)defaultToolbar
{
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    toolbar.translatesAutoresizingMaskIntoConstraints = NO;
    toolbar.barTintColor = [UIToolbar appearance].barTintColor;
    toolbar.tintColor = [UIToolbar appearance].tintColor;
    
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                           target:nil
                                                                           action:NULL];
    fixed.width = 10;

    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                            target:self
                                                                            action:@selector(cancelAction:)];
    
    UIBarButtonItem *flex_left = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                               target:nil
                                                                               action:NULL];
    
    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(toolbarTitleLabelForPicker:)]) {
        label = [self.dataSource toolbarTitleLabelForPicker:self];
    }
    else {
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(toolbarTitleForPicker:)]) {
            label.text = [self.dataSource toolbarTitleForPicker:self];
        }
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(toolbarTitleColorForPicker:)]) {
            label.textColor = [self.dataSource toolbarTitleColorForPicker:self];
        }
    }
    
    UIBarButtonItem *title = [[UIBarButtonItem alloc] initWithCustomView:label];
    
    UIBarButtonItem *flex_right = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                target:nil
                                                                                action:NULL];
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                          target:self
                                                                          action:@selector(doneAction:)];
    
    toolbar.items = @[fixed, cancel, flex_left, title, flex_right, done, fixed];
    
    return toolbar;
}

- (CGFloat)getPickerWidth
{
    CGFloat pickerWidth = kPickerWidth;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(widthForPicker:)]) {
        pickerWidth = [self.dataSource widthForPicker:self];
    }
    return pickerWidth;
}

- (CGFloat)getPickerWidthMultiplier
{
    CGFloat multiplier = (iPhone) ? 1.0 : 0.75;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(widthMultiplierForPicker:)]) {
        multiplier = [self.dataSource widthMultiplierForPicker:self];
    }
    return multiplier;
}

- (CGFloat)getPickerHeight
{
    CGFloat pickerHeight = kPickerHeight;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(heightForPicker:)]) {
        pickerHeight = [self.dataSource heightForPicker:self];
        
        //sum custom toolbar height (if a custom toolbar provided)
        pickerHeight += self.customToolbarHeight;
    }
    if (self.dynamicContentHeight) {
        return MAX(pickerHeight, self.expectedHeight);
    }
    else {
        return pickerHeight;
    }
}

- (CGFloat)getPickerPadding
{
    CGFloat padding = 0.0;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(paddingForPicker:)]) {
        padding = [self.dataSource paddingForPicker:self];
    }
    return padding;
}

- (UIView *)blurView:(UIBlurEffectStyle)style
{
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
        // blur view
        UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:style];
        UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        visualEffectView.clipsToBounds = YES;
        return visualEffectView.contentView;
    }
    else {
        // normal view
        BlurView *overlay = [[BlurView alloc] init];
        overlay.blurTintColor = [UIColor whiteColor];
        return overlay;
    }
}

- (void)setupPicker
{
    if (self.applyBlurEffect) {
        self.pickerView = [self blurView:self.blurEffectStyle];
    }
    else {
        self.pickerView = [[UIView alloc] init];
        self.pickerView.backgroundColor = [UIColor whiteColor];
    }
    self.pickerView.layer.cornerRadius = self.pickerCornerradius;
    self.pickerView.clipsToBounds = YES;
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(contentForPicker:)]) {
        self.picker = [self.dataSource contentForPicker:self];
    }
    if (!self.picker) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ Failed to call pickerContent:, dataSource should provide a valid pickerContent.", NSStringFromClass([self class])] userInfo:nil];
    }
    
    CGFloat toolbarHeight = 0.0f;
    UIToolbar *defaultToolbar = [self defaultToolbar];
    if (![self.dataSource respondsToSelector:@selector(toolbar:forPicker:)] ||
        ([self.dataSource respondsToSelector:@selector(toolbar:forPicker:)] && [self.dataSource toolbar:defaultToolbar forPicker:self] == nil)) {
        if (!self.isToolbarHidden) {
            self.toolbar = defaultToolbar;
            toolbarHeight = 44.0f;
        }
    }
    else {
        if (defaultToolbar == [self.dataSource toolbar:defaultToolbar forPicker:self]) {
            self.toolbar = defaultToolbar;
            toolbarHeight = 44.0f;
        }
        else {
            self.toolbar = [self.dataSource toolbar:defaultToolbar forPicker:self];
            self.toolbar.translatesAutoresizingMaskIntoConstraints = NO;
            if (!self.isToolbarHidden) {
                if ([self.dataSource respondsToSelector:@selector(toolbarHeightForPicker:)]) {
                    toolbarHeight = [self.dataSource toolbarHeightForPicker:self];
                    self.customToolbarHeight = toolbarHeight;
                }
                else {
                    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ Failed to call pickerContent:, dataSource should provide a valid pickerToolbarHeight.", NSStringFromClass([self class])] userInfo:nil];
                }
            }
        }
    }
    
    if (!self.isToolbarHidden) {
        [self.pickerView addSubview:self.toolbar];
    }
    
    self.picker.translatesAutoresizingMaskIntoConstraints = NO;
    [self.pickerView addSubview:self.picker];
    
    if (!self.isToolbarHidden) {
        [self.pickerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_toolbar]|"
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:NSDictionaryOfVariableBindings(_toolbar)]];
    }
    
    [self.pickerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_picker]|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:NSDictionaryOfVariableBindings(_picker)]];
    
    if (!self.isToolbarHidden) {
        NSString *contraint_V = [NSString stringWithFormat:@"V:|[_toolbar(==%@)][_picker]|", @(toolbarHeight)];
        [self.pickerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:contraint_V
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:NSDictionaryOfVariableBindings(_toolbar, _picker)]];
    }
    else {
        [self.pickerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_picker]|"
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:NSDictionaryOfVariableBindings(_picker)]];
    }
}

- (UIViewController *)contentViewControllerWithSize:(CGSize)size
{
    UIViewController *contentController = [[UIViewController alloc] init];
    contentController.view.frame = CGRectMake(0, 0, size.width, size.height);
    self.pickerView.frame = contentController.view.frame;
    [contentController.view addSubview:self.pickerView];
    return contentController;
}

- (void)showPopover
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
    CGSize size = CGSizeMake([self getPickerWidth], [self getPickerHeight]);
    self.controller = [self contentViewControllerWithSize:size];
    self.controller.preferredContentSize = size;
    self.controller.modalPresentationStyle = UIModalPresentationPopover;
    [self.target presentViewController:self.controller
                              animated:YES
                            completion:^{
                                if (self.showCompetion) self.showCompetion();
                            }];
    
    // setup popover controller
    self.popoverPresentationController = self.controller.popoverPresentationController;
    self.popoverPresentationController.backgroundColor = [UIColor clearColor];
    self.popoverPresentationController.canOverlapSourceViewRect = YES;
    self.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    self.popoverPresentationController.delegate = self;
    if ([self.sender isKindOfClass:[UIBarButtonItem class]]) {
        self.popoverPresentationController.barButtonItem = self.sender;
    }
    else if ([self.sender isKindOfClass:[UIView class]]) {
        UIView *sender = (UIView *)self.sender;
        self.popoverPresentationController.sourceRect = CGRectMake(0, 0, sender.frame.size.width, sender.frame.size.height);
        self.popoverPresentationController.sourceView = self.sender;
    }
#else
    CGSize size = CGSizeMake([self getPickerWidth], [self getPickerHeight]);
    self.myPopoverController =
    [[UIPopoverController alloc] initWithContentViewController:[self contentViewControllerWithSize:size]];
    self.myPopoverController.delegate = self;
    [self.myPopoverController setPopoverContentSize:size animated:YES];
    
    UIPopoverArrowDirection popoverArrowDirection = UIPopoverArrowDirectionAny;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(popoverArrowDirectionForPicker:)]) {
        popoverArrowDirection = [self.dataSource popoverArrowDirectionForPicker:self];
    }
    
    //present from UIBarButtonItem
    if ([self.sender isKindOfClass:[UIBarButtonItem class]]) {
        [self.myPopoverController presentPopoverFromBarButtonItem:self.sender
                                         permittedArrowDirections:popoverArrowDirection
                                                         animated:YES];
    }
    //present from any other view
    else if ([self.sender isKindOfClass:[UIView class]]) {
        UIView *sender = (UIView *)self.sender;
        UIView *relativeSuperview = [sender superview];
        if ([self.relativeSuperview isKindOfClass:[UIView class]]) {
            relativeSuperview = self.relativeSuperview;
        }
        CGRect taregtRect = [self.target.view convertRect:sender.frame fromView:relativeSuperview];
        [self.myPopoverController presentPopoverFromRect:taregtRect
                                                  inView:self.target.view
                                permittedArrowDirections:popoverArrowDirection
                                                animated:YES];
    }
    
    if (self.showCompetion) self.showCompetion();
#endif
}

- (void)dismissPopover
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
    [self.controller dismissViewControllerAnimated:YES
                                        completion:^{
                                            if (self.hideCompetion) self.hideCompetion();
                                        }];
#else
    if (self.myPopoverController.popoverVisible) {
        [self.myPopoverController dismissPopoverAnimated:YES];
        
        if (self.hideCompetion) self.hideCompetion();
    }
#endif
}

- (void)addOverlay
{
    if (!self.needsOverlay) {
        return;
    }
    
    self.overlay = [[UIView alloc] init];
    self.overlay.translatesAutoresizingMaskIntoConstraints = NO;
    [self.window addSubview:self.overlay];
    
    NSDictionary *bindings = @{@"overlay" : self.overlay};
    
    [self.window addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[overlay]|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:bindings]];
    
    [self.window addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[overlay]|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:bindings]];
    
    UITapGestureRecognizer* tapGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(overlayTapped:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [self.overlay addGestureRecognizer:tapGesture];
}

- (void)slideUp
{
    // check if our date picker is already on screen
    if (!self.isVisible && self.pickerView.superview == nil) {
        
        //add background overlay
        [self addOverlay];
        
#if kAutoLayout
        self.pickerView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.window addSubview:self.pickerView];

        if (!self.presentFromTop) {
            self.constraintOriginY = [NSLayoutConstraint constraintWithItem:self.pickerView
                                                                  attribute:NSLayoutAttributeBottom
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:[self.pickerView superview]
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1
                                                                   constant:[self getPickerHeight]];
        }
        else {
            self.constraintOriginY = [NSLayoutConstraint constraintWithItem:self.pickerView
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:[self.pickerView superview]
                                                                  attribute:NSLayoutAttributeTop
                                                                 multiplier:1
                                                                   constant:-([self getPickerHeight] + [self getPickerPadding])];
        }

        NSLayoutConstraint *c1 = [NSLayoutConstraint constraintWithItem:self.pickerView
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:[self.pickerView superview]
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:[self getPickerWidthMultiplier]
                                                               constant:-(2*[self getPickerPadding])];
        
        self.constraintSizeHeight = [NSLayoutConstraint constraintWithItem:self.pickerView
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1
                                                                  constant:[self getPickerHeight]];
        
        NSLayoutConstraint *c4 = [NSLayoutConstraint constraintWithItem:self.pickerView
                                                              attribute:NSLayoutAttributeLeading
                                                              relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                 toItem:[self.pickerView superview]
                                                              attribute:NSLayoutAttributeLeading
                                                             multiplier:1
                                                               constant:[self getPickerPadding]];
        
        NSLayoutConstraint *c5 = [NSLayoutConstraint constraintWithItem:self.pickerView
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:[self.pickerView superview]
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1
                                                               constant:0];
        
        [self.window addConstraints:@[self.constraintOriginY, c1, self.constraintSizeHeight, c4, c5]];
        [self.window layoutIfNeeded];
        
        [UIView animateWithDuration:0.15
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
#if kDoubleOverlayPermitted
                             self.overlay.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
#else
                             if (!VISIBLE) {
                                 VISIBLE = YES;
                                 self.overlay.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
                             }
#endif
                             
                             CGFloat positionY = [self getPickerPadding];
                             if (!self.presentFromTop) {
                                 self.constraintOriginY.constant = -positionY;
                             }
                             else {
                                 self.constraintOriginY.constant = positionY;
                             }
                             [self.window layoutIfNeeded];
                         } completion:^(BOOL finished) {
                             [self slideUpDidStart];
                         }];
#else
        //assign size to picker
        CGFloat positionY;
        if (self.presentFromTop) {
            positionY = -[self getPickerHeight];
        }
        else {
            positionY = self.window.bounds.size.height;
        }

        self.pickerView.frame = CGRectMake([self getPickerPadding],
                                           positionY,
                                           [self getPickerWidth] - 2 * [self getPickerPadding],
                                           [self getPickerHeight]);
        [self.window addSubview:self.pickerView];
        
        // size up the picker view to our screen and compute the start/end frame origin for our slide up animation
        
        /////////////////////////////////////////////////
        ////////////////// START FRAME //////////////////
        
        if (self.presentFromTop) {
            positionY = -[self getPickerHeight];
        }
        else {
            positionY = self.window.bounds.size.height;
        }
        CGRect startFrame = self.pickerView.frame;
        startFrame.origin.y = positionY + [self getPickerPadding];
        
        ////////////////// START FRAME //////////////////
        /////////////////////////////////////////////////
        
        /////////////////////////////////////////////////
        /////////////////// END FRAME ///////////////////
        
        if (self.presentFromTop) {
            positionY = [self getPickerPadding];
        }
        else {
            positionY = self.window.bounds.size.height - [self getPickerHeight] - [self getPickerPadding];
        }
        __block CGRect endFrame = self.pickerView.frame;
        endFrame.origin.y = positionY;
        
        /////////////////// END FRAME ///////////////////
        /////////////////////////////////////////////////
        
        /////////////////////////////////////////////////
        /////////////////// ANIMATION ///////////////////
        
        self.pickerView.frame = startFrame;
        if (iPad) {
            [self.pickerView centerX];
        }
        [UIView animateWithDuration:0.15
                         animations:^{
                             self.pickerView.frame = endFrame;
                             if (iPad) {
                                 [self.pickerView centerX];
                             }
                             self.overlay.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
                         } completion:^(BOOL finished) {
                             [self slideUpDidStart];
                         }];
        
        /////////////////// ANIMATION ///////////////////
        /////////////////////////////////////////////////
#endif
    }
}

- (void)slideDown
{
    if (self.isVisible && self.pickerView.superview != nil) {
        
#if kAutoLayout
        [UIView animateWithDuration:0.15
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
#if kDoubleOverlayPermitted
                             self.overlay.alpha = 0.0f;
#else
                             if (VISIBLE) {
                                 VISIBLE = NO;
                                 self.overlay.alpha = 0.0f;
                             }
#endif
                             CGFloat positionY = [self getPickerPadding] + self.constraintSizeHeight.constant;
                             if (!self.presentFromTop) {
                                 self.constraintOriginY.constant = positionY;
                             }
                             else {
                                 self.constraintOriginY.constant = -positionY;
                             }
                             [self.window layoutIfNeeded];
                         } completion:^(BOOL finished) {
                             [self slideDownDidStop];
                         }];

#else
        CGRect targetFrame = self.window.frame;
        CGRect endFrame = self.pickerView.frame;
        if (self.presentFromTop) {
            endFrame.origin.y = -endFrame.size.height;
        }
        else {
            endFrame.origin.y = targetFrame.origin.y + targetFrame.size.height;
        }

        /////////////////////////////////////////////////
        /////////////////// ANIMATION ///////////////////

        [UIView animateWithDuration:0.15
                         animations:^{
                             self.pickerView.frame = endFrame;
                             self.overlay.alpha = 0.0f;
                         } completion:^(BOOL finished) {
                             [self slideDownDidStop];
                         }];
        
        /////////////////// ANIMATION ///////////////////
        /////////////////////////////////////////////////
#endif
    }
}

- (void)overlayTapped:(UIGestureRecognizer *)tapGesture
{
    self.tapped = YES;

    if (self.tappableOverlay) {
        [self slideDown];
    }
}

- (void)slideUpDidStart
{
    if (self.bounceEnabled) {
        CABasicAnimation *bounceAnimation = [CABasicAnimation animationWithKeyPath:@"position.y"];
        bounceAnimation.duration = self.bounceDuration;
        bounceAnimation.fromValue = [NSNumber numberWithFloat:self.pickerView.center.y];
        bounceAnimation.toValue = [NSNumber numberWithFloat:self.pickerView.center.y - self.bouncePosition];
        bounceAnimation.repeatCount = 0;
        bounceAnimation.autoreverses = YES;
        bounceAnimation.fillMode = kCAFillModeBackwards;
        bounceAnimation.removedOnCompletion = YES;
        bounceAnimation.additive = NO;
        [CATransaction setCompletionBlock:^{
            self.visible = YES;
        }];
        [self.pickerView.layer addAnimation:bounceAnimation forKey:@"bounceAnimation"];
        [CATransaction commit];
    }
    else {
        self.visible = YES;
    }
    
    if (self.showCompetion) self.showCompetion();
}

- (void)slideDownDidStop
{
    // the date picker has finished sliding downwards, so remove it
    [self.pickerView removeFromSuperview];
    
    //remove overlay
    [self.overlay removeFromSuperview];
    
    //set boolean
    self.visible = NO;
    
    if (!self.isTapped) {
        if (self.hideCompetion) self.hideCompetion();
    }
    else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(pickerOverkayDidTap:)]) {
            [self.delegate pickerOverkayDidTap:self];
        }
    }
    
    self.tapped = NO;
}

- (void)dragDown:(void(^)(void))completion
{
    if (!self.dynamicContentHeight) {
        [UIView animateWithDuration:0.25
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.constraintSizeHeight.constant = self.expectedHeight;
                             [self.window layoutIfNeeded];
                         } completion:^(BOOL finished) {
                             if (completion) completion();
                         }];
    }
}

- (void)dragUp:(void(^)(void))completion
{
    if (!self.dynamicContentHeight) {
        [UIView animateWithDuration:0.25
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.constraintSizeHeight.constant = [self getPickerHeight];
                             [self.window layoutIfNeeded];
                         } completion:^(BOOL finished) {
                             if (completion) completion();
                         }];
    }
}

- (void)shrinkUp:(CGFloat)offset animated:(BOOL)animated completion:(void (^)(BOOL))completion
{
    [[self.pickerView superview] layoutIfNeeded];                                               // call parent to layout
    [UIView animateWithDuration:animated ? 0.5 : 0.0
                     animations:^{
                         self.constraintSizeHeight.constant = [self getPickerHeight] + offset;  // adjust constraints
                         [[self.pickerView superview] layoutIfNeeded];                          // call parent to layout
                     } completion:^(BOOL finished) {
                         if (completion) completion(finished);
                     }];
}

- (void)shrinkDown:(BOOL)animated completion:(void (^)(BOOL))completion
{
    [[self.pickerView superview] layoutIfNeeded];                                               // call parent to layout
    [UIView animateWithDuration:animated ? 0.5 : 0.0
                     animations:^{
                         self.constraintSizeHeight.constant = [self getPickerHeight];           // adjust constraints
                         [[self.pickerView superview] layoutIfNeeded];                          // call parent to layout
                     } completion:^(BOOL finished) {
                         if (completion) completion(finished);
                     }];
}

#pragma mark -
#pragma mark IBAction

- (void)cancelAction:(id)sender
{
    [self dismissPickerWithCompletion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(picker:cancelActionCallback:)]) {
            [self.delegate picker:self cancelActionCallback:sender];
        }
    }];
}

- (void)doneAction:(id)sender
{
    [self dismissPickerWithCompletion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(picker:doneActionCallback:)]) {
            [self.delegate picker:self doneActionCallback:sender];
        }
    }];
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
#pragma mark -
#pragma mark - UIPopoverControllerDelegate

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    //do somthing
    return YES;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    //do something
}

- (void)popoverController:(UIPopoverController *)popoverController willRepositionPopoverToRect:(inout CGRect *)rect inView:(inout UIView *__autoreleasing *)view
{
    if (self.myPopoverController == popoverController) {
        CGRect taregtRect = [self.target.view convertRect:((UIView *)self.sender).frame fromView:(UIView *)self.relativeSuperview];
        *rect = taregtRect;
    }
}
#else 
- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController
{
    // called when a Popover is dismissed
}

- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController
{
    return YES;
}

- (void)popoverPresentationController:(UIPopoverPresentationController *)popoverPresentationController willRepositionPopoverToRect:(inout CGRect *)rect inView:(inout UIView *__autoreleasing  _Nonnull *)view {
    
    if (self.popoverPresentationController == popoverPresentationController) {
        CGRect taregtRect = [self.target.view convertRect:((UIView *)self.sender).frame fromView:(UIView *)self.relativeSuperview];
        *rect = taregtRect;
    }
}
#endif
@end
