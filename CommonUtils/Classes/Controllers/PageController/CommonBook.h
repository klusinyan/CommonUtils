//  Created by Karen Lusinyan on 16/07/14.

typedef NS_ENUM(NSInteger, PresentationStyle) {
    PresentationStyleFullScreen,
    PresentationStyleCustom,
};

@protocol CommonBookDelegate;
@protocol CommonBookDataSource;

@interface CommonBook : UIViewController

@property (readwrite, nonatomic, assign) id<CommonBookDelegate> delegate;
@property (readwrite, nonatomic, assign) id<CommonBookDataSource> dataSource;
@property (readwrite, nonatomic, assign) UIPageViewControllerTransitionStyle transitionStyle;
@property (readwrite, nonatomic, assign) PresentationStyle presentationStyle;
@property (readwrite, nonatomic, getter = isPresented) BOOL presented;

//desired initializers;
+ (instancetype)commonBook;

+ (instancetype)commonBookWithPageIndicatorTintColor:(UIColor *)pageIndicatorTintColor
                    andCurrentPageIndicatorTintColor:(UIColor *)currentPageIndicatorTintColor;

//presents book
//defualt presentationStyle is PresentationStyleFullScreen it implicity adds SELF childViewController to your viewController
//if you specify presentationStyle as PresentationStyleCustom, is to you add SELF explicity to your view
- (void)presentBookInsideOfContainer:(UIView *)container completion:(void (^)(BOOL finished))completion;

//reload pages
//calls pageContentAtIndex which loads content controllers
- (void)reloadPages;

//jump to indicating index
- (void)jumpToPageAtIndex:(NSInteger)index animated:(BOOL)animated completion:(void (^)(BOOL finished))completion;

//setup custom page control
- (void)setupCustomPageControlWithCompletion:(void (^)(UIPageControl *pageControl))completion;

@end

@protocol CommonBookDataSource <NSObject>

@required
- (NSInteger)numberOfPages;

- (UIViewController *)pageContentAtIndex:(NSInteger)index;

@optional
- (NSInteger)indexOfPresentedPage;

- (BOOL)pageContentShouldRecognizeTapAtIndex:(NSInteger)index;

@end

@protocol CommonBookDelegate <NSObject>

@optional
- (void)pageContent:(UIViewController *)pageContent willMoveAtIndex:(NSInteger)index;

- (void)pageContent:(UIViewController *)pageContent didPresentAtIndex:(NSInteger)index;

- (void)pageContent:(UIViewController *)pageContent didSelectAtIndex:(NSInteger)index;

@end

