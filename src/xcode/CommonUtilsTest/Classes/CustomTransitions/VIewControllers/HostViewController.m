//  Created by Karen Lusinyan on 02/07/14.

#import "HostViewController.h"
#import "MainViewController.h"

@interface HostViewController () <ViewPagerDataSource, ViewPagerDelegate>

@property (readwrite, nonatomic, assign) NSUInteger selectedIndex;
@property (readwrite, nonatomic, strong) MainViewController *vc1;
@property (readwrite, nonatomic, strong) MainViewController *vc2;
@property (readwrite, nonatomic, strong) MainViewController *vc3;
@property (readwrite, nonatomic, strong) NSArray *controllerStack;

@end

@implementation HostViewController

- (void)dealloc
{
    //do something
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.controllerStack = @[self.vc1, self.vc2, self.vc3];
    }
    return self;
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dataSource = self;
    self.delegate = self;
    
    [self reloadData];
}

#pragma mark -
#pragma mark - ViewPagerDataSource

- (NSUInteger)numberOfTabsForViewPager:(ViewPagerController *)viewPager
{
    return 3;
}

- (UIView *)viewPager:(ViewPagerController *)viewPager viewForTabAtIndex:(NSUInteger)index
{
    UILabel *label = [UILabel new];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:12.0];
    label.text = [NSString stringWithFormat:@"Tab #%ld", (long)index];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor lightGrayColor];
    [label sizeToFit];
    
    return label;
}

- (void)viewPager:(ViewPagerController *)viewPager contentViewForTab:(UIView *)view atIndex:(NSUInteger)index
{
    if ([view isKindOfClass:[UILabel class]]) {
        UILabel *label = (UILabel *)view;
        if (self.selectedIndex != index) {
            label.textColor = [UIColor lightGrayColor];
        }
        else {
            label.textColor = [UIColor blackColor];
        }
    }
}

- (void)viewPager:(ViewPagerController *)viewPager controllerForTab:(UIViewController *)controller atIndex:(NSUInteger)index
{
    DebugLog(@"controller %@", controller);
}

- (UIViewController *)viewPager:(ViewPagerController *)viewPager
contentViewControllerForTabAtIndex:(NSUInteger)index
{
    return self.controllerStack[index];
}

#pragma mark - ViewPagerDelegate
- (CGFloat)viewPager:(ViewPagerController *)viewPager
      valueForOption:(ViewPagerOption)option
         withDefault:(CGFloat)value
{
    switch (option) {
        case ViewPagerOptionStartFromSecondTab:
            return 0.0;
        case ViewPagerOptionCenterCurrentTab:
            return 1.0;
        case ViewPagerOptionTabLocation:
            return 1.0;
        case ViewPagerOptionTabOriginX:
            return 0.0;
        case ViewPagerOptionTabOriginY:
            return -1.0;
        case ViewPagerOptionTabHeight:
            return 49.0;
        case ViewPagerOptionTabOffset:
            return 36.0;
        case ViewPagerOptionTabWidth:
            return self.view.bounds.size.width/3;
        case ViewPagerOptionFixFormerTabsPositions:
            return 1.0;
        case ViewPagerOptionFixLatterTabsPositions:
            return 1.0;
        default:
            return value;
    }
}
- (UIColor *)viewPager:(ViewPagerController *)viewPager
     colorForComponent:(ViewPagerComponent)component
           withDefault:(UIColor *)color
{
    switch (component) {
        case ViewPagerIndicator:
            return  [[UIColor redColor] colorWithAlphaComponent:1];
        case ViewPagerTabsView:
            return [[UIColor whiteColor] colorWithAlphaComponent:0.32];
        case ViewPagerContent:
            return [[UIColor whiteColor] colorWithAlphaComponent:1];
        default:
            return color;
    }
}

- (void)viewPager:(ViewPagerController *)viewPager didChangeTabToIndex:(NSUInteger)index
{
    DebugLog(@"index %ld", (long)index);
    self.selectedIndex = index;
    
    [self setNeedsReloadTabViews];
}

#pragma mark -
#pragma mark - Interface Orientation Changes

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // Update changes after screen rotates
    [self performSelector:@selector(setNeedsReloadOptions) withObject:nil afterDelay:duration];
}

#pragma mark -
#pragma mark getter/setter

- (MainViewController *)vc1
{
    if (!_vc1) {
        _vc1 = [[MainViewController alloc] init];
    }
    return _vc1;
}

- (MainViewController *)vc2
{
    if (!_vc2) {
        _vc2 = [[MainViewController alloc] init];
    }
    return _vc2;
}

- (MainViewController *)vc3
{
    if (!_vc3) {
        _vc3 = [[MainViewController alloc] init];
    }
    return _vc3;
}


@end
