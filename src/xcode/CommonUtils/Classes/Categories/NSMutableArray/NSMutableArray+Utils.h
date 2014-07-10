//  Created by Karen Lusinyan on 14/12/13.
//  Copyright (c) 2013 Karen Lusinyan. All rights reserved.

@interface NSMutableArray (Utils)

//Stack
- (id)pop;
- (void)push:(id)obj;

//Queue
- (id)dequeue;
- (void) enqueue:(id)anObject;

@end
