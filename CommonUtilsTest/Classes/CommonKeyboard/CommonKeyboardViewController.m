//  Created by Karen Lusinyan on 23/09/14.
//  Copyright (c) 2014 Karen Lusinyan. All rights reserved.

#import "CommonKeyboardViewController.h"
#import "CommonKeyboard.h"

@interface CommonKeyboardViewController () <CommonKeyboardDelegate, CommonKeyboardDataSource>

@property (readwrite, nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (readwrite, nonatomic, strong) IBOutlet UIView *contentView;
@property (readwrite, nonatomic, strong) IBOutlet UITextField *textField1;
@property (readwrite, nonatomic, strong) IBOutlet UITextField *textField2;
@property (readwrite, nonatomic, strong) IBOutlet UITextField *textField3;
@property (readwrite, nonatomic, strong) IBOutlet UITextView *textView;
@property (readwrite, nonatomic, strong) id actviveResponder;
@property (readwrite, nonatomic, strong) CommonKeyboard *commonKeyboard;

@end

@implementation CommonKeyboardViewController

///*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
//*/

/*
- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
}
//*/

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //self.edgesForExtendedLayout = UIRectEdgeNone;
    
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                      attribute:NSLayoutAttributeLeading
                                                                      relatedBy:0
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeLeft
                                                                     multiplier:1.0
                                                                       constant:0];
    [self.view addConstraint:leftConstraint];
    
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                       attribute:NSLayoutAttributeTrailing
                                                                       relatedBy:0
                                                                          toItem:self.view
                                                                       attribute:NSLayoutAttributeRight
                                                                      multiplier:1.0
                                                                        constant:0];
    [self.view addConstraint:rightConstraint];

    self.commonKeyboard = [[CommonKeyboard alloc] initWithTarget:self.scrollView];
    self.commonKeyboard.dataSource = self;
    self.commonKeyboard.delegate = self;

    [CommonKeyboard registerResponders:@[self.textField1, self.textView]];
    
    //[CommonKeyboard registerForKeyboardNotification:self.textField2];
    //[CommonKeyboard registerForKeyboardNotification:self.textField3];
    
    /*
    UIScrollView *myScrollView = nil;
    UIImageView *imageView = nil;
    NSDictionary *viewsDictionary = nil;
    
    // Create the scroll view and the image view.
    myScrollView  = [[UIScrollView alloc] init];
    myScrollView.backgroundColor = [UIColor yellowColor];
    imageView = [[UIImageView alloc] init];
    
    // Add an image to the image view.
    [imageView setImage:[UIImage imageNamed:@"apple"]];
    [imageView setContentMode:UIViewContentModeScaleAspectFill];
    
    // Add the scroll view to our view.
    [self.view addSubview:myScrollView];
    
    // Add the image view to the scroll view.
    [myScrollView addSubview:imageView];
    
    // Set the translatesAutoresizingMaskIntoConstraints to NO so that the views autoresizing mask is not translated into auto layout constraints.
    myScrollView.translatesAutoresizingMaskIntoConstraints  = NO;
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Set the constraints for the scroll view and the image view.
    viewsDictionary = NSDictionaryOfVariableBindings(myScrollView, imageView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-100-[myScrollView]-100-|" options:0 metrics: 0 views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-100-[myScrollView]-100-|" options:0 metrics: 0 views:viewsDictionary]];
    [myScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]|" options:0 metrics: 0 views:viewsDictionary]];
    [myScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView]|" options:0 metrics: 0 views:viewsDictionary]];
    //*/
}

///*
- (UIView *)activeView
{
    if ([self.textField1 isFirstResponder]) return self.textField1;
    return nil;
}
//*/
 
///*
- (CGFloat)offset
{
    return 10;
}
//*/

- (void)keyboardDidShowWithResponder:(id)responder
{
    DebugLog(@"responder %@", responder);
}

- (void)keyboardWillHideWithResponder:(id)responder
{
    DebugLog(@"responder %@", responder);
}

@end
