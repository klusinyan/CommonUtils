//  Created by Karen Lusinyan on 10/04/14.
//  Copyright (c) 2012 Home. All rights reserved.

@protocol CommonSegmentDataSource;
@protocol CommonSegmentDelegate;

@interface CommonSegment : UIViewController

//readwrite
@property (readwrite, nonatomic, assign) id<CommonSegmentDataSource> dataSource;
@property (readwrite, nonatomic, assign) id<CommonSegmentDelegate> delegate;

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

//call containter explicity to load descired controller
- (void)loadViewControllerWithIndex:(NSInteger)index;

//override
- (void)viewControllerDidLoad:(id<CommonSegmentDelegate>)viewController atIndex:(NSInteger)index;

@end

@protocol  CommonSegmentDataSource <NSObject>

@optional
- (id)headerViewForCommonSegment:(CommonSegment *)commonSegment;

- (CGFloat)headerViewHeightForCommonSegmented:(CommonSegment *)commonSegment;

@end

@protocol CommonSegmentDelegate <NSObject>

@optional
//called when controller did select
- (void)segmentedControllerDidSelect;

//called when controller did select, by passing SELF as a param "sender"
- (void)segmentedControllerDidSelect:(id)sender;

@end