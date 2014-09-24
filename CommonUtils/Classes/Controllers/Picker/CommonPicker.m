//  Created by Karen Lusinyan on 6/21/12.
//  Copyright (c) 2012 Home. All rights reserved.

#import "CommonPicker.h"
#import "BlurView.h"

typedef void(^ShowCompletionHandler)(void);
typedef void(^HideCompletionHandler)(void);

@interface CommonPicker ()
<
UIPopoverControllerDelegate
>

@property (readwrite, nonatomic, assign) UIViewController *target;
@property (readwrite, nonatomic, assign) id sender;
@property (readwrite, nonatomic, assign) id relativeSuperview;
@property (readwrite, nonatomic, strong) UIPopoverController *myPopoverController;
@property (readwrite, nonatomic, strong) UIView *overlay;
@property (readwrite, nonatomic, strong) UIView *pickerView;
@property (readwrite, nonatomic, strong) UIView *toolbar;
@property (readwrite, nonatomic, strong) UIView *picker;
@property (readwrite, nonatomic, getter = isVisible) BOOL visible;

@property (readwrite, nonatomic, copy) ShowCompletionHandler showCompetion;
@property (readwrite, nonatomic, copy) HideCompletionHandler hideCompetion;

@end

@implementation CommonPicker

#pragma mark -
#pragma mark public methods

- (instancetype)initWithTarget:(id)target
                        sender:(id)sender
             relativeSuperview:(id)relativeSuperview;
{
    self = [super init];
    if (self) {
        self.target = (UIViewController *)target;
        self.sender = sender;
        self.relativeSuperview = relativeSuperview;
        
        //defaults
        self.toolbarHidden = NO;
        self.needsOverlay = NO;
        self.shouldChangeOrientation = NO;
        self.pickerWidth = (iPhone) ? self.target.view.frame.size.width : 320.0f;
        self.pickerHeight = 260.0f;
        self.pickerCornerradius = 0.0f;
        self.popoverArrowDirection = UIPopoverArrowDirectionAny;
    }
    return self;
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
        [self slideDown];
    }
    else {
        [self dismissPopover];
    }
}

#pragma mark -
#pragma mark private methods

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIToolbar *)defaultToolbar
{
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    toolbar.translatesAutoresizingMaskIntoConstraints = NO;
    //toolbar.barTintColor = [UIColor greenColor];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                            target:self
                                                                            action:@selector(cancelAction:)];
    
    UIBarButtonItem *flex_left = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                               target:nil
                                                                               action:NULL];
    
    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.font = [UIFont fontWithName:@"Helvetica-Neue" size:14.0f];
    //label.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    //label.shadowOffset = CGSizeMake(0, -1);
    label.textColor = [UIColor colorWithRed:14/255.0 green:121/255.0 blue:255/255.0 alpha:1];
    label.textAlignment = NSTextAlignmentCenter;
    //label.backgroundColor = [UIColor whiteColor];
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(toolbarTitle)]) {
        label.text = [self.dataSource toolbarTitle];
    }
    
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

- (void)setupPicker
{
    self.pickerView = (iPad) ? [[UIView alloc] init] : [[BlurView alloc] init];
    self.pickerView.layer.cornerRadius = self.pickerCornerradius;
    //self.pickerView.backgroundColor = [UIColor greenColor];
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(pickerContent)] && [self.dataSource pickerContent]) {
        self.picker = [self.dataSource pickerContent];
    }
    else {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ Failed to call pickerContent:, dataSource should provide a valid pickerContent.", NSStringFromClass([self class])] userInfo:nil];
    }
    
    BOOL showToolbar = !self.toolbarHidden;
    CGFloat toolbarHeight = 0.0f;
    
    if (![self.dataSource respondsToSelector:@selector(pickerToolbar)] ||
        ([self.dataSource respondsToSelector:@selector(pickerToolbar)] && [self.dataSource pickerToolbar] == nil)) {
        if (!self.toolbarHidden) {
            self.toolbar = [self defaultToolbar];
            toolbarHeight = 44.0f;
        }
    }
    else {
        self.toolbar = [self.dataSource pickerToolbar];
        self.toolbar.translatesAutoresizingMaskIntoConstraints = NO;
        if ([self.dataSource respondsToSelector:@selector(toolbarHeight)]) {
            toolbarHeight = [self.dataSource toolbarHeight];
            self.pickerHeight += toolbarHeight;
        }
        else {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ Failed to call pickerContent:, dataSource should provide a valid toolbarHeight.", NSStringFromClass([self class])] userInfo:nil];
        }
    }
    
    if (showToolbar) {
        [self.pickerView addSubview:self.toolbar];
    }
    
    self.picker.translatesAutoresizingMaskIntoConstraints = NO;
    [self.pickerView addSubview:self.picker];
    //self.picker.backgroundColor = [UIColor redColor];
    
    if (showToolbar) {
        [self.pickerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_toolbar]|"
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:NSDictionaryOfVariableBindings(_toolbar)]];
    }
    
    [self.pickerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_picker]|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:NSDictionaryOfVariableBindings(_picker)]];
    
    if (showToolbar) {
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

#pragma mark -
#pragma Rotation methods

- (void)orientationDidChange:(NSNotification *)notification
{
    [self reloadPickerWithCompletion:nil];
}

- (void)reloadPickerWithCompletion:(void(^)(void))completion
{
    if (iPad && [self.myPopoverController isPopoverVisible]) {
        //present from UIBarButtonItem
        if ([self.sender isKindOfClass:[UIBarButtonItem class]]) {
            [self.myPopoverController setPopoverContentSize:CGSizeMake(self.pickerWidth, self.pickerHeight) animated:YES];
            [self.myPopoverController presentPopoverFromBarButtonItem:self.sender
                                             permittedArrowDirections:self.popoverArrowDirection
                                                             animated:YES];
        }
        //present from any other view
        else if ([self.sender isKindOfClass:[UIView class]]) {
            UIView *view = (UIView *)self.sender;
            UIView *relativeSuperview = (UIView *)self.relativeSuperview;
            CGRect myRect = [relativeSuperview convertRect:view.frame toView:self.target.view];
            [self.myPopoverController setPopoverContentSize:CGSizeMake(self.pickerWidth, self.pickerHeight) animated:YES];
            [self.myPopoverController presentPopoverFromRect:myRect
                                                      inView:self.target.view
                                    permittedArrowDirections:self.popoverArrowDirection
                                                    animated:YES];
        }
        
        if (self.showCompetion) self.showCompetion();
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
    CGSize size = CGSizeMake(self.pickerWidth, self.pickerHeight);
    self.myPopoverController =
    [[UIPopoverController alloc] initWithContentViewController:[self contentViewControllerWithSize:size]];
    self.myPopoverController.delegate = self;
    [self.myPopoverController setPopoverContentSize:size animated:YES];
    
    //layout picker view early
    [self.pickerView layoutIfNeeded];
    
    //present from UIBarButtonItem
    if ([self.sender isKindOfClass:[UIBarButtonItem class]]) {
        [self.myPopoverController presentPopoverFromBarButtonItem:self.sender
                                         permittedArrowDirections:self.popoverArrowDirection
                                                         animated:YES];
    }
    //present from any other view
    else if ([self.sender isKindOfClass:[UIView class]]) {
        UIView *view = (UIView *)self.sender;
        UIView *relativeSuperview = (UIView *)self.relativeSuperview;
        CGRect myRect = [relativeSuperview convertRect:view.frame toView:self.target.view];
        [self.myPopoverController presentPopoverFromRect:myRect
                                                  inView:self.target.view
                                permittedArrowDirections:self.popoverArrowDirection
                                                animated:YES];
    }
    
    if (self.showCompetion) self.showCompetion();
}

- (void)dismissPopover
{
    if (self.myPopoverController.popoverVisible) {
        [self.myPopoverController dismissPopoverAnimated:YES];
        
        if (self.hideCompetion) self.hideCompetion();
    }
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
                                            action:@selector(slideDown)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [self.overlay addGestureRecognizer:tapGesture];
}

- (void)slideUp
{
    /*self.completionType = CompletionTypeUnknown;*/
    
    // check if our date picker is already on screen
    if (!self.isVisible && self.pickerView.superview == nil) {
        
        //add background overlay
        [self addOverlay];
        
        //assign size to picker
        self.pickerView.frame = CGRectMake(0,0,self.pickerWidth, self.pickerHeight);
        
        //add to superview
        [self.target.view addSubview:self.pickerView];
        
        CGSize pickerSize = [self.pickerView sizeThatFits:CGSizeZero];
        self.pickerView.frame = CGRectMake(0,0,pickerSize.width,pickerSize.height);
        
        // size up the picker view to our screen and compute the start/end frame origin for our slide up animation
        //
        // compute the start frame
        CGSize pickerViewContainerSize = CGSizeMake(pickerSize.width, pickerSize.height);
        CGRect startRect = CGRectMake(0.0,
                                      self.target.view.bounds.size.height,
                                      pickerViewContainerSize.width,
                                      pickerViewContainerSize.height);
        
        self.pickerView.frame = startRect;
        
        // compute the end frame
        CGRect pickerRect = CGRectMake(0.0,
                                       self.target.view.bounds.size.height - pickerViewContainerSize.height,
                                       pickerViewContainerSize.width,
                                       pickerViewContainerSize.height);
        // start the slide up animation
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationWillStartSelector:@selector(slideWillStartStop)];
        [UIView setAnimationDuration:0.3];
        
        // we need to perform some post operations after the animation is complete
        [UIView setAnimationDelegate:self];
        
        self.pickerView.frame = pickerRect;
        self.overlay.backgroundColor = [UIColor colorWithWhite:0.2f alpha:0.5f];
        
        [UIView commitAnimations];
    }
}

- (void)slideDown
{
    if (self.isVisible && self.pickerView.superview != nil) {
        
        CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
        CGRect endFrame = self.pickerView.frame;
        endFrame.origin.y = screenRect.origin.y + screenRect.size.height;
        
        // start the slide down animation
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        // we need to perform some post operations after the animation is complete
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(slideDownDidStop)];
        
        self.pickerView.frame = endFrame;
        self.overlay.alpha = 0.0f;
        
        [UIView commitAnimations];
    }
}

- (void)slideWillStartStop
{
    //set boolean
    self.visible = YES;
    
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
    
    if (self.hideCompetion) self.hideCompetion();
}

#pragma mark -
#pragma mark IBAction

- (void)cancelAction:(id)sender
{
    [self dismissPickerWithCompletion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(cancelActionCallback:)]) {
            [self.delegate cancelActionCallback:sender];
        }
    }];
}

- (void)doneAction:(id)sender
{
    [self dismissPickerWithCompletion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(doneActionCallback:)]) {
            [self.delegate doneActionCallback:sender];
        }
    }];
}

@end
