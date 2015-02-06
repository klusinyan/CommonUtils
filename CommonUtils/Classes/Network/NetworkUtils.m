//  Created by Karen Lusinyan on 03/11/14.
//  Copyright (c) 2014 Karen Lusinyan. All rights reserved.

#import "NetworkUtils.h"

@implementation NetworkUtils

/*
+ (void)setNetworkActivityIndicatorVisible:(BOOL)setVisible
{
    static NSInteger NumberOfCallsToSetVisible = 0;
    if (setVisible)
        NumberOfCallsToSetVisible++;
    else
        NumberOfCallsToSetVisible--;
    
    // The assertion helps to find programmer errors in activity indicator management.
    // Since a negative NumberOfCallsToSetVisible is not a fatal error,
    // it should probably be removed from production code.
    //NSAssert(NumberOfCallsToSetVisible >= 0, @"Network Activity Indicator was asked to hide more often than shown");
    
    // Display the indicator as long as our static counter is > 0.
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:(NumberOfCallsToSetVisible > 0)];
}
//*/

+ (void)setNetworkActivityIndicatorVisible:(BOOL)setVisible
{
    /*
    DebugLog(@"--------------requesting--------------");
    DebugLog(@"setVisible %@", setVisible ? @"Y" : @"N");
    DebugLog(@"isNetworkActivityIndicatorVisible %@", [[UIApplication sharedApplication] isNetworkActivityIndicatorVisible] ? @"Y" : @"N");
    DebugLog(@"--------------requesting--------------\n");
    //*/
    
    if ((setVisible && [[UIApplication sharedApplication] isNetworkActivityIndicatorVisible]) ||
       (!setVisible && ![[UIApplication sharedApplication] isNetworkActivityIndicatorVisible]))
        return;

    DebugLog(@"--------------///////--------------");
    DebugLog(@"setVisible %@", setVisible ? @"Y" : @"N");
    DebugLog(@"isNetworkActivityIndicatorVisible %@", [[UIApplication sharedApplication] isNetworkActivityIndicatorVisible] ? @"Y" : @"N");
    DebugLog(@"--------------\\\\\\\\\\\\\\--------------\n");

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:setVisible];
}

@end
