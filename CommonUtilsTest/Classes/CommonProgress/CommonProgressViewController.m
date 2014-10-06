//  Created by Karen Lusinyan on 06/10/14.
//  Copyright (c) 2014 Karen Lusinyan. All rights reserved.

#import "CommonProgressViewController.h"
#import "CommonProgress.h"

@interface CommonProgressViewController ()

@end

@implementation CommonProgressViewController

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
    
    UIBarButtonItem *showProgress = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                  target:self
                                                                                  action:@selector(showProgress:)];
    self.navigationItem.rightBarButtonItems = @[showProgress];
    
    [self showProgress:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)showProgress:(id)sender
{
    __block CommonProgress *commonProgress = [CommonProgress commonProgressWithTarget:self blur:YES];
    commonProgress.activityIndicatorViewStyle = CommonProgressActivityIndicatorViewStyleLarge;
    [commonProgress startAnimating];
    
    /*
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        commonProgress = [CommonProgress commonProgressWithTarget:self];
        [commonProgress startAnimating];
    });
    //*/
}


@end
