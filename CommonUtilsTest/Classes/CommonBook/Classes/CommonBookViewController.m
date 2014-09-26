//  Created by Karen Lusinyan on 17/07/14.

#import "CommonBookViewController.h"
#import "CommonBookContentViewController.h"

//library
#import "CommonBook.h"

@interface CommonBookViewController () <CommonBookDelegate, CommonBookDataSource>

@property (readwrite, nonatomic, strong) IBOutlet UIView *container0;
@property (readwrite, nonatomic, strong) IBOutlet UIView *container1;
@property (readwrite, nonatomic, strong) IBOutlet UIView *container2;

@property (readwrite, nonatomic, strong) UIBarButtonItem *done;
@property (readwrite, nonatomic, strong) CommonBook *commonBook;
@property (readwrite, nonatomic, assign) NSInteger numPages;
@property (readwrite, nonatomic, assign) NSInteger index;
@property (readwrite, nonatomic, strong) NSMutableArray *items;

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

/*
- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1];
}
//*/

- (CommonBookContentViewController *)fabriqueContentController
{
    return
    [[CommonBookContentViewController alloc] initWithNibName:NSStringFromClass([CommonBookContentViewController class])
                                                      bundle:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.items = [NSMutableArray array];
    for (int i = 0; i < 7; i++) {
        [self.items addObject:[self fabriqueContentController]];
    }
    
    /*
    self.items = @[
                   [self fabriqueContentController],
                   [self fabriqueContentController],
                   [self fabriqueContentController],
                   [self fabriqueContentController],
                   [self fabriqueContentController],
                   [self fabriqueContentController],
                   [self fabriqueContentController]
                   ];
    //*/
     
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    //self.commonBook = [CommonPageViewController commonBook];
    
    //used only for custom page control
    ///*
    //__block  UIColor *pageIndicatorTintColor = [UIColor orangeColor];
    //[UIColor colorWithRed:161/255.0 green:161/255.0 blue:161/255.0 alpha:1];
    //__block UIColor *currentPageIndicatorTintColor = [UIColor yellowColor];
    //[UIColor colorWithRed:224/255.0 green:0/255.0 blue:21/255.0 alpha:1];
    
    //*/
    self.commonBook = [CommonBook commonBookWithPageIndicatorTintColor:[UIColor blueColor] andCurrentPageIndicatorTintColor:[UIColor greenColor]];

    self.commonBook.delegate = self;
    self.commonBook.dataSource = self;
    [self.commonBook presentBookInsideOfContainer:self.container1 completion:^(BOOL finished) {
        DebugLog(@"finished [%@]", finished ? @"Y" : @"N");
        
        ///*//not used only test
        //only when finished presneting book the customize page control
        [self.commonBook setupCustomPageControlWithCompletion:^(UIPageControl *pageControl) {
                                                          
                                                          NSLayoutConstraint *bottom =
                                                          [NSLayoutConstraint constraintWithItem:pageControl
                                                                                       attribute:NSLayoutAttributeBottom
                                                                                       relatedBy:NSLayoutRelationEqual
                                                                                          toItem:pageControl.superview
                                                                                       attribute:NSLayoutAttributeBottom
                                                                                      multiplier:1
                                                                                        constant:0];
                                                          
                                                          [pageControl.superview addConstraint:bottom];
                                                      }];
         //*/
    }];
}

- (void)pageControlValueDidChage:(id)sender
{
    
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
    return [self.items count];
}

/*
- (NSInteger)indexOfPresentedPage
{
    return self.index;
}
//*/

- (BOOL)pageContentShouldRecognizeTapAtIndex:(NSInteger)index
{
    return (index == 0);
}

- (UIViewController *)pageContentAtIndex:(NSInteger)index
{
    CommonBookContentViewController *pageContent = [self.items objectAtIndex:index];
    
    NSString *prefix = (iPhone) ? @"iPhone" : @"iPad";
    NSString *imageName = [prefix stringByAppendingFormat:@"_%@", @(index)/*@(arc4random_uniform(index % 6))*/];
    pageContent.image = [UIImage imageNamed:imageName];
    DebugLog(@"imageName %@", imageName);
    
    return pageContent;
}

#pragma mark -
#pragma mark PageViewControllerDelegate protocol

- (void)pageContent:(id)pageContent didPresentAtIndex:(NSInteger)index
{
    DebugLog(@"currentPage %@", @(index));
}

- (void)pageContent:(id)pageContent didSelectAtIndex:(NSInteger)index
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
