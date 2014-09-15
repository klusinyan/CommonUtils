//  Created by Karen Lusinyan on 14/09/14.
//  Copyright (c) 2014 BtB Mobile. All rights reserved.

#import "CUReachability.h"

typedef NS_OPTIONS(NSInteger, NetworkStatusMask) {
    NetworkStatusMaskNotReachable=NotReachable,
    NetworkStatusMaskReachable=ReachableViaWWAN | ReachableViaWiFi
};

//notification of network reachbility status
extern NSString * const NetworkStatusChangedNotification;

//holds current reashability status
static NetworkStatus currentNetworkStatus;

@interface NetworkUtils : NSObject

+ (void)setupConnectionObserver;

@end
