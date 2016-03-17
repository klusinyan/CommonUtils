//  Created by Karen Lusinyan on 14/08/14.

static NSString * const kControllerTransitionStatusUnknown          = @"ControllerTransitionStatusUnknown";
static NSString * const kControllerTransitionStatusWillMoveToParent = @"ControllerTransitionStatusWillMoveToParent";
static NSString * const kControllerTransitionStatusDidMoveToParent  = @"ControllerTransitionStatusDidMoveToParent";

typedef NS_ENUM(NSInteger, ControllerTransitionStatus){
    ControllerTransitionStatusWillMoveToParent,
    ControllerTransitionStatusDidMoveToParent
};

static inline NSString * controllerTransitionStatus(ControllerTransitionStatus transitionStatus)
{
    if (transitionStatus == ControllerTransitionStatusWillMoveToParent)
        return kControllerTransitionStatusWillMoveToParent;
    else if (transitionStatus == ControllerTransitionStatusDidMoveToParent)
        return kControllerTransitionStatusDidMoveToParent;
    
    else return kControllerTransitionStatusUnknown;
}

@protocol ChildControllerDelegate <NSObject>

typedef void(^ControllerTransintionHandler)(UIViewController *controller, ControllerTransitionStatus transitionStatus);

//  __deprecated_msg("deprecated in 1.6.0")
@required
@property (readwrite, nonatomic, copy) ControllerTransintionHandler controllerTransitionHandler;

@end

@interface UIViewController (ChildrenHandler) <ChildControllerDelegate>

@property (nonatomic) ControllerTransitionStatus transitionStatus;

//add child view controller to parent
- (void)addChildViewController:(UIViewController<ChildControllerDelegate> *)childViewController
        toParentViewController:(UIViewController *)parentViewController
                     container:(UIView *)container
                    completion:(ControllerTransintionHandler)completion;

//remove child view controller from parent
- (void)removeChildViewController:(UIViewController<ChildControllerDelegate> *)childViewController
         fromParentViewController:(UIViewController *)parentViewController
                       completion:(ControllerTransintionHandler)completion;

//dissmis child viewController
- (void)dismissChildrenViewControllerWithCompletion:(ControllerTransintionHandler)completion;

@end

