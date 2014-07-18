//  Created by Karen Lusinyan on 16/07/14.

#import "CommonPageViewController.h"

@interface CommonPageViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property (readwrite, nonatomic, strong) UIPageViewController *pageController;
@property (readwrite, nonatomic, strong) NSMutableArray *viewControllers;

@end

@implementation CommonPageViewController

- (void)dealloc
{
    self.delegate = nil;
    self.dataSource = nil;
}

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ Failed to call designated initializer. Invoke `+commonBook: or commonBookWithPageIndicatorTintColor:andCurrentPageIndicatorTintColor` instead.", NSStringFromClass([self class])] userInfo:nil];
}

- (id)initBook
{
    self = [super init];
    if (self) {
        self.viewControllers = [NSMutableArray array];
        
        //defaults
        self.transitionStyle = UIPageViewControllerTransitionStyleScroll;
        self.presentationStyle = PresentationStyleFullScreen;
    }
    return self;
}

#pragma mark -
#pragma mark initializer

+ (instancetype)commonBook
{
    return [self commonBookWithPageIndicatorTintColor:nil andCurrentPageIndicatorTintColor:nil];
}

+ (instancetype)commonBookWithPageIndicatorTintColor:(UIColor *)pageIndicatorTintColor
                    andCurrentPageIndicatorTintColor:(UIColor *)currentPageIndicatorTintColor
{
    if (pageIndicatorTintColor) {
        [UIPageControl appearanceWhenContainedIn:[self class], nil].pageIndicatorTintColor = pageIndicatorTintColor;
    }
    if (currentPageIndicatorTintColor) {
        [UIPageControl appearanceWhenContainedIn:[self class], nil].currentPageIndicatorTintColor = currentPageIndicatorTintColor;
    }
    
    return [[self alloc] initBook];
}

#pragma mark -
#pragma mark public methods

- (void)presentBookWithCompletion:(void (^)(BOOL finished))completion
{
    [self setupViewContollers];
    [self setupPageController:completion];
}

- (void)reloadPages
{
    [self setupViewContollers];
}

- (void)jumpToPageAtIndex:(NSInteger)index animated:(BOOL)animated completion:(void (^)(BOOL finished))completion
{
    UIViewController *contentToJump = [self.viewControllers objectAtIndex:index];
    [self.pageController setViewControllers:@[contentToJump]
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:animated completion:^(BOOL finished) {
                                       DebugLog(@"finished [%@]", finished ? @"Y" : @"N");
                                       if (completion) completion(finished);
                                   }];
}

#pragma mark -
#pragma mark private methods

- (void)setupViewContollers
{
    NSInteger numberOfPages = 0;
    if (self.delegate && [self.delegate respondsToSelector:@selector(numberOfPages)]) {
        numberOfPages = [self.delegate numberOfPages];
    }
    for (int i = 0; i < numberOfPages; i++) {
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(pageContentAtIndex:)]) {
            [self.viewControllers addObject:[self.dataSource pageContentAtIndex:i]];
        }
    }
}

- (void)setupPageController:(void (^)(BOOL finished))completion
{
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:self.transitionStyle
                                                          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                        options:nil];
    self.pageController.delegate = self;
    self.pageController.dataSource = self;

    NSInteger index = 0;
    if (self.delegate && [self.delegate respondsToSelector:@selector(indexOfPresentedPage)]) {
        index = [self.delegate indexOfPresentedPage];
    }

    UIViewController *initialVC = [self.viewControllers objectAtIndex:index];
    [self.pageController setViewControllers:@[initialVC]
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:NO completion:nil];
    
    [self addChildViewController:self.pageController];
    [self.view addSubview:self.pageController.view];
    [self.pageController didMoveToParentViewController:self];

    BOOL finished = (self.presentationStyle == PresentationStyleCustom);
    if (self.presentationStyle == PresentationStyleFullScreen) {
        if (self.delegate && [self.delegate isKindOfClass:[UIViewController class]]) {
            UIViewController *presentingViewController = (UIViewController *)self.delegate;
            [presentingViewController addChildViewController:self];
            [presentingViewController.view addSubview:self.view];
            [self didMoveToParentViewController:presentingViewController];
            
            finished = YES;
        }
    }
    if (completion) completion(finished);
}

#pragma mark -
#pragma mark UIPageViewControllerDataSource methods

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self.viewControllers indexOfObject:viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    index--;
    return [self.viewControllers objectAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self.viewControllers indexOfObject:viewController];
    if (index == NSNotFound) {
        return nil;
    }
    index++;
    if (index == [self.viewControllers count]) {
        return nil;
    }
    return [self.viewControllers objectAtIndex:index];
}

#pragma mark -
#pragma mark PageViewControllerDelegate protocol

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    NSInteger index = 0;
    if (self.delegate && [self.delegate respondsToSelector:@selector(numberOfPages)]) {
        index = [self.delegate numberOfPages];
    }
    return index;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    NSInteger index = 0;
    if (self.delegate && [self.delegate respondsToSelector:@selector(indexOfPresentedPage)]) {
        index = [self.delegate indexOfPresentedPage];
    }
    return index;
}

@end
