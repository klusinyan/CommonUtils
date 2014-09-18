//  Created by Karen Lusinyan on 6/21/12.
//  Copyright (c) 2012 Home. All rights reserved.

#import "CommonPicker.h"
#import "BlurView.h"

typedef NS_ENUM(NSInteger, CompletionType) {
    CompletionTypeUnknown=-1,
    CompletionTypeCancel,
    CompletionTypeDone
};

typedef void(^ShowCompletionHandler)(void);
typedef void(^HideCompletionHandler)(void);

@interface CommonPicker ()
<
UIPickerViewDelegate,
UIPickerViewDataSource,
UIPopoverControllerDelegate
>

@property (readwrite, nonatomic, assign) UIViewController *target;
@property (readwrite, nonatomic, assign) id sender;
@property (readwrite, nonatomic, strong) UIPopoverController *myPopoverController;
@property (readwrite, nonatomic, strong) UIView *overlay;
@property (readwrite, nonatomic, strong) BlurView *pickerView;
@property (readwrite, nonatomic, strong) UIToolbar *toolbar;
@property (readwrite, nonatomic, strong) NSString *title;
@property (readwrite, nonatomic, strong) NSArray *items;
@property (readwrite, nonatomic, strong) UIPickerView *picker;
@property (readwrite, nonatomic, strong) NSString *selectedItem;
@property (readwrite, nonatomic, assign) NSInteger selectedIndex;
@property (readwrite, nonatomic, assign) BOOL showWhenOrientationDidChange;
@property (readwrite, nonatomic, getter = isVisible) BOOL visible;

@property (readwrite, nonatomic, copy) ShowCompletionHandler showCompetion;
@property (readwrite, nonatomic, copy) HideCompletionHandler hideCompetion;
@property (readwrite, nonatomic, copy) CancelCompletionHandler cancelCompletion;
@property (readwrite, nonatomic, copy) DoneCompletionHandler doneCompletion;
@property (readwrite, nonatomic, assign) CompletionType completionType;

@end

@implementation CommonPicker

#pragma mark -
#pragma mark public methods

- (instancetype)initWithTarget:(id)target
                        sender:(id)sender
                     withTitle:(NSString *)title
                         items:(NSArray *)items
              cancelCompletion:(CancelCompletionHandler)cancelCompletion
                doneCompletion:(DoneCompletionHandler)doneCompletion
{
    self = [super init];
    if (self) {
        self.target = (UIViewController *)target;
        self.sender = sender;
        self.title = title;
        self.items = items;
        self.cancelCompletion = cancelCompletion;
        self.doneCompletion = doneCompletion;
        
        //defaults
        self.completionType = CompletionTypeUnknown;
        self.showWhenOrientationDidChange = NO;
        self.selectedItem = ([self.items count] > 0) ? [self.items objectAtIndex:0] : nil;
        
        [self setupPicker];
    }
    return self;
}

- (UIViewController *)contentViewControllerWithSize:(CGSize)size
{
    UIViewController *contentController = [[UIViewController alloc] init];
    contentController.view.translatesAutoresizingMaskIntoConstraints = NO;
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


- (void)showPickerWithCompletion:(void (^)(void))completion
{
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

- (void)setupPicker
{
    self.pickerView = [[BlurView alloc] init];
    //self.pickerView.backgroundColor = [UIColor greenColor];
    
    self.toolbar = [[UIToolbar alloc] init];
    self.toolbar.translatesAutoresizingMaskIntoConstraints = NO;
    self.toolbar.barTintColor = [UIColor whiteColor];
    [self.pickerView addSubview:self.toolbar];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                            target:self
                                                                            action:@selector(buttonCancelPressed:)];
    
    UIBarButtonItem *flex1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                          target:nil
                                                                          action:NULL];

    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.textColor = [self.toolbar tintColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = ([self.title length] > 0) ? self.title : @"";
    label.font = [UIFont systemFontOfSize:18.0f];
    
    UIBarButtonItem *title = [[UIBarButtonItem alloc] initWithCustomView:label];

    UIBarButtonItem *flex2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                          target:nil
                                                                          action:NULL];

    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                          target:self
                                                                          action:@selector(buttonDonePressed:)];
    
    self.toolbar.items = @[cancel, flex1, title, flex2, done];
    
    self.picker = [[UIPickerView alloc] init];
    self.picker.delegate = self;
    self.picker.dataSource = self;
    //self.picker.backgroundColor = [UIColor redColor];
    self.picker.translatesAutoresizingMaskIntoConstraints = NO;
    [self.pickerView addSubview:self.picker];
    
    [self.pickerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_toolbar]|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:NSDictionaryOfVariableBindings(_toolbar)]];

    [self.pickerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_picker]|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:NSDictionaryOfVariableBindings(_picker)]];
    
    [self.pickerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_toolbar(==44)][_picker]|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:NSDictionaryOfVariableBindings(_toolbar, _picker)]];

    /*
    [self.pickerView addConstraint:[NSLayoutConstraint constraintWithItem:self.picker
                                                                attribute:NSLayoutAttributeCenterX
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.pickerView
                                                                attribute:NSLayoutAttributeCenterX
                                                               multiplier:1
                                                                 constant:0]];

    [self.pickerView addConstraint:[NSLayoutConstraint constraintWithItem:self.picker
                                                                attribute:NSLayoutAttributeCenterY
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.pickerView
                                                                attribute:NSLayoutAttributeCenterY
                                                               multiplier:1
                                                                 constant:0]];
     //*/
     
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

#pragma mark -
#pragma Rotation methods

- (void)orientationDidChange:(NSNotification *)notification
{
    if (iPhone) {
        if (self.visible) {
            [self dismissPickerWithCompletion:^{
                DebugLog(@"picker is hidden");
            }];
        }
    }
    else if ([self.myPopoverController isPopoverVisible]) {
        //present from UIBarButtonItem
        if ([self.sender isKindOfClass:[UIBarButtonItem class]]) {
            [self.myPopoverController presentPopoverFromBarButtonItem:self.sender
                                             permittedArrowDirections:UIPopoverArrowDirectionAny
                                                             animated:YES];
        }
        //present from any other view
        else if ([self.sender isKindOfClass:[UIView class]]) {
            UIView *view = (UIView *)self.sender;
            CGRect myRect = [self.target.view convertRect:view.frame toView:self.target.view];
            [self.myPopoverController presentPopoverFromRect:myRect
                                                      inView:self.target.view
                                    permittedArrowDirections:UIPopoverArrowDirectionAny
                                                    animated:YES];
        }
    }
}

- (void)showPopover
{
    CGSize size = CGSizeMake(320.0f, 260.0f);
    self.myPopoverController =
    [[UIPopoverController alloc] initWithContentViewController:[self contentViewControllerWithSize:size]];
    self.myPopoverController.delegate = self;
    [self.myPopoverController setPopoverContentSize:size animated:YES];
    
    //layout picker view early
    [self.pickerView layoutIfNeeded];
    
    //present from UIBarButtonItem
    if ([self.sender isKindOfClass:[UIBarButtonItem class]]) {
        [self.myPopoverController presentPopoverFromBarButtonItem:self.sender
                                         permittedArrowDirections:UIPopoverArrowDirectionAny
                                                         animated:YES];
    }
    //present from any other view
    else if ([self.sender isKindOfClass:[UIView class]]) {
        UIView *view = (UIView *)self.sender;
        CGRect myRect = [self.target.view convertRect:view.frame toView:self.target.view];
        [self.myPopoverController presentPopoverFromRect:myRect
                                                  inView:self.target.view
                                permittedArrowDirections:UIPopoverArrowDirectionAny
                                                animated:YES];
    }
}

- (void)dismissPopover
{
    if (self.myPopoverController.popoverVisible) {
        [self.myPopoverController dismissPopoverAnimated:YES];
        
        if (self.completionType == CompletionTypeCancel) {
            if (self.cancelCompletion) self.cancelCompletion();
        }
        else if (self.completionType == CompletionTypeDone) {
            if (self.doneCompletion) self.doneCompletion(self.selectedItem, self.selectedIndex);
        }
        else {
            if (self.hideCompetion) self.hideCompetion();
        }
    }
}

- (void)addOverlay
{
    self.overlay = [[UIView alloc] init];
    self.overlay.translatesAutoresizingMaskIntoConstraints = NO;
    self.overlay.backgroundColor = [UIColor colorWithWhite:0.2f alpha:0.0f];
    UIView *overlaySuperview = self.target.view;
    //TODO::
    //(self.target.navigationController.view) ? self.target.navigationController.view : self.target.view;
    
    [overlaySuperview addSubview:self.overlay];
    
    NSDictionary *bindings = @{@"overlay" : self.overlay};
    
    [overlaySuperview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[overlay]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:bindings]];
    
    [overlaySuperview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[overlay]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:bindings]];
    
    ///*
    UITapGestureRecognizer* tapGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(slideDown)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    tapGesture.cancelsTouchesInView = NO;
    [self.overlay addGestureRecognizer:tapGesture];
    //*/
}

- (void)slideUp
{
    self.completionType = CompletionTypeUnknown;
    
    // check if our date picker is already on screen
    if (self.pickerView.superview == nil) {
        
        //add background overlay
        [self addOverlay];
        
        //assign size to picker
        self.pickerView.frame = CGRectMake(0,0,self.target.view.frame.size.width, 260.0f);
        
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

- (void)slideWillStartStop
{
    if (self.showCompetion) self.showCompetion();

    //set boolean
    self.visible = YES;
}

- (void)slideDownDidStop
{
    // the date picker has finished sliding downwards, so remove it
	[self.pickerView removeFromSuperview];
    
    //remove overlay
    [self.overlay removeFromSuperview];
    
    //set boolean
    self.visible = NO;

    if (self.completionType == CompletionTypeCancel) {
        if (self.cancelCompletion) self.cancelCompletion();
    }
    else if (self.completionType == CompletionTypeDone) {
        if (self.doneCompletion) self.doneCompletion(self.selectedItem, self.selectedIndex);
    }
    else {
        if (self.hideCompetion) self.hideCompetion();
    }
}

- (void)slideDown
{
    if (self.pickerView.superview != nil) {
        
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

#pragma mark -
#pragma mark UIPickerViewDataSource protocol

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.items count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.items objectAtIndex:row];
}

#pragma mark -
#pragma mark UIPickerViewDelegate protocol

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.selectedItem = [self.items objectAtIndex:row];
    self.selectedIndex = row;
}

#pragma mark -
#pragma mark IBAction

- (void)buttonCancelPressed:(id)sender
{
    self.completionType = CompletionTypeCancel;
    
    if (iPhone) {
        [self slideDown];
    }
    else if (self.myPopoverController.popoverVisible) {
        [self.myPopoverController dismissPopoverAnimated:YES];
        [self dismissPopover];
    }
}

- (void)buttonDonePressed:(id)sender
{
    self.completionType = CompletionTypeDone;
    
    if (iPhone) {
        [self slideDown];
    }
    else if (self.myPopoverController.popoverVisible) {
        [self.myPopoverController dismissPopoverAnimated:YES];
        [self dismissPopover];
    }
}

@end
