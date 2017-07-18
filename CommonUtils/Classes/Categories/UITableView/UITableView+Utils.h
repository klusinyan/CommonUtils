//  Created by Karen Lusinyan on 29/05/14.

@interface UITableView (Utils)

// register cell
- (void)registerNib:(Class)aclass
         identifier:(NSString *)identifier;

// inlince cells
- (void)insertObjects:(NSArray *)objects
          atIndexPath:(NSIndexPath *)indexPath
       withDataSource:(NSMutableArray *)dataSource;

- (void)removeObjects:(NSArray *)objects
          atIndexPath:(NSIndexPath *)indexPath
       withDataSource:(NSMutableArray *)dataSource;

- (void)emptyLinesHidden;

@end
