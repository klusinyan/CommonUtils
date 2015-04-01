//  Created by Karen Lusinyan on 21/05/14.
//  Copyright (c) 2014 Parrocchia. All rights reserved.

#import "ProgressViewController.h"
#import "ProgressView.h"

#import <CommonBanner.h>

@interface ProgressViewController ()

@end

@implementation ProgressViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    self.canDisplayAds = YES;
    self.animated = YES;
    
    ProgressView *progressView = [ProgressView defaultHUDWithSize:CGSizeMake(100, 100)];
    [progressView setActivityIndicatorOn:YES];
    [progressView showInView:self.view];
    
    //appearance
    progressView.borderColor = [UIColor whiteColor];
    progressView.borderWidth = 2;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(dismiss)];
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

@end
