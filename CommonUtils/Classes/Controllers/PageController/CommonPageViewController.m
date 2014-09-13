//  Created by Karen Lusinyan on 16/07/14.

#import "CommonPageViewController.h"

@interface CommonPageViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property (readwrite, nonatomic, strong) UIPageViewController *pageController;
@property (readwrite, nonatomic, strong) NSMutableArray *viewControllers;
@property (readwrite, nonatomic, strong) UIPageControl *pageControl;
@property (readwrite, nonatomic, assign) NSInteger currentPage;

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

- (void)presentBookInsideOfContainer:(UIView *)container completion:(void (^)(BOOL finished))completion
{
    [self setupViewContollers];
    [self setupPageControllerInsideOfContainer:container completion:completion];
}

- (void)reloadPages
{
    NSInteger numberOfPages = 0;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfPages)]) {
        numberOfPages = [self.dataSource numberOfPages];
    }
    for (int i = 0; i < numberOfPages; i++) {
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(pageContentAtIndex:)]) {
            [self.dataSource pageContentAtIndex:i];
        }
    }
}

- (void)jumpToPageAtIndex:(NSInteger)index animated:(BOOL)animated completion:(void (^)(BOOL finished))completion
{
    UIViewController *contentToJump = [self.viewControllers objectAtIndex:index];
    UIPageViewControllerNavigationDirection direction = (index > self.currentPage)
    ? UIPageViewControllerNavigationDirectionForward
    : UIPageViewControllerNavigationDirectionReverse;
    self.currentPage = index;
    [self.pageController setViewControllers:@[contentToJump]
                                  direction:direction
                                   animated:animated
                                 completion:^(BOOL finished) {
                                     //do something
                                     if (completion) completion(finished);
                                 }];
}

- (void)setupCustomPageControlWithTarget:(id)target
                                  action:(SEL)action
                              completion:(void (^)(UIPageControl *pageControl))completion;
{
    if (!self.pageControl) {
        self.pageControl = [[UIPageControl alloc] init];
        self.pageControl.translatesAutoresizingMaskIntoConstraints = NO;
        self.pageControl.numberOfPages = [self.viewControllers count];
        [self.pageControl addTarget:target
                             action:action
                   forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:self.pageControl];
        
        NSLayoutConstraint *centerX =
        [NSLayoutConstraint constraintWithItem:self.pageControl
                                     attribute:NSLayoutAttributeCenterX
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.view
                                     attribute:NSLayoutAttributeCenterX
                                    multiplier:1
                                      constant:0];
        NSLayoutConstraint *centerY =
        [NSLayoutConstraint constraintWithItem:self.pageControl
                                     attribute:NSLayoutAttributeCenterX
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.view
                                     attribute:NSLayoutAttributeCenterX
                                    multiplier:1
                                      constant:0];
        
        [self.view addConstraints:@[centerX, centerY]];
        if (completion) completion(self.pageControl);
    }
}

#pragma mark -
#pragma mark private methods

- (void)setupViewContollers
{
    NSInteger numberOfPages = 0;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfPages)]) {
        numberOfPages = [self.dataSource numberOfPages];
    }
    for (int i = 0; i < numberOfPages; i++) {
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(pageContentAtIndex:)]) {
            [self.viewControllers addObject:[self.dataSource pageContentAtIndex:i]];
            
            //TODO:: implementare
            /*
             UIViewController *contentController = [self.dataSource pageContentAtIndex:i];
             if (self.dataSource && [self.dataSource respondsToSelector:@selector(pageContentShouldRecognizerTapAtIndex:)]) {
             if ([self.dataSource pageContentShouldRecognizerTapAtIndex:i]) {
             UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self.delegate
             action:@selector(pageContentDidSelectAtIndex:)];
             tapGesture.numberOfTapsRequired = 1;
             tapGesture.numberOfTouchesRequired = 1;
             [contentController.view addGestureRecognizer:tapGesture];
             }
             }
             //*/
        }
    }
}

- (void)setupPageControllerInsideOfContainer:(UIView *)container completion:(void (^)(BOOL finished))completion
{
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:self.transitionStyle
                                                          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                        options:nil];
    self.pageController.delegate = self;
    self.pageController.dataSource = self;
    
    NSInteger index = 0;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(indexOfPresentedPage)]) {
        index = [self.dataSource indexOfPresentedPage];
    }
    
    UIViewController *initialVC = [self.viewControllers objectAtIndex:index];
    [self.pageController setViewControllers:@[initialVC]
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:NO completion:nil];
    
    self.view.frame = container.bounds;
    [container addSubview:self.view];
    
    [self addChildViewController:self.pageController];
    self.pageController.view.frame = self.view.bounds;
    [self.view addSubview:self.pageController.view];
    [self.pageController didMoveToParentViewController:self];
    
    if (completion) completion(YES);
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

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    NSUInteger index = [self.viewControllers indexOfObject:pageViewController.viewControllers[0]];
    if (index == NSNotFound) {
        return;
    }
    self.currentPage = index;
    if (self.pageControl && [self.pageControl respondsToSelector:@selector(setCurrentPage:)]) {
        self.pageControl.currentPage = self.currentPage;
    }
}

#pragma mark -
#pragma mark PageViewControllerDelegate protocol

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    NSInteger index = 0;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfPages)]) {
        index = [self.dataSource numberOfPages];
    }
    return index;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    if (self.pageControl) {
        return -1;
    }
    NSInteger index = 0;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(indexOfPresentedPage)]) {
        index = [self.dataSource indexOfPresentedPage];
    }
    return index;
}

@end
