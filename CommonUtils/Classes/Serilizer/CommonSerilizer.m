//  Created by Karen Lusinyan on 12/03/15.
//  Copyright (c) 2015 Karen Lusinyan. All rights reserved.

#import "CommonSerilizer.h"
#import <objc/runtime.h>

@implementation CommonSerilizer

+ (id)loadObjectForKey:(NSString *)key
{
    NSData *decodedObject = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    if (decodedObject == nil) return nil;
    return [NSKeyedUnarchiver unarchiveObjectWithData:decodedObject];
}

+ (void)saveObject:(id)object forKey:(NSString *)key
{
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:object];
    if (encodedObject == nil) return;
    
    [[NSUserDefaults standardUserDefaults] setObject:encodedObject forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)removeObjectForKey:(id)key
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDictionary *)dictionaryFromObject:(NSObject *)object
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    Class clazz = [object class];
    u_int count;
    
    objc_property_t* properties = class_copyPropertyList(clazz, &count);
    NSMutableArray* propertyArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count ; i++)
    {
        const char* propertyName = property_getName(properties[i]);
        [propertyArray addObject:[NSString  stringWithCString:propertyName encoding:NSUTF8StringEncoding]];
    }
    free(properties);
    
    for (id propertyName in propertyArray) {
        id value = [object valueForKey:propertyName];
        if (value != nil) {
            [dict setObject:value forKey:propertyName];
        }
    }
    
    return dict;
}

@end
