//  Created by Karen Lusinyan on 17/07/14.

#import "CommonBookViewController.h"
#import "CommonBookContentViewController.h"

//library
#import "CommonPageViewController.h"

@interface CommonBookViewController () <CommonPageViewControllerDelegate, CommonPageViewControllerDataSource>

@property (readwrite, nonatomic, strong) UIBarButtonItem *done;
@property (readwrite, nonatomic, strong) CommonPageViewController *commonBook;
@property (readwrite, nonatomic, assign) NSInteger numPages;
@property (readwrite, nonatomic, assign) NSInteger index;
@property (readwrite, nonatomic, strong) NSArray *items;

@end

@implementation CommonBookViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (id)init
{
    self = [super init];
    if (self) {
        
        //defaults
        self.numPages = 7;  //numpages
        self.index = 0;     //index of initial page
    }
    return self;
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1];
}

- (CommonBookContentViewController *)fabriqueContentController
{
    return
    [[CommonBookContentViewController alloc] initWithNibName:NSStringFromClass([CommonBookContentViewController class])
                                                      bundle:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.items = @[
                   [self fabriqueContentController],
                   [self fabriqueContentController],
                   [self fabriqueContentController],
                   [self fabriqueContentController],
                   [self fabriqueContentController],
                   [self fabriqueContentController],
                   [self fabriqueContentController]
                   ];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    UIColor *pageIndicatorTintColor = [UIColor colorWithRed:161/255.0 green:161/255.0 blue:161/255.0 alpha:1];
    UIColor *currentPageIndicatorTintColor = [UIColor colorWithRed:224/255.0 green:0/255.0 blue:21/255.0 alpha:1];
    
    self.commonBook = [CommonPageViewController commonBookWithPageIndicatorTintColor:pageIndicatorTintColor
                                                    andCurrentPageIndicatorTintColor:currentPageIndicatorTintColor];
    self.commonBook.delegate = self;
    self.commonBook.dataSource = self;
    [self.commonBook presentBookInsideOfContainer:self.view completion:^(BOOL finished) {
        DebugLog(@"finished [%@]", finished ? @"Y" : @"N");
        
        /*//not used only test
        //only when finished presneting book the customize page control
        [self.commonBook setupCustomPageControlWithTarget:self
                                                   action:@selector(pageControlValueDidChage:)
                                               completion:^(UIPageControl *pageControl) {
                                                   NSLayoutConstraint *c =
                                                   [NSLayoutConstraint constraintWithItem:pageControl
                                                                                attribute:NSLayoutAttributeBottom
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:pageControl.superview
                                                                                attribute:NSLayoutAttributeBottom
                                                                               multiplier:1
                                                                                 constant:-10];
                                                   [pageControl.superview addConstraint:c];
                                               }];
         //*/
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.commonBook reloadPages];
}

#pragma mark -
#pragma mark PageViewControllerDataSource protocol

- (NSInteger)numberOfPages
{
    return self.numPages;
}

- (NSInteger)indexOfPresentedPage
{
    return self.index;
}

- (BOOL)pageContentShouldRecognizeTapAtIndex:(NSInteger)index
{
    return (index == 0);
}

- (UIViewController *)pageContentAtIndex:(NSInteger)index
{
    CommonBookContentViewController *pageContent = [self.items objectAtIndex:index];
    
    NSString *prefix = (iPhone) ? @"iPhone" : @"iPad";
    NSString *imageName = [prefix stringByAppendingFormat:@"_%@", @(index)];
    pageContent.image = [UIImage imageNamed:imageName];
    DebugLog(@"imageName %@", imageName);
    
    return pageContent;
}

#pragma mark -
#pragma mark PageViewControllerDelegate protocol

- (void)pageContentDidSelectAtIndex:(NSInteger)index
{
    DebugLog(@"pageContent tapped at index %@", @(index));
}

/*not used only test
- (void)pageControlValueDidChage:(UIPageControl *)pageControl
{
    [self.commonBook jumpToPageAtIndex:pageControl.currentPage
                              animated:YES
                            completion:^(BOOL finished) {
                                //do something
                            }];
}
//*/

@end