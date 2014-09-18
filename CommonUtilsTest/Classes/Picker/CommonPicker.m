//  Created by Karen Lusinyan on 6/21/12.
//  Copyright (c) 2012 Home. All rights reserved.

#import "CommonPicker.h"

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
@property (readwrite, nonatomic, strong) UIView *overlay;
@property (readwrite, nonatomic, retain) UIView *pickerView;
@property (readwrite, nonatomic, retain) UIToolbar *toolbar;
@property (readwrite, nonatomic, retain) NSString *title;
@property (readwrite, nonatomic, retain) NSArray *items;
@property (readwrite, nonatomic, retain) UIPickerView *picker;
@property (readwrite, nonatomic, strong) NSString *selectedItem;
@property (readwrite, nonatomic, assign) NSInteger selectedIndex;
@property (readwrite, nonatomic, getter=isVisible) BOOL visible;

@property (readwrite, nonatomic, strong) UIPopoverController *myPopoverController;

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
        [self showPicker];
    }
    else {
        CGSize size = CGSizeMake(320.0f, 260.0f);
        self.myPopoverController =
        [[UIPopoverController alloc] initWithContentViewController:[self contentViewControllerWithSize:size]];
        self.myPopoverController.delegate = self;
        [self.myPopoverController setPopoverContentSize:size animated:YES];
        [self.myPopoverController presentPopoverFromBarButtonItem:self.sender
                                         permittedArrowDirections:UIPopoverArrowDirectionAny
                                                         animated:YES];
    }
}

- (void)dismissPickerWithCompletion:(void (^)(void))completion
{
    self.hideCompetion = completion;
    
    if (iPhone) {
        [self hidePicker];
    }
    else {
        if (self.myPopoverController.popoverVisible) {
            [self.myPopoverController dismissPopoverAnimated:YES];
            if (self.hideCompetion) self.hideCompetion();
        }
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
    self.pickerView = [[UIView alloc] init];
    //self.pickerView.backgroundColor = [UIColor greenColor];
    
    self.toolbar = [[UIToolbar alloc] init];
    self.toolbar.translatesAutoresizingMaskIntoConstraints = NO;
    //self.toolbar.barTintColor = [UIColor yellowColor];
    [self.pickerView addSubview:self.toolbar];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                            target:self
                                                                            action:@selector(buttonCancelPressed:)];
    
    UIBarButtonItem *flex1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                          target:nil
                                                                          action:NULL];

    UIBarButtonItem *title = [[UIBarButtonItem alloc] initWithTitle:self.title
                                                              style:UIBarButtonItemStylePlain
                                                             target:nil
                                                             action:NULL];

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
    if (self.isVisible) {
        [self hidePicker];

        if (self.showWhenOrientationDidChange) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self showPicker];
            });
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
    
    UITapGestureRecognizer* tapGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(hidePicker)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    tapGesture.cancelsTouchesInView = NO;
    [self.overlay addGestureRecognizer:tapGesture];
}

- (void)showPicker
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
        [UIView setAnimationDidStopSelector:@selector(slideUpDidStop)];
        [UIView setAnimationDuration:0.3];
        
        // we need to perform some post operations after the animation is complete
        [UIView setAnimationDelegate:self];
        
        self.pickerView.frame = pickerRect;
        self.overlay.backgroundColor = [UIColor colorWithWhite:0.2f alpha:0.5f];
        
        [UIView commitAnimations];
    }
}

- (void)slideUpDidStop
{
    if (self.showCompetion) self.showCompetion();
    self.visible = YES;
}

- (void)slideDownDidStop
{
    if (self.completionType == CompletionTypeCancel) {
        if (self.cancelCompletion) self.cancelCompletion();
    }
    else if (self.completionType == CompletionTypeDone) {
        if (self.doneCompletion) self.doneCompletion(self.selectedItem, self.selectedIndex);
    }
    
	// the date picker has finished sliding downwards, so remove it
	[self.pickerView removeFromSuperview];
    
    if (self.hideCompetion) self.hideCompetion();
    [self.overlay removeFromSuperview];
    self.overlay = nil;
    self.visible = NO;
}

- (void)hidePicker
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
        [self hidePicker];
    }
    else if (self.myPopoverController.popoverVisible) {
        [self.myPopoverController dismissPopoverAnimated:YES];
        if (self.cancelCompletion) self.cancelCompletion();
    }
}

- (void)buttonDonePressed:(id)sender
{
    self.completionType = CompletionTypeDone;
    
    if (iPhone) {
        [self hidePicker];
    }
    else if (self.myPopoverController.popoverVisible) {
        [self.myPopoverController dismissPopoverAnimated:YES];
        if (self.doneCompletion) self.doneCompletion(self.selectedItem, self.selectedIndex);
    }
}

@end
