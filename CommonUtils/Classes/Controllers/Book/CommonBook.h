//  Created by Karen Lusinyan on 16/07/14.

#import <UIKit/UIKit.h>

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
@property (readwrite, nonatomic, getter = isPageControlHidden) BOOL pageControlHidden;

//desired initializers;
+ (instancetype)commonBook __deprecated_msg("use +instance instead");

+ (instancetype)instance;

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
- (void)setupCustomPageControlWithCompletion:(void (^)(UIPageControl *pageControl))completion; //TODO:: __deprecated_msg("use setupCustomPageControlInsideOfContainer:completion");

- (void)setupCustomPageControlInsideOfContainer:(UIView *)container completion:(void (^)(UIPageControl *pageControl))completion;

@end

@protocol CommonBookDataSource <NSObject>

@required
- (NSInteger)numberOfPagesForBook:(CommonBook *)book;

- (UIViewController *)book:(CommonBook *)book pageContentAtIndex:(NSInteger)index;

@optional
- (NSInteger)indexOfPresentedPageForBook:(CommonBook *)book;

- (BOOL)book:(CommonBook *)book pageContentShouldRecognizeTapAtIndex:(NSInteger)index;

@end

@protocol CommonBookDelegate <NSObject>

@optional
- (void)book:(CommonBook *)book pageContent:(UIViewController *)pageContent willMoveAtIndex:(NSInteger)index;

- (void)book:(CommonBook *)book pageContent:(UIViewController *)pageContent didPresentAtIndex:(NSInteger)index;

- (void)book:(CommonBook *)book pageContent:(UIViewController *)pageContent didSelectAtIndex:(NSInteger)index;

@end

