//  Created by Karen Lusinyan on 21/11/14.
//  Copyright (c) 2014 Karen Lusinyan. All rights reserved.

#import "ChildViewController.h"
#import "UIViewController+ChildrenHandler.h"

@interface ChildViewController ()
<
ChildControllerDelegate
>

@end

@implementation ChildViewController
@synthesize controllerTransitionHandler;

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
