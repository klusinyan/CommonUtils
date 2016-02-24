//  Created by Karen Lusinyan on 04/06/14.

#import "CustomSplitController.h"
#import "SplitViewController.h"

@interface CustomSplitController ()

@end

@implementation CustomSplitController

- (void)dealloc
{
    //do something
}

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
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    view.autoresizesSubviews = YES;
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor greenColor];
    
    SplitViewController *splitController = [[SplitViewController alloc] init];
    //splitController.view.backgroundColor = [UIColor blackColor];
    splitController.shadowRadius = 1;
    splitController.menuOverlay = 10;
    //splitController.openningAnimationDuration = 0.3;
    //splitController.closingAnimationDuration = 0.3;
    //splitController.openningTimingFunctionName = kCAMediaTimingFunctionEaseInEaseOut;
    //splitController.closingTimingFunctionName = kCAMediaTimingFunctionEaseInEaseOut;
    splitController.menuMode = MenuModeShownAlways;
    splitController.menuWidth = 200;
    
    [self addChildViewController:splitController];
    [self.view addSubview:splitController.view];
    
    //configure master and detail
    UIViewController *masterController = [[UIViewController alloc] init];
    masterController.view.backgroundColor = [UIColor redColor];
    
    UIViewController *detailController = [[UIViewController alloc] init];
    detailController.view.backgroundColor = [UIColor lightGrayColor];
    
    [splitController addMasterController:masterController animated:NO];
    [splitController addDetailController:detailController animated:NO];
    
    //masterController.navigationController.navigationBarHidden = YES;
    //detailController.navigationController.navigationBarHidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma Rotation methods

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (BOOL) shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

@end
