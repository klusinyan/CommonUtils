//  Created by Karen Lusinyan on 26/04/14.
//  Copyright (c) 2014 Karen Lusinyan. All rights reserved.

#import "NavigationControllerController.h"
#import "MainViewController.h"

@interface NavigationControllerController ()

@end

@implementation NavigationControllerController

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
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    if ([self.topViewController conformsToProtocol:@protocol(MainViewControllerDelegate)]) {
        id<MainViewControllerDelegate> controller = (id<MainViewControllerDelegate>)self.topViewController;
        if ([controller respondsToSelector:@selector(setAnimating:)]) {
            return !controller.isAnimating;
        }
    }
    return YES;
}

@end
