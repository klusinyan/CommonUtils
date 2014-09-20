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
        
        if (numberOfPages > 0) {
            
            //ask dataSource for current presenting page
            NSInteger index = 0;
            if (self.dataSource && [self.dataSource respondsToSelector:@selector(indexOfPresentedPage)]) {
                index = [self.dataSource indexOfPresentedPage];
            }
            
            //tell to pageController to set viewContollers
            UIViewController *initialVC = [self.viewControllers objectAtIndex:index];
            [self.pageController setViewControllers:@[initialVC]
                                          direction:UIPageViewControllerNavigationDirectionForward
                                           animated:NO completion:nil];
            
            //tell the pageControl (if there is a custom one) to point to the same page as \"indexOfPresentedPag\"
            if (self.pageControl) self.pageControl.currentPage = index;
            
            //ask to dataSource to reload pages
            for (int i = 0; i < numberOfPages; i++) {
                if (self.dataSource && [self.dataSource respondsToSelector:@selector(pageContentAtIndex:)]) {
                    UIViewController *pageContent = [self.dataSource pageContentAtIndex:i];
                    
                    //ask to dataSourcento activate or not tap gesture recognizer
                    if (self.dataSource && [self.dataSource respondsToSelector:@selector(pageContentShouldRecognizeTapAtIndex:)]) {
                        if ([self.dataSource pageContentShouldRecognizeTapAtIndex:i]) {
                            [self addTapGestureRecognizerToPageContent:pageContent];
                        }
                    }
                }
            }
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

- (void)pageContentDidTap
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(pageContent:didSelectAtIndex:)]) {
        [self.delegate pageContent:[self.viewControllers objectAtIndex:self.currentPage] didSelectAtIndex:self.currentPage];
    }
}

- (void)addTapGestureRecognizerToPageContent:(UIViewController *)pageContent
{
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] init];
    [tapGesture addTarget:self action:@selector(pageContentDidTap)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [pageContent.view addGestureRecognizer:tapGesture];
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
            UIViewController *pageContent = [self.dataSource pageContentAtIndex:i];
            [self.viewControllers addObject:pageContent];
            
            if (self.dataSource && [self.dataSource respondsToSelector:@selector(pageContentShouldRecognizeTapAtIndex:)]) {
                if ([self.dataSource pageContentShouldRecognizeTapAtIndex:i]) {
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
    
    self.presented = YES;
    
    //first call completion to customize "pageControl custom"
    if (completion) completion(YES);
    
    //call delegate to pass the initialVC
    if (self.delegate && [self.delegate respondsToSelector:@selector(pageContent:didMovetToIndex:)]) {
        [self.delegate pageContent:initialVC didMovetToIndex:index];
    }
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
    if (self.delegate && [self.delegate respondsToSelector:@selector(pageContent:willMoveFromIndex:)]) {
        [self.delegate pageContent:[self.viewControllers objectAtIndex:index] willMoveFromIndex:index];
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
    if (self.delegate && [self.delegate respondsToSelector:@selector(pageContent:didMovetToIndex:)]) {
        [self.delegate pageContent:[self.viewControllers objectAtIndex:index] didMovetToIndex:index];
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
