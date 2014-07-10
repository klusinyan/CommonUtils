//  Created by Karen Lusinyan on 29/05/14.

#import "UITableView+Utils.h"

@implementation UITableView (Utils)

- (NSIndexPath *)indexPathForEditingCell
{
    NSUInteger index = [self.indexPathsForVisibleRows indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        UITableViewCell *cell = [self cellForRowAtIndexPath:obj];
        return cell.isEditing;
    }];
    
    if (index == NSNotFound)
        return nil;
    
    return self.indexPathsForVisibleRows[index];
}

- (NSIndexPath *)indexPathForEditingSubview:(UIView *)subview
{
    CGPoint pointInTable = [subview convertPoint:subview.bounds.origin toView:self];
    return [self indexPathForRowAtPoint:pointInTable];
}

- (UITableViewCell *)cellForEditingSubview:(UIView *)subview
{
    NSIndexPath *indexPath = [self indexPathForEditingSubview:subview];
    return [self cellForRowAtIndexPath:indexPath];
}

- (NSIndexPath *)indexPathForSelectedSubview:(UIView *)selectedSubview __deprecated
{
    // if found
    if ([[selectedSubview superview] isKindOfClass:[UITableViewCell class]]) {
        return [self indexPathForCell:(UITableViewCell *)[selectedSubview superview]];
    }
    // if it should continue searching
    else if ([selectedSubview superview] != nil) {
        return [self indexPathForSelectedSubview:[selectedSubview superview]];
    }
    // if there is no superview
    else {
        return nil;
    }
}

- (UITableViewCell *)cellForForSelectedSubview:(UIView *)selectedSubview __deprecated
{
    NSIndexPath *indexPath = [self indexPathForSelectedSubview:selectedSubview];
    return [self cellForRowAtIndexPath:indexPath];
}

@end
