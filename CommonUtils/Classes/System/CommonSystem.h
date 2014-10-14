//  Created by Shmoopi LLC on 9/18/12.
//  Copyright (c) 2012 Shmoopi LLC. All rights reserved.

extern NSString * const kCurrentIPAddress;
extern NSString * const kCurrentMACAddress;
extern NSString * const kExternalIPAddress;
extern NSString * const kCellIPAddress;
extern NSString * const kCellMACAddress;
extern NSString * const kCellNetmaskAddress;
extern NSString * const kCellBroadcastAddress;
extern NSString * const kWiFiIPAddress;
extern NSString * const kWiFiMACAddress;
extern NSString * const kWiFiNetmaskAddress;
extern NSString * const kWiFiBroadcastAddress;
extern NSString * const kConnectedToWiFi;
extern NSString * const kConnectedToCellNetwork;

@interface CommonSystem : NSObject

// Network Information
+ (NSDictionary *)networkInfo;

// Get Current IP Address
+ (NSString *)currentIPAddress;

// Get Current MAC Address
+ (NSString *)currentMACAddress;

// Get the External IP Address
+ (NSString *)externalIPAddress;

// Get Cell IP Address
+ (NSString *)cellIPAddress;

// Get Cell MAC Address
+ (NSString *)cellMACAddress;

// Get Cell Netmask Address
+ (NSString *)cellNetmaskAddress;

// Get Cell Broadcast Address
+ (NSString *)cellBroadcastAddress;

// Get WiFi IP Address
+ (NSString *)wiFiIPAddress;

// Get WiFi MAC Address
+ (NSString *)wiFiMACAddress;

// Get WiFi Netmask Address
+ (NSString *)wiFiNetmaskAddress;

// Get WiFi Broadcast Address
+ (NSString *)wiFiBroadcastAddress;

// Connected to WiFi?
+ (BOOL)connectedToWiFi;

// Connected to Cellular Network?
+ (BOOL)connectedToCellNetwork;

@end
