//  Created by Karen Lusinyan on 13/02/15.
//  Copyright (c) 2015 Karen Lusinyan. All rights reserved.

#import "CommonLoadingViewController.h"
#import "CommonSpinner.h"

@interface CommonLoadingViewController ()

@property (readwrite, nonatomic, assign) id target;

@end

@implementation CommonLoadingViewController

- (void)dealloc
{
   //do something
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

+ (instancetype)instanceWithTarget:(id)target
{
    CommonLoadingViewController *instance = [[self alloc] init];
    instance.target = target;
    
    UIView *view = ((UIViewController *)target).view;
    for (UIView *subview in [view subviews]) {
        subview.hidden = NO;
    }

    return instance;
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = self.backgroundColor;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [CommonSpinner setHidesWhenStopped:YES];
    [CommonSpinner setTitle:@"iCoop Mobile"];
    //[CommonSpinner sharedSpinner].timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [CommonSpinner showInView:self.view completion:^{

        }];
    });
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.target view].hidden = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
}

@end
