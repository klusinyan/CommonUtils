# CommonUtils

[![CI Status](http://img.shields.io/travis/Karen Lusinyan/CommonUtils.svg?style=flat)](https://travis-ci.org/Karen Lusinyan/CommonUtils)
[![Version](https://img.shields.io/cocoapods/v/CommonUtils.svg?style=flat)](http://cocoapods.org/pods/CommonUtils)
[![License](https://img.shields.io/cocoapods/l/CommonUtils.svg?style=flat)](http://cocoapods.org/pods/CommonUtils)
[![Platform](https://img.shields.io/cocoapods/p/CommonUtils.svg?style=flat)](http://cocoapods.org/pods/CommonUtils)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## CommonNotification Example

## Step 1: How to configure

AppDelegate.m
```
#import "CommonNotificationManager.h"

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // in-app notification's basic configuration
    
    [CommonNotificationManager sharedInstance].checkNotificationsTimeInterval = 1.0;
    [CommonNotificationManager sharedInstance].imageIcon = [UIImage imageNamed:@"apple"];
    [CommonNotificationManager sharedInstance].notificationHeight = 120.0;
    
    ... do your other staff
}
```

## Step 2: How to add notification
```
    // alertBody: notification title
    // alertMessage: notification message
    // alertAction: noticiation action that will be executed when notificaiton did tap
    // fireDate: notification valid date, if [NSDate date] > fireDate the notification will be removed, nil means it will be allive until presented
    // priority: if it's High, then the notification will be presented immediately
    
    [[CommonNotificationManager sharedInstance] addNotificationWithAlertBody:@"Message"
                                                                alertMessage:@"Lorem ipsum..."
                                                                 alertAction:@"actionName"
                                                                    fireDate:nil
                                                                    priority:CommonNotificationPriorityDefault];

```

## Step 3: How to perform the notification action when tapped

```
    [[NSNotificationCenter defaultCenter] addObserverForName:CommonNotificationDidTap
                                                      object:nil
                                                       queue:[NSOperationQueue currentQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      if ([[note object] isMemberOfClass:[CommonNotification class]]) {
                                                          CommonNotification *notification = (CommonNotification *)[note object];
                                                          // do something with notification
                                                      }
                                                  }];
```

## Requirements

## Installation

CommonUtils is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "CommonUtils"
```

## Author

Karen Lusinyan, karen.lusinyan.developerios@gmail.com

## License

CommonUtils is available under the MIT license. See the LICENSE file for more info.

RELEASE-INFO: pod trunk push CommonUtils.podspec
