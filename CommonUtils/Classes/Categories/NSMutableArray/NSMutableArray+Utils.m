//  Created by Karen Lusinyan on 14/12/13.
//  Copyright (c) 2013 Karen Lusinyan. All rights reserved.

#import "NSMutableArray+Utils.h"

@implementation NSMutableArray (Utils)

#pragma mark -
#pragma mark Stack

- (id)pop
{
    if ([self count] == 0) return nil;
    id lastObject = [self lastObject];
    if (lastObject)
        [self removeLastObject];
    return lastObject;
}

- (void)push:(id)obj
{
    [self addObject: obj];
}

#pragma mark -
#pragma mark Queue

- (id)dequeue
{
    if ([self count] == 0) return nil; // to avoid raising exception (Quinn)
    id headObject = [self objectAtIndex:0];
    if (headObject != nil) {
        [self removeObjectAtIndex:0];
    }
    return headObject;
}

- (void) enqueue:(id)anObject
{
    [self addObject:anObject];
}

@end
