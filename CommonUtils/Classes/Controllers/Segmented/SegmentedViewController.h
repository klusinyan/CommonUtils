//  Created by Karen Lusinyan on 10/04/14.
//  Copyright (c) 2012 Home. All rights reserved.

#pragma mark - v1.0.0

@protocol SegmentedControllerDelegate <NSObject>

@optional
//called when controller did select
- (void)segmentedControllerDidSelect;
//called when controller did select, by passing SELF as a param "sender"
- (void)segmentedControllerDidSelect:(id)sender;

@end

@interface SegmentedViewController : UIViewController

//readwrite
@property (readwrite, nonatomic, assign) id<SegmentedControllerDelegate> delegate;

@property (readwrite, nonatomic, strong) UIView *headerView;                     //defautl nil

@property (readwrite, nonatomic, assign) CGFloat headerHeight;                   //defualt 0

@property (readwrite, nonatomic, assign) BOOL useToolBar;                        //default YES

@property (readwrite, nonatomic, assign) BOOL enableSwipe;                       //defualt NO

@property (readwrite, nonatomic, assign) BOOL versioneTest;                      //default NO

//readonly
@property (readonly, nonatomic, strong) UIView *toolBar;                         //defualt is UIToolbar

@property (readonly, nonatomic, assign) NSInteger selectedIndex;                 //ref to last selectedIndex

@property (readonly, nonatomic, strong) NSArray *viewControllers;                //ref to viewController's stack

@property (readonly, nonatomic, strong) UIViewController *selectedViewController;//ref to current viewController

//desired initializer
- (id)initWithViewControllers:(NSArray *)viewControllers;

//call containter explicity to load descired controller
- (void)loadViewControllerWithIndex:(NSInteger)index;

@end
