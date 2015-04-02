//  Created by Karen Lusinyan on 12/03/15.
//  Copyright (c) 2015 Karen Lusinyan. All rights reserved.

#import "CommonSerilizer.h"

@implementation CommonSerilizer

+ (id)loadObjectForKey:(NSString *)key
{
    NSData *decodedObject = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    if (!decodedObject) return nil;
    return [NSKeyedUnarchiver unarchiveObjectWithData:decodedObject];
}

+ (void)saveObject:(id)object forKey:(NSString *)key
{
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:object];

    [[NSUserDefaults standardUserDefaults] setObject:encodedObject forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
