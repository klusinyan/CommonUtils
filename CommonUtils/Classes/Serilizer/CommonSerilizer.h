//  Created by Karen Lusinyan on 12/03/15.
//  Copyright (c) 2015 Karen Lusinyan. All rights reserved.

@interface CommonSerilizer : NSObject

+ (id)loadObjectForKey:(NSString *)key;

+ (void)saveObject:(id)object forKey:(NSString *)key;

@end
