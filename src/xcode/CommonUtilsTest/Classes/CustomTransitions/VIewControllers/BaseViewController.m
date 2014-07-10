//  Created by Karen Lusinyan on 02/04/14.
//  Copyright (c) 2014 BtB Mobile. All rights reserved.

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)dealloc
{
    //do something
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //custom init
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)updateUI
{
    //override
}

- (void)dismissController:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        //do something
    }];
}

#pragma mark -
#pragma mark KLSegmentedControllerDelegate delegate methods

- (void)segmentedControllerDidSelect
{
    [self updateUI];
}

@end
