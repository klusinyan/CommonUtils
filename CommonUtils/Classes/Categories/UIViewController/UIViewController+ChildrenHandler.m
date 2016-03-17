//  Created by Karen Lusinyan on 14/08/14.

#import "UIViewController+ChildrenHandler.h"
#import <objc/runtime.h>

@implementation UIViewController (ChildrenHandler)
@dynamic controllerTransitionHandler;
@dynamic transitionStatus;

- (ControllerTransitionStatus)transitionStatus
{
    return [objc_getAssociatedObject(self, @selector(transitionStatus)) integerValue];
}

- (void)setTransitionStatus:(ControllerTransitionStatus)transitionStatus
{
    objc_setAssociatedObject(self, @selector(transitionStatus), @(transitionStatus), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)addChildViewController:(UIViewController<ChildControllerDelegate> *)childViewController
        toParentViewController:(UIViewController *)parentViewController
                     container:(UIView *)container
                    completion:(ControllerTransintionHandler)completion
{
    if ([self respondsToSelector:@selector(controllerTransitionHandler)]) {
        childViewController.controllerTransitionHandler = ^(UIViewController *controller, ControllerTransitionStatus transitionStatus) {
            if (completion) completion(controller, transitionStatus);
        };
    }
    
    //if container view is nil -> assign it self.view as a default value
    if (!container) container = self.view;

    [parentViewController addChildViewController:childViewController];
    [childViewController didMoveToParentViewController:parentViewController];
    childViewController.view.frame = container.bounds;
    [container addSubview:childViewController.view];
    
    if (completion) completion(childViewController, self.transitionStatus);

    //***************************************************************//
    //********************* implement if needed *********************//
    //***************************************************************//
    /*
    //set constrains to childView
    childViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    //create bidings dictionary
    NSDictionary *bindings = @{@"childView" : childViewController.view};
    
    //assign contstrains
    [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[childView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:bindings]];
    
    [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[childView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:bindings]];
     //*/
    //***************************************************************//
    //********************* implement if needed *********************//
    //***************************************************************//
}

- (void)removeChildViewController:(UIViewController<ChildControllerDelegate> *)childViewController
         fromParentViewController:(UIViewController *)parentViewController
                       completion:(ControllerTransintionHandler)completion
{
    if ([self respondsToSelector:@selector(controllerTransitionHandler)]) {
        childViewController.controllerTransitionHandler = ^(UIViewController *controller, ControllerTransitionStatus transitionStatus) {
            if (completion) completion(controller, transitionStatus);
        };
    }

    [childViewController willMoveToParentViewController:parentViewController];
    [childViewController.view removeFromSuperview];
    [childViewController removeFromParentViewController];
}

- (void)dismissChildrenViewControllerWithCompletion:(ControllerTransintionHandler)completion
{
    for (UIViewController *childViewController in self.childViewControllers) {
        if ([self respondsToSelector:@selector(controllerTransitionHandler)]) {
            childViewController.controllerTransitionHandler = ^(UIViewController *controller, ControllerTransitionStatus transitionStatus) {
                if (completion) completion(controller, transitionStatus);
            };
        }
        
        [childViewController willMoveToParentViewController:nil];
        [childViewController.view removeFromSuperview];
        [childViewController removeFromParentViewController];
    }
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    self.transitionStatus = ControllerTransitionStatusWillMoveToParent;
    
    if ([self respondsToSelector:@selector(controllerTransitionHandler)]) {
        if (self.controllerTransitionHandler) self.controllerTransitionHandler(self, ControllerTransitionStatusWillMoveToParent);
    }
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    self.transitionStatus = ControllerTransitionStatusDidMoveToParent;

    if ([self respondsToSelector:@selector(controllerTransitionHandler)]) {
        if (self.controllerTransitionHandler) self.controllerTransitionHandler(self, ControllerTransitionStatusDidMoveToParent);
    }
}

@end
