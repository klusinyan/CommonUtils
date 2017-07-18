//  Created by Karen Lusinyan on 29/05/14.

#import "UITableView+Utils.h"

@implementation UITableView (Utils)

// register cell
- (void)registerNib:(Class)aclass
         identifier:(NSString *)identifier
{
    UINib *nib = [UINib nibWithNibName:NSStringFromClass(aclass) bundle:nil];
    [self registerNib:nib forCellReuseIdentifier:identifier];
}

// inline cells
- (void)insertObjects:(NSArray *)objects
          atIndexPath:(NSIndexPath *)indexPath
       withDataSource:(NSMutableArray *)dataSource
{
    if (objects == nil || dataSource == nil) {
        return;
    }
    
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (int i = 0; i < [objects count]; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:indexPath.row+(i+1) inSection:0]];
    }
    
    // wrap begin updates
    [self beginUpdates];
    
    // add objects to data source
    [dataSource insertObjects:objects atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(indexPath.row+1, [objects count])]];
    
    // insert in tableview animated
    [self insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
    
    // wrap end updates
    [self endUpdates];
    
    [self scrollToRowAtIndexPath:[indexPaths lastObject] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)removeObjects:(NSArray *)objects
          atIndexPath:(NSIndexPath *)indexPath
       withDataSource:(NSMutableArray *)dataSource
{
    if (objects == nil || dataSource == nil) {
        return;
    }
    
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (int i = 0; i < [objects count]; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:indexPath.row+(i+1) inSection:0]];
    }
    
    // wrap begin updates
    [self beginUpdates];
    
    // add objects to data source
    [dataSource removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(indexPath.row+1, [objects count])]];
    
    // insert in tableview animated
    [self deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    
    // wrap end updates
    [self endUpdates];
    
    [self scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)emptyLinesHidden
{
    self.tableFooterView = [UIView new];
}

@end
