//  Created by Karen Lusinyan on 14/09/14.
//  Copyright (c) 2014 BtB Mobile. All rights reserved.

#import "NetworkUtils.h"

NSString * const NetworkStatusChangedNotification = @"NetworkStatusChangedNotification";

static CUReachability *reachability = nil;

@implementation NetworkUtils

+ (void)removeObservers
{
    [reachability stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//not used
+ (instancetype)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
        
    });
    return _sharedObject;
}

#pragma mark -
#pragma mark Reachability status

//public method
//setup connection observer to observe network reachability status
//should be called in init of coordinator
+ (void)setupConnectionObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkStatusDidChange:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    reachability = [CUReachability reachabilityForInternetConnection];
    [reachability startNotifier];
}

+ (NetworkStatus)currentNetworkStatus
{
    reachability = [CUReachability reachabilityForInternetConnection];
    return [reachability currentReachabilityStatus];
}

//private method
+ (void)networkStatusDidChange:(NSNotification *)notification
{
    CUReachability *curReach = [notification object];
    NetworkStatus currentNetworkStatus = [curReach currentReachabilityStatus];
    
    switch (currentNetworkStatus) {
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NetworkStatusChangedNotification
                                                        object:@(currentNetworkStatus)];
}

@end
