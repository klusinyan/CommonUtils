//  Created by Karen Lusinyan on 09/04/15.
//  Copyright (c) 2015 Karen Lusinyan. All rights reserved.

@interface CommonTask : NSObject

+ (void)performBackgroundTask:(void (^)(void))backgroundTask;

@end
