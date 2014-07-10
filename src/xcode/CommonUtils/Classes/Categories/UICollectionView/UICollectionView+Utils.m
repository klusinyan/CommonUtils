//  Created by Karen Lusinyan on 23/06/14.
//  Copyright (c) 2014 KL. All rights reserved.

#import "UICollectionView+Utils.h"

@implementation UICollectionView (Utils)

- (NSIndexPath *)indexPathForEditingSubview:(UIView *)subview
{
    CGPoint pointInTable = [subview convertPoint:subview.bounds.origin toView:self];
    return [self indexPathForItemAtPoint:pointInTable];
}

- (UICollectionViewCell *)cellForEditingSubview:(UIView *)subview
{
    NSIndexPath *indexPath = [self indexPathForEditingSubview:subview];
    return [self cellForItemAtIndexPath:indexPath];
}

@end
