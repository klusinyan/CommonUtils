//  Created by Karen Lusinyan on 16/07/14.

typedef NS_ENUM(NSInteger, PresentationStyle) {
    PresentationStyleFullScreen,
    PresentationStyleCustom,
};

@protocol CommonPageViewControllerDataSource;
@protocol CommonPageViewControllerDelegate;

@interface CommonPageViewController : UIViewController

@property (readwrite, nonatomic, assign) id<CommonPageViewControllerDelegate> delegate;
@property (readwrite, nonatomic, assign) id<CommonPageViewControllerDataSource> dataSource;
@property (readwrite, nonatomic, assign) UIPageViewControllerTransitionStyle transitionStyle;
@property (readwrite, nonatomic, assign) PresentationStyle presentationStyle;

//desired initializers;
+ (instancetype)commonBook;

+ (instancetype)commonBookWithPageIndicatorTintColor:(UIColor *)pageIndicatorTintColor
                    andCurrentPageIndicatorTintColor:(UIColor *)currentPageIndicatorTintColor;

//presents book
//defualt presentationStyle is PresentationStyleFullScreen it implicity adds SELF childViewController to your viewController
//if you specify presentationStyle as PresentationStyleCustom, is to you add SELF explicity to your view
- (void)presentBookWithCompletion:(void (^)(BOOL finished))completion;

//reload pages
//calls pageContentAtIndex which loads content controllers
- (void)reloadPages;

@end

@protocol CommonPageViewControllerDelegate <NSObject>

- (NSInteger)numberOfPages;

- (NSInteger)indexOfPresentedPage;

@end

@protocol CommonPageViewControllerDataSource <NSObject>

- (UIViewController *)pageContentAtIndex:(NSInteger)index;

@end
