//  Created by Karen Lusinyan on 14/04/15.
//  Copyright (c) 2015 Karen Lusinyan. All rights reserved.

#import "CommonUtilsVersion.h"

@implementation CommonUtilsVersion

+ (void)load
{
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        NSLog(@"LibCommonUtils [%@]", kLibVersion);
    });
}

@end
