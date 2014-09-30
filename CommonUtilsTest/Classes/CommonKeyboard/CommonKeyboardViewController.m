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

- (void)dealloc
{
    [CommonKeyboard unregisterRespondersForClass:[self class]];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
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

    [CommonKeyboard registerClass:[self class] withResponders:@[self.textField1, self.textView]];
}

- (CGFloat)keyboardOffset
{
    return 10;
}

- (void)keyboardDidShowWithResponder:(id)responder
{
    DebugLog(@"responder %@", responder);
}

- (void)keyboardWillHideWithResponder:(id)responder
{
    DebugLog(@"responder %@", responder);
}

@end
