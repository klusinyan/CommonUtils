//  Created by Karen Lusinyan on 17/10/14.
//  Copyright (c) 2014 Karen Lusinyan. All rights reserved.

#import "UIViewController+Utils.h"

@implementation UIViewController (Utils)

- (void)backButtonItemWithTitle:(NSString *)title
{
    UIBarButtonItem *backButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:title
                                     style:UIBarButtonItemStyleBordered
                                    target:nil
                                    action:nil];
    
    self.navigationItem.backBarButtonItem = backButtonItem;
}

@end
