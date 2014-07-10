//  Created by Karen Lusinyan on 29/05/14.

@interface UITableView (Utils)

- (NSIndexPath *)indexPathForEditingCell;

- (NSIndexPath *)indexPathForEditingSubview:(UIView *)subview;

- (UITableViewCell *)cellForEditingSubview:(UIView *)subview;

@end
