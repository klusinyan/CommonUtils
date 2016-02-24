//  Created by Karen Lusinyan on 16/07/14.

#import "CommonBook.h"

@interface CommonBook () <UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIGestureRecognizerDelegate>

@property (readwrite, nonatomic, strong) UIPageViewController *pageController;
@property (readwrite, nonatomic, strong) NSMutableArray *viewControllers;
@property (readwrite, nonatomic, strong) UIPageControl *pageControl;
@property (readwrite, nonatomic, assign) NSInteger currentPage;

@end

@implementation CommonBook

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
        self.presented = NO;
        self.pageControlHidden = NO;
    }
    return self;
}
 
#pragma mark -
#pragma mark initializer

+ (instancetype)commonBook
{
    return [self commonBookWithPageIndicatorTintColor:nil andCurrentPageIndicatorTintColor:nil];
}

+ (instancetype)instance
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
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfPagesForBook:)]) {
        numberOfPages = [self.dataSource numberOfPagesForBook:self];
        
        if (numberOfPages > 0) {
            
            //ask dataSource for current presenting page
            NSInteger index = 0;
            if (self.dataSource && [self.dataSource respondsToSelector:@selector(indexOfPresentedPageForBook:)]) {
                index = [self.dataSource indexOfPresentedPageForBook:self];
            }
            
            //tell the pageControl (if there is a custom one) to point to the same page as \"indexOfPresentedPag\"
            if (self.pageControl) self.pageControl.currentPage = index;
            if (self.pageControl) self.pageControl.numberOfPages = numberOfPages;
            
            [self.viewControllers removeAllObjects];
            [self setupViewContollers];
            
            //tell to pageController to set viewContollers
            UIViewController *initialVC = [self.viewControllers objectAtIndex:index];
            [self.pageController setViewControllers:@[initialVC]
                                          direction:UIPageViewControllerNavigationDirectionForward
                                           animated:NO completion:nil];
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

- (void)pageContentDidTap
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(book:pageContent:didSelectAtIndex:)]) {
        [self.delegate book:self pageContent:[self.viewControllers objectAtIndex:self.currentPage] didSelectAtIndex:self.currentPage];
    }
}

- (void)addTapGestureRecognizerToPageContent:(UIViewController *)pageContent
{
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] init];
    tapGesture.delegate = self;
    [tapGesture addTarget:self action:@selector(pageContentDidTap)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [pageContent.view addGestureRecognizer:tapGesture];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return (touch.view != self.pageControl);
}

#pragma mark -
#pragma mark private methods

- (void)setupViewContollers
{
    NSInteger numberOfPages = 0;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfPagesForBook:)]) {
        numberOfPages = [self.dataSource numberOfPagesForBook:self];
    }
    for (int i = 0; i < numberOfPages; i++) {
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(book:pageContentAtIndex:)]) {
            UIViewController *pageContent = [self.dataSource book:self pageContentAtIndex:i];
            [self.viewControllers addObject:pageContent];
            
            if (self.dataSource && [self.dataSource respondsToSelector:@selector(book:pageContentShouldRecognizeTapAtIndex:)]) {
                if ([self.dataSource book:self pageContentShouldRecognizeTapAtIndex:i]) {
                    [self addTapGestureRecognizerToPageContent:pageContent];
                }
            }
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
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(indexOfPresentedPageForBook:)]) {
        index = [self.dataSource indexOfPresentedPageForBook:self];
    }
    
    UIViewController *initialVC = [self.viewControllers objectAtIndex:index];
    [self.pageController setViewControllers:@[initialVC]
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:NO completion:nil];

    if (!container) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ Failed to call setupPageControllerInsideOfContainer:withCompletion, please pass a valid \"container\"", NSStringFromClass([self class])] userInfo:nil];
    }

    self.view.frame = container.bounds;
    [container addSubview:self.view];
    
    [self addChildViewController:self.pageController];
    self.pageController.view.frame = self.view.bounds;
    [self.view addSubview:self.pageController.view];
    [self.pageController didMoveToParentViewController:self];
    
    self.presented = YES;
    
    //first call completion to customize "pageControl custom"
    if (completion) completion(YES);
    
    //call delegate to pass the initialVC
    if (self.delegate && [self.delegate respondsToSelector:@selector(book:pageContent:didPresentAtIndex:)]) {
        [self.delegate book:self pageContent:initialVC didPresentAtIndex:index];
    }
}

- (void)setupCustomPageControlWithCompletion:(void (^)(UIPageControl *))completion
{
    [self setupCustomPageControlInsideOfContainer:nil completion:completion];
}

- (void)setupCustomPageControlInsideOfContainer:(UIView *)container completion:(void (^)(UIPageControl *))completion
{
    if (!self.pageControl && !self.pageControlHidden) {
        self.pageControl = [[UIPageControl alloc] init];
        self.pageControl.translatesAutoresizingMaskIntoConstraints = NO;
        self.pageControl.numberOfPages = [self.viewControllers count];
        [self.pageControl addTarget:self
                             action:@selector(pageControlValueDidChange:)
                   forControlEvents:UIControlEventValueChanged];

        if (!container) {
            container = self.view;
        }
        
        [container addSubview:self.pageControl];
        [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_pageControl]|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:NSDictionaryOfVariableBindings(_pageControl)]];
        
        if (container != self.view) {
            [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_pageControl]|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:NSDictionaryOfVariableBindings(_pageControl)]];
        }

        if (completion) completion(self.pageControl);
    }
}

- (void)pageControlValueDidChange:(id)sender
{
    [self jumpToPageAtIndex:self.pageControl.currentPage
                   animated:YES
                 completion:^(BOOL finished) {
                     if (self.delegate && [self.delegate respondsToSelector:@selector(book:pageContent:didPresentAtIndex:)]) {
                         [self.delegate book:self pageContent:[self.viewControllers objectAtIndex:self.currentPage] didPresentAtIndex:self.currentPage];
                     }
                 }];
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

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
    NSUInteger index = [self.viewControllers indexOfObject:pageViewController.viewControllers[0]];
    if (index == NSNotFound) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(book:pageContent:willMoveAtIndex:)]) {
        [self.delegate book:self pageContent:[self.viewControllers objectAtIndex:index] willMoveAtIndex:index];
    }
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
    if (self.delegate && [self.delegate respondsToSelector:@selector(book:pageContent:didPresentAtIndex:)]) {
        [self.delegate book:self pageContent:[self.viewControllers objectAtIndex:index] didPresentAtIndex:index];
    }
}

#pragma mark -
#pragma mark PageViewControllerDelegate protocol

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    NSInteger index = 0;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfPagesForBook:)]) {
        index = [self.dataSource numberOfPagesForBook:self];
    }
    return index;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    if (self.pageControl || self.isPageControlHidden) {
        return -1;
    }
    NSInteger index = 0;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(indexOfPresentedPageForBook:)]) {
        index = [self.dataSource indexOfPresentedPageForBook:self];
    }
    return index;
}

@end
