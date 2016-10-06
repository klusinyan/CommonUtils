//  Created by Karen Lusinyan on 6/21/12.
//  Copyright (c) 2012 Home. All rights reserved.

#import "CommonPicker.h"
#import "BlurView.h"

#define kPickerWidth (iPhone) ? self.target.view.frame.size.width : 320.0f;
#define kPickerHeight 260.0f

typedef void(^ShowCompletionHandler)(void);
typedef void(^HideCompletionHandler)(void);

@interface CommonPicker ()

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
<
UIPopoverControllerDelegate
>
#endif


@property (readwrite, nonatomic, assign) UIViewController *target;
@property (readwrite, nonatomic, assign) id sender;
@property (readwrite, nonatomic, assign) UIView *relativeSuperview;
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
@property (readwrite, nonatomic, strong) UIPopoverController *myPopoverController;
#endif
@property (readwrite, nonatomic, strong) UIView *overlay;
@property (readwrite, nonatomic, strong) UIView *pickerView;
@property (readwrite, nonatomic, strong) UIView *toolbar;
@property (readwrite, nonatomic, strong) UIView *picker;
@property (readwrite, nonatomic, assign) CGFloat customToolbarHeight;
@property (readwrite, nonatomic, getter = isVisible) BOOL visible;
@property (readwrite, nonatomic, getter = isTapped) BOOL tapped;

@property (readwrite, nonatomic, copy) ShowCompletionHandler showCompetion;
@property (readwrite, nonatomic, copy) HideCompletionHandler hideCompetion;

@end

@implementation CommonPicker

#pragma mark -
#pragma mark public methods

- (void)dealloc
{
    if (iPhone) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (instancetype)initWithTarget:(UIViewController *)target
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
        self.needsOverlay = NO;
        self.applyBlurEffect = NO;
        self.blurEffectStyle = UIBlurEffectStyleLight;
        self.toolbarHidden = NO;
        self.showAfterOrientationDidChange = NO;
        self.pickerCornerradius = 0.0f;
        self.customToolbarHeight = 0.0f;
        self.bounceEnabled = NO;
        self.bounceDuration = 0.15;
        self.bouncePosition = 5.0;
        
        if (iPhone) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(statusBarOrientationWillChange:)
                                                         name:UIApplicationWillChangeStatusBarOrientationNotification
                                                       object:nil];
        }
    }
    return self;
}

- (void)statusBarOrientationWillChange:(NSNotification *)notificaion
{
    if (iPhone && self.isVisible) {
        [self dismissPickerWithCompletion:^{
            if (self.showAfterOrientationDidChange) {
                [self showPickerWithCompletion:^{
                    DebugLog(@"Picker is shown after orientation did change");
                }];
            }
        }];
    }
}

- (void)showPickerWithCompletion:(void (^)(void))completion
{
    [self setupPicker];
    
    self.showCompetion = completion;
    
    if (iPhone) {
        [self slideUp];
    }
    else {
        [self showPopover];
    }
}

- (void)dismissPickerWithCompletion:(void (^)(void))completion
{
    self.hideCompetion = completion;
    
    if (iPhone) {
        [self slideDown:nil];
    }
    else {
        [self dismissPopover];
    }
}

#pragma mark -
#pragma mark private methods

- (UIToolbar *)defaultToolbar
{
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    toolbar.translatesAutoresizingMaskIntoConstraints = NO;
    
    // setup appearance
    toolbar.barTintColor = [UIToolbar appearance].barTintColor;
    toolbar.tintColor = [UIToolbar appearance].tintColor;
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                            target:self
                                                                            action:@selector(cancelAction:)];
    
    UIBarButtonItem *flex_left = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                               target:nil
                                                                               action:NULL];
    
    UILabel *label = [[UILabel alloc] init];
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(toolbarTitleLabelForPicker:)]) {
        label = [self.dataSource toolbarTitleLabelForPicker:self];
    }
    else {
        label.font = [UIFont fontWithName:@"Helvetica-Neue" size:15.0f];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(toolbarTitleForPicker:)]) {
            label.text = [self.dataSource toolbarTitleForPicker:self];
        }
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(toolbarTitleColorForPicker:)]) {
            label.textColor = [self.dataSource toolbarTitleColorForPicker:self];
        }
    }
    
    label.translatesAutoresizingMaskIntoConstraints = NO;
    
    // setup appearance
    label.backgroundColor = [UIColor clearColor];
    //label.textColor = [UIToolbar appearance].tintColor;
    
    UIBarButtonItem *title = [[UIBarButtonItem alloc] initWithCustomView:label];
    
    UIBarButtonItem *flex_right = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                target:nil
                                                                                action:NULL];
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                          target:self
                                                                          action:@selector(doneAction:)];
    
    toolbar.items = @[cancel, flex_left, title, flex_right, done];
    
    [[label superview] addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1
                                                                   constant:44.0f]];
    
    [[label superview] addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                                  attribute:NSLayoutAttributeCenterX
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:[label superview]
                                                                  attribute:NSLayoutAttributeCenterX
                                                                 multiplier:1
                                                                   constant:0]];
    
    [[label superview] addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                                  attribute:NSLayoutAttributeCenterY
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:[label superview]
                                                                  attribute:NSLayoutAttributeCenterY
                                                                 multiplier:1
                                                                   constant:0]];
    
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

- (CGFloat)getPickerHeight
{
    CGFloat pickerHeight = kPickerHeight;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(heightForPicker:)]) {
        pickerHeight = [self.dataSource heightForPicker:self];
        
        //sum custom toolbar height (if a custom toolbar provided)
        pickerHeight += self.customToolbarHeight;
    }
    if (self.isToolbarHidden) {
        pickerHeight -= 44.0f;
    }
    return pickerHeight;
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
        return visualEffectView;
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
    //self.picker.backgroundColor = [UIColor redColor];
    
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
    //contentController.view.translatesAutoresizingMaskIntoConstraints = NO;
    //contentController.view.backgroundColor = [UIColor redColor];
    contentController.view.frame = CGRectMake(0, 0, size.width, size.height);
    
    self.pickerView.translatesAutoresizingMaskIntoConstraints = NO;
    [contentController.view addSubview:self.pickerView];
    
    [contentController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_pickerView]|"
                                                                                   options:0
                                                                                   metrics:nil
                                                                                     views:NSDictionaryOfVariableBindings(_pickerView)]];
    
    [contentController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_pickerView]|"
                                                                                   options:0
                                                                                   metrics:nil
                                                                                     views:NSDictionaryOfVariableBindings(_pickerView)]];
    return contentController;
}

- (void)showPopover
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
    CGSize size = CGSizeMake([self getPickerWidth], [self getPickerHeight]);
    UIViewController *vc = [self contentViewControllerWithSize:size];
    //vc.view.backgroundColor = [UIColor greenColor];
    vc.preferredContentSize = size;
    vc.modalPresentationStyle = UIModalPresentationPopover;
    [self.target presentViewController:vc
                              animated:YES
                            completion:^{
                                if (self.showCompetion) self.showCompetion();
                            }];
    UIPopoverPresentationController *popover = vc.popoverPresentationController;
    popover.backgroundColor = [UIColor whiteColor];
    popover.canOverlapSourceViewRect = YES;
    popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    if ([self.sender isKindOfClass:[UIBarButtonItem class]]) {
        popover.barButtonItem = self.sender;
    }
    else if ([self.sender isKindOfClass:[UIView class]]) {
        UIView *sender = (UIView *)self.sender;
        popover.sourceRect = CGRectMake(0, 0, sender.frame.size.width, sender.frame.size.height);
        popover.sourceView = self.sender;
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
    [self.target dismissViewControllerAnimated:YES
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
    self.overlay.backgroundColor = [UIColor colorWithWhite:0.2f alpha:0.0f];
    [self.target.view addSubview:self.overlay];
    
    NSDictionary *bindings = @{@"overlay" : self.overlay};
    
    [self.target.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[overlay]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:bindings]];
    
    [self.target.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[overlay]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:bindings]];
    
    UITapGestureRecognizer* tapGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(slideDown:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [self.overlay addGestureRecognizer:tapGesture];
}

- (void)centerPickerView
{
    self.pickerView.center = CGPointMake(self.pickerView.superview.center.x, self.pickerView.center.y);
}

- (void)slideUp
{
    /*self.completionType = CompletionTypeUnknown;*/
    
    // check if our date picker is already on screen
    if (!self.isVisible && self.pickerView.superview == nil) {
        
        //add background overlay
        [self addOverlay];
        
        //assign size to picker
        CGFloat positionY;
        if (self.presentFromTop) {
            positionY = -[self getPickerHeight];
        }
        else {
            positionY = self.target.view.bounds.size.height;
        }
        self.pickerView.frame = CGRectMake(0, positionY, [self getPickerWidth]-2 * [self getPickerPadding], [self getPickerHeight]);

        //add to superview
        [self.target.view addSubview:self.pickerView];
        
        CGSize pickerSize = [self.pickerView sizeThatFits:CGSizeZero];
        self.pickerView.frame = CGRectMake(0, positionY, pickerSize.width, pickerSize.height);

        // size up the picker view to our screen and compute the start/end frame origin for our slide up animation
        
        /////////////////////////////////////////////////
        ////////////////// START FRAME //////////////////

        if (self.presentFromTop) {
            positionY = -[self getPickerHeight];
        }
        else {
            positionY = self.target.view.bounds.size.height;
        }
        CGSize pickerViewContainerSize = CGSizeMake(pickerSize.width, pickerSize.height);
        CGRect startFrame = CGRectMake(0.0 + [self getPickerPadding],
                                       positionY + [self getPickerPadding],
                                       pickerViewContainerSize.width,
                                       pickerViewContainerSize.height);
        
        ////////////////// START FRAME //////////////////
        /////////////////////////////////////////////////

        /////////////////////////////////////////////////
        /////////////////// END FRAME ///////////////////

        if (self.presentFromTop) {
            positionY = [self getPickerPadding];
        }
        else {
            positionY = self.target.view.bounds.size.height - pickerViewContainerSize.height - [self getPickerPadding];
        }
        __block CGRect endFrame = CGRectMake(0.0 + [self getPickerPadding],
                                             positionY,
                                             pickerViewContainerSize.width,
                                             pickerViewContainerSize.height);
        
        /////////////////// END FRAME ///////////////////
        /////////////////////////////////////////////////
        
        /////////////////////////////////////////////////
        /////////////////// ANIMATION ///////////////////

        self.pickerView.frame = startFrame;
        [UIView animateWithDuration:0.15
                         animations:^{
                             self.pickerView.frame = endFrame;
                             self.overlay.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.5];
                         } completion:^(BOOL finished) {
                             [self slideUpDidStart];
                         }];
        
        /////////////////// ANIMATION ///////////////////
        /////////////////////////////////////////////////
    }
}

- (void)slideDown:(UIGestureRecognizer *)tapGesture
{
    if (self.isVisible && self.pickerView.superview != nil) {
        
        if (tapGesture) {
            self.tapped = YES;
        }
        
        CGRect targetFrame = self.target.view.frame;
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
    
    //set tapped to default
    self.tapped = NO;
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
#endif
@end
