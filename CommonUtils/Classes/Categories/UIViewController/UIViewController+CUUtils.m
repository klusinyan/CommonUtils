//  Created by Karen Lusinyan on 17/10/14.
//  Copyright (c) 2014 Karen Lusinyan. All rights reserved.

#import "UIViewController+CUUtils.h"

@implementation UIViewController (CUUtils)

- (void)backButtonItemWithTitle:(NSString *)title target:(id)target action:(SEL)action
{
    UIBarButtonItem *backButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:title
                                     style:UIBarButtonItemStyleBordered
                                    target:target
                                    action:action];
    
    self.navigationItem.backBarButtonItem = backButtonItem;
}

@end
