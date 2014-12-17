//  Created by Karen Lusinyan on 14/08/14.

#import "UIViewController+ChildrenHandler.h"

@implementation UIViewController (ChildrenHandler)
@dynamic controllerTransitionHandler;

- (void)parentViewController:(UIViewController *)parentViewController
      addChildViewController:(UIViewController<ChildControllerDelegate> *)childViewController
               containerView:(UIView *)containerView
                  completion:(ControllerTransintionHandler)completion
{
    childViewController.controllerTransitionHandler = ^(UIViewController *controller, ControllerTransitionStatus transitionStatus) {
        if (completion) completion(controller, transitionStatus);
    };
    
    //if container view is nil -> assign it self.view as a default value
    if (!containerView) containerView = self.view;

    [parentViewController addChildViewController:childViewController];
    [childViewController didMoveToParentViewController:parentViewController];
    childViewController.view.frame = containerView.bounds;
    [containerView addSubview:childViewController.view];

    //set constrains to childView
    childViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    //create bidings dictionary
    NSDictionary *bindings = @{@"childView" : childViewController.view};
    
    //assign contstrains
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[childView]|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:bindings]];
    
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[childView]|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:bindings]];
}

- (void)parentViewController:(UIViewController *)parentViewController
   removeChildViewController:(UIViewController<ChildControllerDelegate> *)childViewController
                  completion:(ControllerTransintionHandler)completion
{
    childViewController.controllerTransitionHandler = ^(UIViewController *controller, ControllerTransitionStatus transitionStatus) {
        if (completion) completion(controller, transitionStatus);
    };

    [childViewController willMoveToParentViewController:parentViewController];
    [childViewController removeFromParentViewController];
}

- (void)dismissChildrenViewControllerWithCompletion:(ControllerTransintionHandler)completion
{
    for (UIViewController *childViewController in self.childViewControllers) {
        childViewController.controllerTransitionHandler = ^(UIViewController *controller, ControllerTransitionStatus transitionStatus) {
            if (completion) completion(controller, transitionStatus);
        };
        
        [childViewController willMoveToParentViewController:nil];
        [childViewController.view removeFromSuperview];
        [childViewController removeFromParentViewController];
    }
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    if ([self respondsToSelector:@selector(controllerTransitionHandler)]) {
        if (self.controllerTransitionHandler) self.controllerTransitionHandler(self, ControllerTransitionStatusWillMoveToParent);
    }
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    if ([self respondsToSelector:@selector(controllerTransitionHandler)]) {
        if (self.controllerTransitionHandler) self.controllerTransitionHandler(self, ControllerTransitionStatusDidMoveToParent);
    }
}

@end
