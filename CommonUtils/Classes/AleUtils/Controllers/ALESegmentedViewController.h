//  Created by Alessio on 11/03/14.
//  Copyright (c) 2014 Alessio. All rights reserved.

//  Container view controller with a segmented control to switch between view controllers (similar to a UITabBarViewController)

#import <UIKit/UIKit.h>

@class ALESegmentedViewController;

@protocol ALESegmentedViewControllerDelegate <NSObject>

@optional

//  called when a view controller is about to be shown
- (void)segmentedViewController:(ALESegmentedViewController *)segmentedController willShowViewController:(UIViewController *)viewController;

//  called when a view controller has been shown
- (void)segmentedViewController:(ALESegmentedViewController *)segmentedController didShowViewController:(UIViewController *)viewController;

//  called when a view controller is about to be hidden
- (void)segmentedViewController:(ALESegmentedViewController *)segmentedController willHideViewController:(UIViewController *)viewController;

//  called when a view controller has been hidden
- (void)segmentedViewController:(ALESegmentedViewController *)segmentedController didHideViewController:(UIViewController *)viewController;

@end

@interface ALESegmentedViewController : UIViewController

//  the segmented control associated with the segmentedViewController
@property (nonatomic, strong, readonly) IBOutlet UISegmentedControl *segmentedControl;

//  the view controllers associated with the segmentedViewController
@property (nonatomic, strong) NSArray *viewControllers;

//  the index of the currenlty selected view controller
@property (nonatomic, assign, readonly) NSUInteger selectedViewControllerIndex;

//  the segmented view controller delegate
@property (nonatomic, assign) id<ALESegmentedViewControllerDelegate>delegate;

//  use this to set the segmented control title for a view controller's segment
- (void)setSegmentedTitle:(NSString *)title forViewControllerAtIndex:(NSUInteger)index;

@end
