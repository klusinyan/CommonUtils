//  Created by Karen Lusinyan on 11/02/14.
//  Copyright (c) 2014 Karen Lusinyan. All rights reserved.

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

extern NSString * const BannerViewActionWillBegin;
extern NSString * const BannerViewActionDidFinish;

@protocol CommonBannerPrototype <NSObject>

@required
@property (readwrite, nonatomic, assign) BOOL canDisplayAds;        // default YES

@optional
@property (readwrite, nonatomic, assign) BOOL shouldResizeContent;  // default YES
@property (readwrite, nonatomic, assign) BOOL animated;             // default YES

@optional
- (void)bannerDidShow:(ADBannerView *)bannerView;
- (void)bannerDidHide:(ADBannerView *)bannerView;

@end

@interface CommonBanner : UIViewController

@end

@interface UIViewController (Prototype) <CommonBannerPrototype>

@end

@interface UITableViewController (Prototype) <CommonBannerPrototype>

@end
