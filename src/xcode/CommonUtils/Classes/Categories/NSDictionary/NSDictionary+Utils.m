//  Created by Karen Lusinyan on 22/04/14.

#import "NSDictionary+Utils.h"

@implementation NSDictionary (Utils)

- (id)objectForKeyNotNull:(id)key
{
    id object = [self objectForKey:key];
    if (object == [NSNull null]) return nil;
    return object;
}

@end
