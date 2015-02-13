//  Created by Karen Lusinyan on 17/07/14.

#import "CommonBookViewController.h"
#import "CommonBookContentViewController.h"
#import "TGRImageViewController.h"

//library
#import "CommonBook.h"
#import "CommonPageContent.h"

#define kPageBackgroundColor [UIColor blackColor]

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

- (CommonPageContent *)fabriquePageContent
{
    return
    [[CommonPageContent alloc] init];

    /*
    return
    [[TGRImageViewController alloc] initWithNibName:NSStringFromClass([TGRImageViewController class])
                                             bundle:nil];
    //*/
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = kPageBackgroundColor;
    
    self.items = [NSMutableArray array];
    /*
    for (int i = 0; i < 7; i++) {
        [self.items addObject:[self fabriqueContentController]];
    }
    //*/
    
    for (int i = 0; i < 10; i++) {
        [self.items addObject:[self fabriquePageContent]];
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
    self.commonBook = [CommonBook commonBookWithPageIndicatorTintColor:[UIColor whiteColor]
                                      andCurrentPageIndicatorTintColor:[UIColor redColor]];
    self.commonBook.delegate = self;
    self.commonBook.dataSource = self;
    self.commonBook.pageControlHidden = YES;
    [self.commonBook presentBookInsideOfContainer:self.container1 completion:^(BOOL finished) {
        DebugLog(@"finished [%@]", finished ? @"Y" : @"N");
        
        /*
        //setup and position page control
        //not used only test
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
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //---------------RELOAD PAGES---------------//
        //[self.items removeLastObject];
        //[self.commonBook reloadPages];
        //---------------RELOAD PAGES---------------//
    });
}

- (void)pageControlValueDidChage:(id)sender
{
    //do something
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

- (NSInteger)numberOfPagesForBook:(CommonBook *)book
{
    return [self.items count];
}

/*
- (NSInteger)indexOfPresentedPage
{
    return self.index;
}
//*/

- (BOOL)book:(CommonBook *)book pageContentShouldRecognizeTapAtIndex:(NSInteger)index
{
    return (index == 0);
}

- (UIViewController *)book:(CommonBook *)book pageContentAtIndex:(NSInteger)index
{
    CommonPageContent *pageContent = [self.items objectAtIndex:index];
    pageContent.zoomEnabled = YES;
    pageContent.backgroundColor = kPageBackgroundColor;
    //pageContent.contentInset = UIEdgeInsetsZero;
    
    NSString *prefix = (iPhone) ? @"iPhone" : @"iPad";
    NSString *imageName = [prefix stringByAppendingFormat:@"_%@", @(index % 7)];
    pageContent.image = [UIImage imageNamed:imageName];
    DebugLog(@"imageName %@", imageName);
    
    return pageContent;
    
    /*
    CommonBookContentViewController *pageContent = [self.items objectAtIndex:index];
    
    NSString *prefix = (iPhone) ? @"iPhone" : @"iPad";
    NSString *imageName = [prefix stringByAppendingFormat:@"_%@", @(index)];
    pageContent.image = [UIImage imageNamed:imageName];
    DebugLog(@"imageName %@", imageName);
    
    return pageContent;
    //*/
}

#pragma mark -
#pragma mark PageViewControllerDelegate protocol

- (void)book:(CommonBook *)book pageContent:(UIViewController *)pageContent willMoveAtIndex:(NSInteger)index
{
    DebugLog(@"willMoveAtIndex %@", @(index));
    //CommonBookContentViewController *pc = (CommonBookContentViewController *)pageContent;
    //[pc showAnimation:YES];
}

- (void)book:(CommonBook *)book pageContent:(id)pageContent didPresentAtIndex:(NSInteger)index
{
    DebugLog(@"didPresentAtIndex %@", @(index));
    //CommonBookContentViewController *pc = (CommonBookContentViewController *)pageContent;
    //[pc showAnimation:YES];
}

- (void)book:(CommonBook *)book pageContent:(id)pageContent didSelectAtIndex:(NSInteger)index
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
