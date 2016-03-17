//  Created by Shmoopi LLC on 9/18/12.
//  Copyright (c) 2012 Shmoopi LLC. All rights reserved.

#import <arpa/inet.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <sys/ioctl.h>
#import <sys/sysctl.h>
#import <ifaddrs.h>

#import "AFNetworking.h"
#import "CommonSystem.h"

static __strong NSMutableDictionary *NETWORK_INFO = nil;

NSString * const kCurrentIPAddress          = @"currentIPAddress";
NSString * const kCurrentMACAddress         = @"currentMACAddress";
NSString * const kExternalIPAddress         = @"externalIPAddress";
NSString * const kCellIPAddress             = @"cellIPAddress";
NSString * const kCellMACAddress            = @"cellMACAddress";
NSString * const kCellNetmaskAddress        = @"cellNetmaskAddress";
NSString * const kCellBroadcastAddress      = @"cellBroadcastAddress";
NSString * const kWiFiIPAddress             = @"wiFiIPAddress";
NSString * const kWiFiMACAddress            = @"wiFiMACAddress";
NSString * const kWiFiNetmaskAddress        = @"wiFiNetmaskAddress";
NSString * const kWiFiBroadcastAddress      = @"wiFiBroadcastAddress";
NSString * const kConnectedToWiFi           = @"connectedToWiFi";
NSString * const kConnectedToCellNetwork    = @"connectedToCellNetwork";

@implementation CommonSystem

#define kUnknwon @"unknown"

+ (void)networkInfoWithCompletion:(NetworkInfoCompletionHandler)completion
{
    if (NETWORK_INFO == nil) {
        NETWORK_INFO = [NSMutableDictionary dictionary];
    }
    
    [NETWORK_INFO setObject:kUnknwon forKey:kCurrentIPAddress];
    [NETWORK_INFO setObject:kUnknwon forKey:kCurrentMACAddress];
    [NETWORK_INFO setObject:kUnknwon forKey:kExternalIPAddress];
    [NETWORK_INFO setObject:kUnknwon forKey:kCellIPAddress];
    [NETWORK_INFO setObject:kUnknwon forKey:kCellMACAddress];
    [NETWORK_INFO setObject:kUnknwon forKey:kCellNetmaskAddress];
    [NETWORK_INFO setObject:kUnknwon forKey:kCellBroadcastAddress];
    [NETWORK_INFO setObject:kUnknwon forKey:kWiFiIPAddress];
    [NETWORK_INFO setObject:kUnknwon forKey:kWiFiMACAddress];
    [NETWORK_INFO setObject:kUnknwon forKey:kWiFiNetmaskAddress];
    [NETWORK_INFO setObject:kUnknwon forKey:kWiFiBroadcastAddress];
    [NETWORK_INFO setObject:kUnknwon forKey:kConnectedToWiFi];
    [NETWORK_INFO setObject:kUnknwon forKey:kConnectedToCellNetwork];
    
    [self externalIPAddressWithCompletion:^(NSDictionary *networkInfo) {
        if ([self currentIPAddress])
            [NETWORK_INFO setObject:[self currentIPAddress] forKey:kCurrentIPAddress];
        if ([self currentMACAddress])
            [NETWORK_INFO setObject:[self currentMACAddress] forKey:kCurrentMACAddress];
        if ([self cellIPAddress])
            [NETWORK_INFO setObject:[self cellIPAddress] forKey:kCellIPAddress];
        if ([self cellMACAddress])
            [NETWORK_INFO setObject:[self cellMACAddress] forKey:kCellMACAddress];
        if ([self cellNetmaskAddress])
            [NETWORK_INFO setObject:[self cellNetmaskAddress] forKey:kCellNetmaskAddress];
        if ([self cellBroadcastAddress])
            [NETWORK_INFO setObject:[self cellBroadcastAddress] forKey:kCellBroadcastAddress];
        if ([self wiFiIPAddress])
            [NETWORK_INFO setObject:[self wiFiIPAddress] forKey:kWiFiIPAddress];
        if ([self wiFiMACAddress])
            [NETWORK_INFO setObject:[self wiFiMACAddress] forKey:kWiFiMACAddress];
        if ([self wiFiNetmaskAddress])
            [NETWORK_INFO setObject:[self wiFiNetmaskAddress] forKey:kWiFiNetmaskAddress];
        if ([self wiFiBroadcastAddress])
            [NETWORK_INFO setObject:[self wiFiBroadcastAddress] forKey:kWiFiBroadcastAddress];
        
        [NETWORK_INFO setObject:[self connectedToWiFi] ? @"yes" : @"no"  forKey:kConnectedToWiFi];
        [NETWORK_INFO setObject:[self connectedToCellNetwork] ? @"yes" : @"no" forKey:kConnectedToCellNetwork];
        
        if (completion) completion(NETWORK_INFO);
    }];
}

// Network Information

// Get Current IP Address
+ (NSString *)currentIPAddress
{
    // Get the current IP Address
    
    // Check which interface is currently in use
    if ([self connectedToWiFi]) {
        // WiFi is in use
        
        // Get the WiFi IP Address
        NSString *WiFiAddress = [self wiFiIPAddress];
        
        // Check that you get something back
        if (WiFiAddress == nil || WiFiAddress.length <= 0) {
            // Error, no address found
            return nil;
        }
        
        // Return Wifi address
        return WiFiAddress;
    } else if ([self connectedToCellNetwork]) {
        // Cell Network is in use
        
        // Get the Cell IP Address
        NSString *CellAddress = [self cellIPAddress];
        
        // Check that you get something back
        if (CellAddress == nil || CellAddress.length <= 0) {
            // Error, no address found
            return nil;
        }
        
        // Return Cell address
        return CellAddress;
    } else {
        // No interface in use
        return nil;
    }
}

// Get Current MAC Address
+ (NSString *)currentMACAddress
{
    // Get the current interface MAC Address
    
    // Check which interface is currently in use
    if ([self connectedToWiFi]) {
        // WiFi is in use
        
        // Get the WiFi MAC Address
        NSString *WiFiAddress = [self wiFiMACAddress];
        
        // Check that you get something back
        if (WiFiAddress == nil || WiFiAddress.length <= 0) {
            // Error, no address found
            return nil;
        }
        
        // Return Wifi address
        return WiFiAddress;
    } else if ([self connectedToCellNetwork]) {
        // Cell Network is in use
        
        // Get the Cell MAC Address
        NSString *CellAddress = [self cellMACAddress];
        
        // Check that you get something back
        if (CellAddress == nil || CellAddress.length <= 0) {
            // Error, no address found
            return nil;
        }
        
        // Return Cell address
        return CellAddress;
    } else {
        // No interface in use
        return nil;
    }
}

// Get the External IP Address
// not used: using externalIPAddressWithCompletion:
+ (NSString *)externalIPAddress
{
    @try {
        // Check if we have an internet connection then try to get the External IP Address
        if (![self connectedToCellNetwork] && ![self connectedToWiFi]) {
            // Not connected to anything, return nil
            return nil;
        }
        
        // Get the external IP Address based on dynsns.org
        NSError *error = nil;
        NSString *theIpHtml = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://www.dyndns.org/cgi-bin/check_ip.cgi"]
                                                       encoding:NSUTF8StringEncoding
                                                          error:&error];
        if (!error) {
            NSUInteger  an_Integer;
            NSArray * ipItemsArray;
            NSString *externalIP;
            NSScanner *theScanner;
            NSString *text = nil;
            
            theScanner = [NSScanner scannerWithString:theIpHtml];
            
            while ([theScanner isAtEnd] == NO) {
                
                // find start of tag
                [theScanner scanUpToString:@"<" intoString:NULL] ;
                
                // find end of tag
                [theScanner scanUpToString:@">" intoString:&text] ;
                
                // replace the found tag with a space
                //(you can filter multi-spaces out later if you wish)
                theIpHtml = [theIpHtml stringByReplacingOccurrencesOfString:
                             [ NSString stringWithFormat:@"%@>", text]
                                                                 withString:@" "] ;
                ipItemsArray = [theIpHtml  componentsSeparatedByString:@" "];
                an_Integer = [ipItemsArray indexOfObject:@"Address:"];
                
                externalIP =[ipItemsArray objectAtIndex:++an_Integer];
            }
            
            // Check that you get something back
            if (externalIP == nil || externalIP.length <= 0) {
                // Error, no address found
                return nil;
            }
            
            // Return External IP
            return externalIP;
        } else {
            // Error, no address found
            return nil;
        }
    }
    @catch (NSException *exception) {
        // Error, no address found
        return nil;
    }
}

// Get the External IP Address
+ (void)externalIPAddressWithCompletion:(NetworkInfoCompletionHandler)completion
{
    @try {
        NSURL *URL = [NSURL URLWithString:@"http://www.trackip.net/ip?json"];
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager GET:URL.absoluteString
          parameters:nil
            progress:nil
             success:^(NSURLSessionDataTask *task, id responseObject) {
                 NSError *error = nil;
                 NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                      options:NSJSONReadingMutableContainers
                                                                        error:&error];
                 if ([dict valueForKey:@"ip"])
                     [NETWORK_INFO setObject:[dict valueForKey:@"ip"] forKey:kExternalIPAddress];
                 
                 if (completion) completion(NETWORK_INFO);
             } failure:^(NSURLSessionDataTask *task, NSError *error) {
                 DebugLog(@"Network info error = %@",[error localizedDescription]);
                 if (completion) completion(NETWORK_INFO);
             }];
    }
    @catch (NSException *exception) {
        DebugLog(@"exeption network external ip address %@", exception);
        completion(NETWORK_INFO);
    }
    @finally {
        //do something
    }
}

// Get Cell IP Address
+ (NSString *)cellIPAddress
{
    // Get the Cell IP Address
    @try {
        // Set a string for the address
        NSString *IPAddress;
        // Set up structs to hold the interfaces and the temporary address
        struct ifaddrs *Interfaces;
        struct ifaddrs *Temp;
        struct sockaddr_in *s4;
        char buf[64];
        
        // If it's 0, then it's good
        if (!getifaddrs(&Interfaces))
        {
            // Loop through the list of interfaces
            Temp = Interfaces;
            
            // Run through it while it's still available
            while(Temp != NULL)
            {
                // If the temp interface is a valid interface
                if(Temp->ifa_addr->sa_family == AF_INET)
                {
                    // Check if the interface is Cell
                    if([[NSString stringWithUTF8String:Temp->ifa_name] isEqualToString:@"pdp_ip0"])
                    {
                        s4 = (struct sockaddr_in *)Temp->ifa_addr;
                        
                        if (inet_ntop(Temp->ifa_addr->sa_family, (void *)&(s4->sin_addr), buf, sizeof(buf)) == NULL) {
                            // Failed to find it
                            IPAddress = nil;
                        } else {
                            // Got the Cell IP Address
                            IPAddress = [NSString stringWithUTF8String:buf];
                        }
                    }
                }
                
                // Set the temp value to the next interface
                Temp = Temp->ifa_next;
            }
        }
        
        // Free the memory of the interfaces
        freeifaddrs(Interfaces);
        
        // Check to make sure it's not empty
        if (IPAddress == nil || IPAddress.length <= 0) {
            // Empty, return not found
            return nil;
        }
        
        // Return the IP Address of the WiFi
        return IPAddress;
    }
    @catch (NSException *exception) {
        // Error, IP Not found
        return nil;
    }
}

// Get Cell MAC Address
+ (NSString *)cellMACAddress
{
    // Get the Cell MAC Address
    @try {
        // Start by setting the variables to get the Cell Mac Address
        int                 mgmtInfoBase[6];
        char                *msgBuffer = NULL;
        size_t              length;
        unsigned char       macAddress[6];
        struct if_msghdr    *interfaceMsgStruct;
        struct sockaddr_dl  *socketStruct;
        
        // Setup the management Information Base (mib)
        mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
        mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
        mgmtInfoBase[2] = 0;
        mgmtInfoBase[3] = AF_LINK;        // Request link layer information
        mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
        
        // With all configured interfaces requested, get handle index
        if ((mgmtInfoBase[5] = if_nametoindex([@"pdp_ip0" UTF8String])) == 0)
            // Error, Name to index failure
            return nil;
        else
        {
            // Get the size of the data available (store in len)
            if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
                // Error, Sysctl MgmtInfoBase Failure
                return nil;
            else
            {
                // Alloc memory based on above call
                if ((msgBuffer = malloc(length)) == NULL)
                    // Error, Buffer allocation failure
                    return nil;
                else
                {
                    // Get system information, store in buffer
                    if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
                        // Error, Sysctl MsgBuffer Failure
                        return nil;
                }
            }
        }
        
        // Map msgbuffer to interface message structure
        interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
        
        // Map to link-level socket structure
        socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
        
        // Copy link layer address data in socket structure to an array
        memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
        
        // Read from char array into a string object, into traditional Mac address format
        NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                      macAddress[0], macAddress[1], macAddress[2],
                                      macAddress[3], macAddress[4], macAddress[5]];
        
        // Release the buffer memory
        free(msgBuffer);
        
        // Make a new string from the macAddressString
        NSString *deviceID = macAddressString;
        
        // If the device ID comes back empty
        if (deviceID == (id)[NSNull null] || deviceID.length <= 0) {
            // Return that the MAC address was not found
            return nil;
        }
        
        // Return Successful
        return deviceID;
    }
    @catch (NSException *exception) {
        // Error, return nil
        return nil;
    }
}

// Get Cell Netmask Address
+ (NSString *)cellNetmaskAddress
{
    // Get the Cell Netmask Address
    @try {
        // Set up the variable
        struct ifreq afr;
        // Copy the string
        strncpy(afr.ifr_name, [@"pdp_ip0" UTF8String], IFNAMSIZ-1);
        // Open a socket
        int afd = socket(AF_INET, SOCK_DGRAM, 0);
        
        // Check the socket
        if (afd == -1) {
            // Error, socket failed to open
            return nil;
        }
        
        // Check the netmask output
        if (ioctl(afd, SIOCGIFNETMASK, &afr) == -1) {
            // Error, netmask wasn't found
            // Close the socket
            close(afd);
            // Return error
            return nil;
        }
        
        // Close the socket
        close(afd);
        
        // Create a char for the netmask
        char *netstring = inet_ntoa(((struct sockaddr_in *)&afr.ifr_addr)->sin_addr);
        
        // Create a string for the netmask
        NSString *Netmask = [NSString stringWithUTF8String:netstring];
        
        // Check to make sure it's not nil
        if (Netmask == nil || Netmask.length <= 0) {
            // Error, netmask not found
            return nil;
        }
        
        // Return successful
        return Netmask;
    }
    @catch (NSException *exception) {
        // Error
        return nil;
    }
}

// Get Cell Broadcast Address
+ (NSString *)cellBroadcastAddress
{
    // Get the Cell Broadcast Address
    @try {
        // Set up strings for the IP and Netmask
        NSString *IPAddress = [self cellIPAddress];
        NSString *NMAddress = [self cellNetmaskAddress];
        
        // Check to make sure they aren't nil
        if (IPAddress == nil || IPAddress.length <= 0) {
            // Error, IP Address can't be nil
            return nil;
        }
        if (NMAddress == nil || NMAddress.length <= 0) {
            // Error, NM Address can't be nil
            return nil;
        }
        
        // Check the formatting of the IP and NM Addresses
        NSArray *IPCheck = [IPAddress componentsSeparatedByString:@"."];
        NSArray *NMCheck = [NMAddress componentsSeparatedByString:@"."];
        
        // Make sure the IP and NM Addresses are correct
        if (IPCheck.count != 4 || NMCheck.count != 4) {
            // Incorrect IP Addresses
            return nil;
        }
        
        // Set up the variables
        NSUInteger IP = 0;
        NSUInteger NM = 0;
        NSUInteger CS = 24;
        
        // Make the address based on the other addresses
        for (NSUInteger i = 0; i < 4; i++, CS -= 8) {
            IP |= [[IPCheck objectAtIndex:i] intValue] << CS;
            NM |= [[NMCheck objectAtIndex:i] intValue] << CS;
        }
        
        // Set it equal to the formatted raw addresses
        NSUInteger BA = ~NM | IP;
        
        // Make a string for the address
        NSString *BroadcastAddress = [NSString stringWithFormat:@"%@.%@.%@.%@", @((BA & 0xFF000000) >> 24),
                                      @((BA & 0x00FF0000) >> 16), @((BA & 0x0000FF00) >> 8), @(BA & 0x000000FF)];
        
        // Check to make sure the string is valid
        if (BroadcastAddress == nil || BroadcastAddress.length <= 0) {
            // Error, no address
            return nil;
        }
        
        // Return Successful
        return BroadcastAddress;
    }
    @catch (NSException *exception) {
        // Error
        return nil;
    }
}

// Get WiFi IP Address
+ (NSString *)wiFiIPAddress
{
    // Get the WiFi IP Address
    @try {
        // Set a string for the address
        NSString *IPAddress;
        // Set up structs to hold the interfaces and the temporary address
        struct ifaddrs *Interfaces;
        struct ifaddrs *Temp;
        // Set up int for success or fail
        int Status = 0;
        
        // Get all the network interfaces
        Status = getifaddrs(&Interfaces);
        
        // If it's 0, then it's good
        if (Status == 0)
        {
            // Loop through the list of interfaces
            Temp = Interfaces;
            
            // Run through it while it's still available
            while(Temp != NULL)
            {
                // If the temp interface is a valid interface
                if(Temp->ifa_addr->sa_family == AF_INET)
                {
                    // Check if the interface is WiFi
                    if([[NSString stringWithUTF8String:Temp->ifa_name] isEqualToString:@"en0"])
                    {
                        // Get the WiFi IP Address
                        IPAddress = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)Temp->ifa_addr)->sin_addr)];
                    }
                }
                
                // Set the temp value to the next interface
                Temp = Temp->ifa_next;
            }
        }
        
        // Free the memory of the interfaces
        freeifaddrs(Interfaces);
        
        // Check to make sure it's not empty
        if (IPAddress == nil || IPAddress.length <= 0) {
            // Empty, return not found
            return nil;
        }
        
        // Return the IP Address of the WiFi
        return IPAddress;
    }
    @catch (NSException *exception) {
        // Error, IP Not found
        return nil;
    }
}

// Get WiFi MAC Address
+ (NSString *)wiFiMACAddress
{
    // Get the WiFi MAC Address
    @try {
        // Start by setting the variables to get the WiFi Mac Address
        int                 mgmtInfoBase[6];
        char                *msgBuffer = NULL;
        size_t              length;
        unsigned char       macAddress[6];
        struct if_msghdr    *interfaceMsgStruct;
        struct sockaddr_dl  *socketStruct;
        
        // Setup the management Information Base (mib)
        mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
        mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
        mgmtInfoBase[2] = 0;
        mgmtInfoBase[3] = AF_LINK;        // Request link layer information
        mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
        
        // With all configured interfaces requested, get handle index
        if ((mgmtInfoBase[5] = if_nametoindex([@"en0" UTF8String])) == 0)
            // Error, Name to index failure
            return nil;
        else
        {
            // Get the size of the data available (store in len)
            if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
                // Error, Sysctl MgmtInfoBase Failure
                return nil;
            else
            {
                // Alloc memory based on above call
                if ((msgBuffer = malloc(length)) == NULL)
                    // Error, Buffer allocation failure
                    return nil;
                else
                {
                    // Get system information, store in buffer
                    if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
                        // Error, Sysctl MsgBuffer Failure
                        return nil;
                }
            }
        }
        
        // Map msgbuffer to interface message structure
        interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
        
        // Map to link-level socket structure
        socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
        
        // Copy link layer address data in socket structure to an array
        memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
        
        // Read from char array into a string object, into traditional Mac address format
        NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                      macAddress[0], macAddress[1], macAddress[2],
                                      macAddress[3], macAddress[4], macAddress[5]];
        
        // Release the buffer memory
        free(msgBuffer);
        
        // Make a new string from the macAddressString
        NSString *deviceID = macAddressString;
        
        // If the device ID comes back empty
        if (deviceID == (id)[NSNull null] || deviceID.length <= 0) {
            // Return that the MAC address was not found
            return nil;
        }
        
        // Return Successful
        return deviceID;
    }
    @catch (NSException *exception) {
        // Error, return nil
        return nil;
    }
}

// Get WiFi Netmask Address
+ (NSString *)wiFiNetmaskAddress
{
    // Get the WiFi Netmask Address
    @try {
        // Set up the variable
        struct ifreq afr;
        // Copy the string
        strncpy(afr.ifr_name, [@"en0" UTF8String], IFNAMSIZ-1);
        // Open a socket
        int afd = socket(AF_INET, SOCK_DGRAM, 0);
        
        // Check the socket
        if (afd == -1) {
            // Error, socket failed to open
            return nil;
        }
        
        // Check the netmask output
        if (ioctl(afd, SIOCGIFNETMASK, &afr) == -1) {
            // Error, netmask wasn't found
            // Close the socket
            close(afd);
            // Return error
            return nil;
        }
        
        // Close the socket
        close(afd);
        
        // Create a char for the netmask
        char *netstring = inet_ntoa(((struct sockaddr_in *)&afr.ifr_addr)->sin_addr);
        
        // Create a string for the netmask
        NSString *Netmask = [NSString stringWithUTF8String:netstring];
        
        // Check to make sure it's not nil
        if (Netmask == nil || Netmask.length <= 0) {
            // Error, netmask not found
            return nil;
        }
        
        // Return successful
        return Netmask;
    }
    @catch (NSException *exception) {
        // Error
        return nil;
    }
}

// Get WiFi Broadcast Address
+ (NSString *)wiFiBroadcastAddress
{
    // Get the WiFi Broadcast Address
    @try {
        // Set up strings for the IP and Netmask
        NSString *IPAddress = [self wiFiIPAddress];
        NSString *NMAddress = [self wiFiNetmaskAddress];
        
        // Check to make sure they aren't nil
        if (IPAddress == nil || IPAddress.length <= 0) {
            // Error, IP Address can't be nil
            return nil;
        }
        if (NMAddress == nil || NMAddress.length <= 0) {
            // Error, NM Address can't be nil
            return nil;
        }
        
        // Check the formatting of the IP and NM Addresses
        NSArray *IPCheck = [IPAddress componentsSeparatedByString:@"."];
        NSArray *NMCheck = [NMAddress componentsSeparatedByString:@"."];
        
        // Make sure the IP and NM Addresses are correct
        if (IPCheck.count != 4 || NMCheck.count != 4) {
            // Incorrect IP Addresses
            return nil;
        }
        
        // Set up the variables
        NSUInteger IP = 0;
        NSUInteger NM = 0;
        NSUInteger CS = 24;
        
        // Make the address based on the other addresses
        for (NSUInteger i = 0; i < 4; i++, CS -= 8) {
            IP |= [[IPCheck objectAtIndex:i] intValue] << CS;
            NM |= [[NMCheck objectAtIndex:i] intValue] << CS;
        }
        
        // Set it equal to the formatted raw addresses
        NSUInteger BA = ~NM | IP;
        
        // Make a string for the address
        NSString *BroadcastAddress = [NSString stringWithFormat:@"%@.%@.%@.%@", @((BA & 0xFF000000) >> 24),
                                      @((BA & 0x00FF0000) >> 16), @((BA & 0x0000FF00) >> 8), @(BA & 0x000000FF)];
        
        // Check to make sure the string is valid
        if (BroadcastAddress == nil || BroadcastAddress.length <= 0) {
            // Error, no address
            return nil;
        }
        
        // Return Successful
        return BroadcastAddress;
    }
    @catch (NSException *exception) {
        // Error
        return nil;
    }
}

// Connected to WiFi?
+ (BOOL)connectedToWiFi
{
    // Check if we're connected to WiFi
    NSString *WiFiAddress = [self wiFiIPAddress];
    // Check if the string is populated
    if (WiFiAddress == nil || WiFiAddress.length <= 0) {
        // Nothing found
        return false;
    } else {
        // WiFi in use
        return true;
    }
}

// Connected to Cellular Network?
+ (BOOL)connectedToCellNetwork
{
    // Check if we're connected to cell network
    NSString *CellAddress = [self cellIPAddress];
    // Check if the string is populated
    if (CellAddress == nil || CellAddress.length <= 0) {
        // Nothing found
        return false;
    } else {
        // Cellular Network in use
        return true;
    }
}

// Total Disk Space
+ (NSString *)diskSpace {
    // Get the total disk space
    @try {
        // Get the long total disk space
        long long Space = [self longDiskSpace];
        
        // Check to make sure it's valid
        if (Space <= 0) {
            // Error, no disk space found
            return nil;
        }
        
        // Turn that long long into a string
        NSString *DiskSpace = [self formatMemory:Space];
        
        // Check to make sure it's valid
        if (DiskSpace == nil || DiskSpace.length <= 0) {
            // Error, diskspace not given
            return nil;
        }
        
        // Return successful
        return DiskSpace;
    }
    @catch (NSException * ex) {
        // Error
        return nil;
    }
}

// Total Free Disk Space
+ (NSString *)freeDiskSpace:(BOOL)inPercent {
    // Get the total free disk space
    @try {
        // Get the long size of free space
        long long Space = [self longFreeDiskSpace];
        
        // Check to make sure it's valid
        if (Space <= 0) {
            // Error, no disk space found
            return nil;
        }
        
        // Set up the string output variable
        NSString *DiskSpace;
        
        // If the user wants the output in percentage
        if (inPercent) {
            // Get the total amount of space
            long long TotalSpace = [self longDiskSpace];
            // Make a float to get the percent of those values
            float PercentDiskSpace = (Space * 100) / TotalSpace;
            // Check it to make sure it's okay
            if (PercentDiskSpace <= 0) {
                // Error, invalid percent
                return nil;
            }
            // Convert that float to a string
            DiskSpace = [NSString stringWithFormat:@"%.f%%", PercentDiskSpace];
        } else {
            // Turn that long long into a string
            DiskSpace = [self formatMemory:Space];
        }
        
        // Check to make sure it's valid
        if (DiskSpace == nil || DiskSpace.length <= 0) {
            // Error, diskspace not given
            return nil;
        }
        
        // Return successful
        return DiskSpace;
    }
    @catch (NSException * ex) {
        // Error
        return nil;
    }
}

// Total Used Disk Space
+ (NSString *)usedDiskSpace:(BOOL)inPercent {
    // Get the total used disk space
    @try {
        // Make a variable to hold the Used Disk Space
        long long UDS;
        // Get the long total disk space
        long long TDS = [self longDiskSpace];
        // Get the long free disk space
        long long FDS = [self longFreeDiskSpace];
        
        // Make sure they're valid
        if (TDS <= 0 || FDS <= 0) {
            // Error, invalid values
            return nil;
        }
        
        // Now subtract the free space from the total space
        UDS = TDS - FDS;
        
        // Make sure it's valid
        if (UDS <= 0) {
            // Error, invalid value
            return nil;
        }
        
        // Set up the string output variable
        NSString *UsedDiskSpace;
        
        // If the user wants the output in percentage
        if (inPercent) {
            // Make a float to get the percent of those values
            float PercentUsedDiskSpace = (UDS * 100) / TDS;
            // Check it to make sure it's okay
            if (PercentUsedDiskSpace <= 0) {
                // Error, invalid percent
                return nil;
            }
            // Convert that float to a string
            UsedDiskSpace = [NSString stringWithFormat:@"%.f%%", PercentUsedDiskSpace];
        } else {
            // Turn that long long into a string
            UsedDiskSpace = [self formatMemory:UDS];
        }
        
        // Check to make sure it's valid
        if (UsedDiskSpace == nil || UsedDiskSpace.length <= 0) {
            // Error, diskspace not given
            return nil;
        }
        
        // Return successful
        return UsedDiskSpace;
        
        // Now convert that to a string
    }
    @catch (NSException *exception) {
        // Error
        return nil;
    }
}

#pragma mark - Disk Information Long Values

// Get the total disk space in long format
+ (long long)longDiskSpace {
    // Get the long long disk space
    @try {
        // Set up variables
        long long DiskSpace = 0L;
        NSError *Error = nil;
        NSDictionary *FileAttributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&Error];
        
        // Get the file attributes of the home directory assuming no errors
        if (Error == nil) {
            // Get the size of the filesystem
            DiskSpace = [[FileAttributes objectForKey:NSFileSystemSize] longLongValue];
        } else {
            // Error, return nil
            return -1;
        }
        
        // Check to make sure it's a valid size
        if (DiskSpace <= 0) {
            // Invalid size
            return -1;
        }
        
        // Successful
        return DiskSpace;
    }
    @catch (NSException *exception) {
        // Error
        return -1;
    }
}

// Get the total free disk space in long format
+ (long long)longFreeDiskSpace {
    // Get the long total free disk space
    @try {
        // Set up the variables
        long long FreeDiskSpace = 0L;
        NSError *Error = nil;
        NSDictionary *FileAttributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&Error];
        
        // Get the file attributes of the home directory assuming no errors
        if (Error == nil) {
            FreeDiskSpace = [[FileAttributes objectForKey:NSFileSystemFreeSize] longLongValue];
        } else {
            // There was an error
            return -1;
        }
        
        // Check for valid size
        if (FreeDiskSpace <= 0) {
            // Invalid size
            return -1;
        }
        
        // Successful
        return FreeDiskSpace;
    }
    @catch (NSException *exception) {
        // Error
        return -1;
    }
}

#pragma mark - Memory Value Formatting

// Format the memory to a string in GB, MB, or Bytes
+ (NSString *)formatMemory:(long long)Space {
    // Format the long long disk space
    @try {
        // Set up the string
        NSString *FormattedBytes = nil;
        
        // Get the bytes, megabytes, and gigabytes
        double NumberBytes = 1.0 * Space;
        double TotalGB = NumberBytes / GB;
        double TotalMB = NumberBytes / MB;
        
        // Display them appropriately
        if (TotalGB >= 1.0) {
            FormattedBytes = [NSString stringWithFormat:@"%.2f GB", TotalGB];
        } else if (TotalMB >= 1)
            FormattedBytes = [NSString stringWithFormat:@"%.2f MB", TotalMB];
        else {
            FormattedBytes = [self formattedMemory:Space];
            FormattedBytes = [FormattedBytes stringByAppendingString:@" bytes"];
        }
        
        // Check for errors
        if (FormattedBytes == nil || FormattedBytes.length <= 0) {
            // Error, invalid string
            return nil;
        }
        
        // Completed Successfully
        return FormattedBytes;
    }
    @catch (NSException *exception) {
        // Error
        return nil;
    }
}

// Format bytes to a string
+ (NSString *)formattedMemory:(unsigned long long)Space {
    // Format for bytes
    @try {
        // Set up the string variable
        NSString *FormattedBytes = nil;
        
        // Set up the format variable
        NSNumberFormatter *Formatter = [[NSNumberFormatter alloc] init];
        
        // Format the bytes
        [Formatter setPositiveFormat:@"###,###,###,###"];
        
        // Get the bytes
        NSNumber * theNumber = [NSNumber numberWithLongLong:Space];
        
        // Format the bytes appropriately
        FormattedBytes = [Formatter stringFromNumber:theNumber];
        
        // Check for errors
        if (FormattedBytes == nil || FormattedBytes.length <= 0) {
            // Error, invalid value
            return nil;
        }
        
        // Completed Successfully
        return FormattedBytes;
    }
    @catch (NSException *exception) {
        // Error
        return nil;
    }
}

@end
