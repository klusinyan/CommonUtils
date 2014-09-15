//  Created by Karen Lusinyan on 14/09/14.
//  Copyright (c) 2014 BtB Mobile. All rights reserved.

#import "CUReachability.h"

//per avere la notifica della connessione iscriversi alla notifica "kReachabilityChangedNotification"

typedef NS_OPTIONS(NSInteger, NetworkStatusMask) {
    NetworkStatusMaskNotReachable=NotReachable,
    NetworkStatusMaskReachable=ReachableViaWWAN | ReachableViaWiFi
};

@interface NetworkUtils : NSObject

+ (instancetype)initSharedInstanceWithConnectionObserver;

+ (NetworkStatus)currentNetworkStatus;

@end
