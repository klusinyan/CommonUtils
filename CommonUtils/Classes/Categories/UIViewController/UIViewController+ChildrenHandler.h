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

@required
@property (readwrite, nonatomic, copy) ControllerTransintionHandler controllerTransitionHandler;

@end

@interface UIViewController (ChildrenHandler) <ChildControllerDelegate>

//add child view controller to parent
- (void)parentViewController:(UIViewController *)parentViewController
      addChildViewController:(UIViewController<ChildControllerDelegate> *)childViewController
               containerView:(UIView *)containerView
                  completion:(ControllerTransintionHandler)completion;

//remove child view controller from parent
- (void)parentViewController:(UIViewController *)parentViewController
   removeChildViewController:(UIViewController<ChildControllerDelegate> *)childViewController
                  completion:(ControllerTransintionHandler)completion;

//dissmis child viewController
- (void)dismissChildrenViewControllerWithCompletion:(ControllerTransintionHandler)completion;

@end

