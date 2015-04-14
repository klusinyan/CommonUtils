//  Created by Karen Lusinyan on 29/01/14.
//  Copyright (c) 2014 Home. All rights reserved.

@interface NSIndexPath (Utils)

+ (NSString *)keyFromIndexPath:(NSIndexPath *)indexPath;

+ (NSIndexPath *)indexPathFromKey:(NSString *)key;

- (NSUInteger)tagFromIndexPath:(NSIndexPath *)indexPath;

@end

