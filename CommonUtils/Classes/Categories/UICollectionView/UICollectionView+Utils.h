//  Created by Karen Lusinyan on 23/06/14.
//  Copyright (c) 2014 KL. All rights reserved.

@interface UICollectionView (Utils)

- (NSIndexPath *)indexPathForEditingSubview:(UIView *)subview;

- (UICollectionViewCell *)cellForEditingSubview:(UIView *)subview;

@end
