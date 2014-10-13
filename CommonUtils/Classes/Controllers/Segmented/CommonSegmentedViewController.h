//  Created by Karen Lusinyan on 10/04/14.
//  Copyright (c) 2012 Home. All rights reserved.

@protocol CommonSegmentedControllerDelegate;

@interface CommonSegmentedViewController : UIViewController

//readwrite
@property (readwrite, nonatomic, assign) id<CommonSegmentedControllerDelegate> delegate;

@property (readwrite, nonatomic, strong) UIView *headerView;                     //defautl nil

@property (readwrite, nonatomic, assign) CGFloat headerHeight;                   //defualt 0

@property (readwrite, nonatomic, assign) BOOL useToolBar;                        //default YES

@property (readwrite, nonatomic, assign) BOOL enableSwipe;                       //defualt NO

@property (readwrite, nonatomic, assign) BOOL versioneTest;                      //default NO

@property (readwrite, nonatomic, assign) NSInteger selectedIndex;                //defualt is 0

//readonly
@property (readonly, nonatomic, strong) UIView *toolBar;                         //defualt is UIToolbar

@property (readonly, nonatomic, strong) NSArray *viewControllers;                //ref to viewController's stack

@property (readonly, nonatomic, strong) UIViewController *selectedViewController;//ref to current viewController

//desired initializer
- (id)initWithViewControllers:(NSArray *)viewControllers;

//override to setup addional UI components es: headerView
- (void)setupCustomUI;

//call containter explicity to load descired controller
- (void)loadViewControllerWithIndex:(NSInteger)index;

//override
- (void)viewControllerDidLoad:(id<CommonSegmentedControllerDelegate>)viewController atIndex:(NSInteger)index;

@end

@protocol CommonSegmentedControllerDelegate <NSObject>

@optional
- (void)segmentedController:(UIViewController *)segmentedController
            didSelectConent:(id<CommonSegmentedControllerDelegate>)content
                    atIndex:(NSInteger)index;

@end