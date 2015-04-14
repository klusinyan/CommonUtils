//  Created by Karen Lusinyan on 09/04/15.
//  Copyright (c) 2015 Karen Lusinyan. All rights reserved.

#import "CommonTask.h"

@implementation CommonTask

+ (void)performBackgroundTask:(void (^)(void))backgroundTask
{
    UIApplication *application = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        // clean up any task
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // start background task immediately
        if (backgroundTask) backgroundTask();
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    });
}

@end
