//  Created by Karen Lusinyan on 29/01/14.
//  Copyright (c) 2014 Home. All rights reserved.

#import "NSIndexPath+Utils.h"

@implementation NSIndexPath (Utils)

+ (NSString *)keyFromIndexPath:(NSIndexPath *)indexPath
{
    return [NSString stringWithFormat:@"%ld-%ld",(long)indexPath.section, (long)indexPath.row];
}

+ (NSIndexPath *)indexPathFromKey:(NSString *)key
{
    NSArray *components = [key componentsSeparatedByString:@"-"];
    if ([components count] == 2) {
        return [NSIndexPath indexPathForRow:[[components objectAtIndex:1] integerValue] inSection:[[components objectAtIndex:0] integerValue]];
    }
    return nil;
}

- (NSUInteger)tagFromIndexPath:(NSIndexPath *)indexPath
{
    return [[NSString stringWithFormat:@"%ld%ld", (long)indexPath.section, (long)indexPath.row] integerValue];
}

@end
