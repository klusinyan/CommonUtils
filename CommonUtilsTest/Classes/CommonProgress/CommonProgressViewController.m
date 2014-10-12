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
                                                                                  action:@selector(hideCommonProgress:)];
    self.navigationItem.rightBarButtonItems = @[showProgress];
    
    BOOL random = arc4random_uniform(2);
    [CommonProgress showWithTaregt:self completion:^{
        DebugLog(@"common progress did start");
    }];
    [CommonProgress sharedProgress].activityIndicatorViewStyle = (random) ? CommonProgressActivityIndicatorViewStyleLarge : CommonProgressActivityIndicatorViewStyleNormal;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CommonProgressViewController *vc = [[CommonProgressViewController alloc] initWithNibName:NSStringFromClass([CommonProgressViewController class]) bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    });
}

- (void)hideCommonProgress:(id)sender
{
    [CommonProgress hideWithCompletion:^{
        DebugLog(@"common progress did stop");
    }];
}

@end
