//  Created by Nicco on 03/04/14.
//  Copyright (c) 2014 BtB Mobile. All rights reserved.

#import "CommonBanner.h"

@interface UIView (Layout)

- (void)layoutAttributeCenterX;

- (void)layoutAttributeCenterY;

- (void)layoutAttributeWithSize:(CGSize)size
               attributeCenterX:(BOOL)attributeCenterX
               attributeCenterY:(BOOL)attributeCenterY;

- (void)layoutAttributeCenterX_Y;

@end

@implementation UIView (Layout)

- (void)layoutAttributeCenterX
{
    NSLayoutConstraint *c = [NSLayoutConstraint constraintWithItem:self
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.superview
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1
                                                          constant:0];
    [self.superview addConstraint:c];
}

- (void)layoutAttributeCenterY
{
    NSLayoutConstraint *c = [NSLayoutConstraint constraintWithItem:self
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.superview
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1
                                                          constant:0];
    [self.superview addConstraint:c];
}

- (void)layoutAttributeCenterX_Y
{
    [self layoutAttributeCenterX];
    [self layoutAttributeCenterY];
}

- (void)layoutAttributeWithSize:(CGSize)size
{
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:self
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:1
                                                              constant:size.width];
    
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:self
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1
                                                               constant:size.height];
    
    [self.superview addConstraints:@[width, height]];
}

- (void)layoutAttributeWithSize:(CGSize)size
               attributeCenterX:(BOOL)attributeCenterX
               attributeCenterY:(BOOL)attributeCenterY
{
    
    [self layoutAttributeWithSize:size];
    if (attributeCenterX) {
        [self layoutAttributeCenterX];
    }
    if (attributeCenterY) {
        [self layoutAttributeCenterY];
    }
}

@end

#import "FirstViewController.h"

@interface FirstViewController ()

@property (readwrite, nonatomic, strong) UIView *containerView;
@property (readwrite, nonatomic, strong) UITextField *textFieldUsername;
@property (readwrite, nonatomic, strong) UITextField *textFieldPassword;
@property (readwrite, nonatomic, strong) UIButton *buttonLogin;
@property (readwrite, nonatomic, strong) UIButton *buttonGuest;
@property (readwrite, nonatomic, strong) UILabel *labelOppure;

@end

@implementation FirstViewController

- (id)init
{
    self = [super init];
    if (self) {
        //custom init
    }
    return self;
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    self.containerView = [[UIView alloc] init];
    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.containerView.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.containerView];
    
    self.textFieldUsername = [[UITextField alloc] init];
    self.textFieldUsername.borderStyle = UITextBorderStyleRoundedRect;
    self.textFieldUsername.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:self.textFieldUsername];
    
    self.textFieldPassword = [[UITextField alloc] init];
    self.textFieldPassword.translatesAutoresizingMaskIntoConstraints = NO;
    self.textFieldPassword.borderStyle = UITextBorderStyleRoundedRect;
    [self.containerView addSubview:self.textFieldPassword];
    
    self.buttonLogin = [UIButton buttonWithType:UIButtonTypeCustom];
    self.buttonLogin.translatesAutoresizingMaskIntoConstraints = NO;
    self.buttonLogin.backgroundColor = [UIColor blueColor];
    [self.buttonLogin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.buttonLogin setTitle:@"Login" forState:UIControlStateNormal];
    [self.containerView addSubview:self.buttonLogin];

    self.buttonGuest = [UIButton buttonWithType:UIButtonTypeCustom];
    self.buttonGuest.translatesAutoresizingMaskIntoConstraints = NO;
    self.buttonGuest.backgroundColor = [UIColor blueColor];
    [self.buttonGuest setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.buttonGuest setTitle:@"Prosegui senza registrati" forState:UIControlStateNormal];
    [self.containerView addSubview:self.buttonGuest];
    
    self.labelOppure = [[UILabel alloc] init];
    self.labelOppure.translatesAutoresizingMaskIntoConstraints = NO;
    self.labelOppure.text = @"Oppure";
    self.labelOppure.textAlignment = NSTextAlignmentCenter;
    [self.containerView addSubview:self.labelOppure];

    if (iPhone) {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_containerView]-|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:NSDictionaryOfVariableBindings(_containerView)]];
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_containerView]-|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:NSDictionaryOfVariableBindings(_containerView)]];
    }
    if (iPad) {
        [self.containerView layoutAttributeWithSize:CGSizeMake(300, 480) attributeCenterX:YES attributeCenterY:YES];
    }

    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_textFieldUsername(>=100)]-10-|"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:NSDictionaryOfVariableBindings(_textFieldUsername)]];

    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_textFieldPassword(>=100)]-10-|"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:NSDictionaryOfVariableBindings(_textFieldPassword)]];

    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_buttonLogin(>=100)]-10-|"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:NSDictionaryOfVariableBindings(_buttonLogin)]];

    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_labelOppure(>=100)]-10-|"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:NSDictionaryOfVariableBindings(_labelOppure)]];

    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_buttonGuest(>=100)]-10-|"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:NSDictionaryOfVariableBindings(_buttonGuest)]];

    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_textFieldUsername(<=40)]-10-[_textFieldPassword(<=40)]-10-[_buttonLogin(<=40)]->=10-[_labelOppure(<=30)]-20-[_buttonGuest(<=40)]-(>=30)-|"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:NSDictionaryOfVariableBindings(_textFieldUsername, _textFieldPassword, _buttonLogin, _labelOppure, _buttonGuest)]];

    
    

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.canDisplayAds = NO;
}

- (void)segmentedController:(UIViewController *)segmentedController
            didSelectConent:(id<CommonSegmentedControllerDelegate>)content
                    atIndex:(NSInteger)index
{
    DebugLog(@"segmentedController %@", segmentedController);
    DebugLog(@"content %@", content);
    DebugLog(@"index %@", @(index));
    
    /*
    UIAlertView *segmetnedGray = [[UIAlertView alloc] initWithTitle:@"Segemented Gray"
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
    
    [segmetnedGray show];
    //*/
}


@end
