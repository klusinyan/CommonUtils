//  Created by Karen Lusinyan on 29/01/14.
//  Copyright (c) 2014 Home. All rights reserved.

#import "NSIndexPath+Utils.h"

@implementation NSIndexPath (Utils)

- (NSString *)keyFromIndexPath
{
    return [NSString stringWithFormat:@"%ld-%ld",(long)self.section,(long)self.row];
}

- (NSUInteger)tagFromIndexPath
{
    return [[NSString stringWithFormat:@"%ld%ld", (long)self.section, (long)self.row] integerValue];
}

@end
