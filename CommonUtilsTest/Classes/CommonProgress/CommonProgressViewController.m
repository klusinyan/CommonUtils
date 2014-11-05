//  Created by Karen Lusinyan on 06/10/14.
//  Copyright (c) 2014 Karen Lusinyan. All rights reserved.

#import "CommonProgressViewController.h"
#import "CommonProgress.h"

@interface CommonProgressViewController ()

@end

@implementation CommonProgressViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
    
    UIBarButtonItem *showProgress = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                  target:self
                                                                                  action:@selector(showHideCommonProgress:)];
    self.navigationItem.rightBarButtonItems = @[showProgress];
    
    //BOOL random = arc4random_uniform(3);
    [CommonProgress sharedProgress].backgroundImageColor = [UIColor colorWithWhite:0.5 alpha:0.8];
    [CommonProgress sharedProgress].activityIndicatorViewStyle = CommonProgressActivityIndicatorViewStyleSmall;
    [CommonProgress sharedProgress].indicatorImageColor = [UIColor greenColor];
    [CommonProgress sharedProgress].networkActivityIndicatorVisible = YES;
    

    [CommonProgress showWithTaregt:self completion:^{
        DebugLog(@"common progress did start");
    }];

    /*
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CommonProgressViewController *vc = [[CommonProgressViewController alloc] initWithNibName:NSStringFromClass([CommonProgressViewController class]) bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    });
    //*/
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self showHideCommonProgress:nil];
}

- (void)showHideCommonProgress:(id)sender
{
    if ([[CommonProgress sharedProgress] isAnimating] || !sender) {
        [CommonProgress hideWithCompletion:^{
            DebugLog(@"common progress did stop");
        }];
    }
    else {
        [CommonProgress showWithTaregt:self
                            completion:^{
                                DebugLog(@"common progress did start");
                            }];
    }
}

@end
