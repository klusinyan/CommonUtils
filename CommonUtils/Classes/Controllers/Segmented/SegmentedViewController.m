//  Created by Karen Lusinyan on 10/04/14.
//  Copyright (c) 2012 Home. All rights reserved.

#import "SegmentedViewController.h"

#define kTest NO

@interface SegmentedViewController ()

@property (readwrite, nonatomic, strong) UIView *toolbar;
@property (readwrite, nonatomic, strong) UISegmentedControl *segmentedControl;
@property (readwrite, nonatomic, strong) UIView *contentView;
@property (readwrite, nonatomic, strong) UILabel *lblMessage;
@property (readwrite, nonatomic, strong) NSArray *viewControllers;
@property (readwrite, nonatomic, strong) UIViewController *selectedViewController;

//swipe gesture
@property (readwrite, nonatomic, strong) UISwipeGestureRecognizer *leftSwipe;
@property (readwrite, nonatomic, strong) UISwipeGestureRecognizer *rightSwipe;

@end

@implementation SegmentedViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ Failed to call designated initializer. Invoke `initWithViewControllers:` instead.", NSStringFromClass([self class])] userInfo:nil];
}

- (id)initWithViewControllers:(NSArray *)viewControllers
{
    self = [super init];
    if (self) {
        self.viewControllers = viewControllers;
        self.useToolBar = YES;
        self.enableSwipe = NO;
        self.selectedIndex = 0;
    }
    
    return self;
}

//override to setup addional UI components es: headerView
- (void)setupCustomUI
{
    //override
}

- (void)loadView
{
    [self setupCustomUI];
    
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.toolbar = (self.useToolBar) ? [[UIToolbar alloc] init] : [[UIView alloc] init];
    if (kTest) {
        self.toolbar.backgroundColor = [UIColor redColor];
    }
    self.toolbar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.toolbar];
    
    self.contentView = [[UIView alloc] init];
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentView.backgroundColor = (self.versioneTest) ? [UIColor greenColor] : [UIColor clearColor];
    [self.view addSubview:self.contentView];
    
    if ([self.viewControllers count] == 0) {
        self.lblMessage = [[UILabel alloc] init];
        self.lblMessage.translatesAutoresizingMaskIntoConstraints = NO;
        self.lblMessage.font = [UIFont systemFontOfSize:(iPad) ? 20 : 14];
        self.lblMessage.numberOfLines = 0;
        self.lblMessage.textColor = [UIColor grayColor];
        self.lblMessage.layer.shadowColor = [UIColor whiteColor].CGColor;
        self.lblMessage.layer.shadowOffset = CGSizeMake(1, 1);
        self.lblMessage.text = @"[KL]: Please, insert at least one viewcontroller inside of container and implement <SegmentedControllerDelegate> to receive changes from segementedControl.";
        [self.lblMessage sizeToFit];
        [self.contentView addSubview:self.lblMessage];
        
        CGFloat defaultHeight = 40;
        CGSize maximumLabelSize = CGSizeMake(220.0f, CGFLOAT_MAX);
        CGRect rect = [self.lblMessage.text boundingRectWithSize:maximumLabelSize
                                                         options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                      attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:(iPad) ? 20 : 14]}
                                                         context:nil];
        CGFloat maxHeight = fmaxf(defaultHeight, rect.size.height + 45.0f);
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_contentView]|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:NSDictionaryOfVariableBindings(_contentView)]];
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_contentView]|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:NSDictionaryOfVariableBindings(_contentView)]];
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=20)-[_lblMessage]-(>=20)-|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:NSDictionaryOfVariableBindings(_lblMessage)]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.lblMessage
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1
                                                               constant:maxHeight]];
        ///*
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.lblMessage
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1
                                                               constant:0]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.lblMessage
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1
                                                               constant:0]];
        //*/
        
    }
    else if ([self.viewControllers count] == 1) {
        if (self.headerView) {
            [self.view addSubview:self.headerView];
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_headerView]|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:NSDictionaryOfVariableBindings(_headerView)]];
            
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_headerView][_contentView]|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:NSDictionaryOfVariableBindings(_headerView, _toolbar, _contentView)]];
            
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.headerView
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1
                                                                   constant:self.headerHeight]];
            
        }
        else {
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_contentView]|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:NSDictionaryOfVariableBindings(_toolbar, _contentView)]];
        }
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_contentView]|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:NSDictionaryOfVariableBindings(_contentView)]];
    }
    else if ([self.viewControllers count] > 1) {
        if (self.headerView) {
            [self.view addSubview:self.headerView];
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_headerView]|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:NSDictionaryOfVariableBindings(_headerView)]];
            
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_headerView][_toolbar(==44)][_contentView]|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:NSDictionaryOfVariableBindings(_headerView, _toolbar, _contentView)]];
            
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.headerView
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1
                                                                   constant:self.headerHeight]];
            
        }
        else {
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_toolbar(==44)][_contentView]|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:NSDictionaryOfVariableBindings(_toolbar, _contentView)]];
        }
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_toolbar]|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:NSDictionaryOfVariableBindings(_toolbar)]];
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_contentView]|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:NSDictionaryOfVariableBindings(_contentView)]];
        
        NSMutableArray *titles = [NSMutableArray array];
        for (int i = 0; i <  [self.viewControllers count]; i++) {
            NSString *title = [[self.viewControllers objectAtIndex:i] valueForKeyPath:@"title"];
            if (!title) {
                title = [NSString stringWithFormat:@"ControllerTitle[%d]", i+1];
            }
            [titles addObject:title];
        }
        self.segmentedControl = [[UISegmentedControl alloc] initWithItems:titles];
        self.segmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
        /* //not used
         if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
         self.segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
         }
         //*/
        ////[self.segmentedControl sizeToFit];
        
        if (self.useToolBar) {
            //header is UIToolbar
            UIBarButtonItem *flexLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                      target:nil
                                                                                      action:nil];
            
            UIBarButtonItem *segmented = [[UIBarButtonItem alloc] initWithCustomView:self.segmentedControl];
            
            
            UIBarButtonItem *flexRight = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                       target:nil
                                                                                       action:nil];
            
            ((UIToolbar *)self.toolbar).items = @[flexLeft, segmented, flexRight];
        }
        else {
            //header is UIView
            [self.toolbar addSubview:self.segmentedControl];
        }
        
        //SEL
        [self.segmentedControl addTarget:self
                                  action:@selector(segmentedControlDidChange:)
                        forControlEvents:UIControlEventValueChanged];
        
        
        //constraints to segmented control
        [self.toolbar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(==10)-[_segmentedControl]-(==10)-|"
                                                                             options:NSLayoutFormatAlignAllCenterX | NSLayoutFormatAlignAllCenterY
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_segmentedControl)]];
        
        [self.toolbar addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControl
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.toolbar
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1
                                                                  constant:0]];
        
        [self.toolbar addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControl
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.toolbar
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1
                                                                  constant:0]];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //remove later...
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    //se ce' solo un controller
    if ([self.viewControllers count] == 1) {
        self.delegate = [self.viewControllers objectAtIndex:0];
        [self loadViewController:self.delegate];
    }
    //se ci sono piu' di un controller
    else if ([self.viewControllers count] > 1) {
        self.segmentedControl.selectedSegmentIndex = self.selectedIndex;
        [self segmentedControlDidChange:nil];
    }
    
    if (self.enableSwipe) {
        self.leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)];
        self.leftSwipe.cancelsTouchesInView = YES;
        self.leftSwipe.delaysTouchesBegan = YES;
        self.leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
        [self.view addGestureRecognizer:self.leftSwipe];
        
        self.rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)];
        self.rightSwipe.cancelsTouchesInView = YES;
        self.rightSwipe.delaysTouchesBegan = YES;
        self.rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
        [self.view addGestureRecognizer:self.rightSwipe];
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

- (void)loadViewController:(id<SegmentedControllerDelegate>)delegate
{
    UIViewController *previousVC = [self.viewControllers objectAtIndex:self.selectedIndex];
    [previousVC.view removeFromSuperview];
    [previousVC removeFromParentViewController];
    
    if ([delegate isKindOfClass:[UIViewController class]]) {
        UIViewController *vc = (UIViewController *)delegate;
        vc.view.translatesAutoresizingMaskIntoConstraints = NO;
        [self addChildViewController:vc];
        [self.contentView addSubview:vc.view];
        
        self.selectedViewController = vc;
        self.selectedIndex = self.segmentedControl.selectedSegmentIndex;
        
        NSDictionary *binding = @{@"subview" : vc.view};
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[subview]|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:binding]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[subview]|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:binding]];
    }
    
    if ([delegate respondsToSelector:@selector(segmentedControllerDidSelect)]) {
        [delegate segmentedControllerDidSelect];
    }
    if ([delegate respondsToSelector:@selector(segmentedControllerDidSelect:)]) {
        [delegate segmentedControllerDidSelect:self];
    }
    
    //calls for subclasses to override by implementing additional features
    [self viewControllerDidLoad:delegate atIndex:self.selectedIndex];
}

- (void)loadViewControllerWithIndex:(NSInteger)index
{
    if ([self.viewControllers count] > index) {
        self.segmentedControl.selectedSegmentIndex = index;
        id<SegmentedControllerDelegate> controllerWithIndex = [self.viewControllers objectAtIndex:index];
        [self loadViewController:controllerWithIndex];
    }
}

//override
- (void)viewControllerDidLoad:(id<SegmentedControllerDelegate>)viewController atIndex:(NSInteger)index
{
    //do nothing
}

#pragma mark -
#pragma mark IBActions

- (void)segmentedControlDidChange:(id)sender
{
    self.delegate = [self.viewControllers objectAtIndex:self.segmentedControl.selectedSegmentIndex];
    [self loadViewController:self.delegate];
}

#pragma mark -
#pragma mark UISwipeGestureRecognizer methods

- (void)swipeGesture:(UISwipeGestureRecognizer *)swipeGesture
{
    NSInteger currentIndex = self.segmentedControl.selectedSegmentIndex;
    
    if (swipeGesture.direction == UISwipeGestureRecognizerDirectionLeft) {
        //DebugLog(@" *** SWIPE LEFT ***");
        if (currentIndex > 2) {
            return;
        }
        //fisrt end editing the VC
        UIViewController *vc = [self.viewControllers objectAtIndex:currentIndex];
        [vc.view endEditing:YES];
        currentIndex++;
        [self loadViewControllerWithIndex:currentIndex];
    }
    else if (swipeGesture.direction == UISwipeGestureRecognizerDirectionRight) {
        //DebugLog(@" *** SWIPE RIGHT ***");
        if (currentIndex == 0) {
            return;
        }
        //fisrt end editing the VC
        UIViewController *vc = [self.viewControllers objectAtIndex:currentIndex];
        [vc.view endEditing:YES];
        currentIndex--;
        [self loadViewControllerWithIndex:currentIndex];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.selectedViewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.selectedViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

@end
