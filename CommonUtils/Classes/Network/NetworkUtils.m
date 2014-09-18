//  Created by Karen Lusinyan on 14/09/14.
//  Copyright (c) 2014 BtB Mobile. All rights reserved.

#import "NetworkUtils.h"

static CUReachability *reachability = nil;

@implementation NetworkUtils

#pragma mark -
#pragma mark Reachability status

//public method
//setup connection observer to observe network reachability status
//should be called in init of coordinator
+ (void)setupConnectionObserver
{
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(networkStatusDidChange:)
                                                     name:kReachabilityChangedNotification
                                                   object:nil];
        
        reachability = [CUReachability reachabilityForInternetConnection];
        [reachability startNotifier];
        
        [self printNetworkStatusWith:[reachability currentReachabilityStatus]];
    });
}

+ (NetworkStatus)currentNetworkStatus
{
    NetworkStatus currentNetworkStatus = [reachability currentReachabilityStatus];
    [self printNetworkStatusWith:currentNetworkStatus];
    return currentNetworkStatus;
}

//private method (only debug)
+ (void)networkStatusDidChange:(NSNotification *)notification
{
    CUReachability *curReach = [notification object];
    NetworkStatus currentNetworkStatus = [curReach currentReachabilityStatus];
    [self printNetworkStatusWith:currentNetworkStatus];
}

+ (void)printNetworkStatusWith:(NetworkStatus)networkStatus
{
    switch (networkStatus) {
        case NotReachable: {
            DebugLog(@"Nessuna rete");
            break;
        }
        case ReachableViaWiFi: {
            DebugLog(@"Wi-Fi connesso");
            break;
        }
        case ReachableViaWWAN: {
            DebugLog(@"WWAN connesso");
            break;
        }
        default:
            break;
    }
}

//used for remove observer
+ (void)removeConnectionObserver
{
    [reachability stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
