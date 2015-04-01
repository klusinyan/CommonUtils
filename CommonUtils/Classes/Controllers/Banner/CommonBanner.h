//  Created by Karen Lusinyan on 11/02/14.
//  Copyright (c) 2014 Karen Lusinyan. All rights reserved.

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@protocol CommonBannerAdapter <NSObject>

@required
@property (readwrite, nonatomic, assign) BOOL canDisplayAds;

@optional
@property (readwrite, nonatomic, assign) BOOL shouldCoverContent;
@property (readwrite, nonatomic, assign) BOOL animated;             

@optional
- (void)bannerViewDidLoadAd:(ADBannerView *)banner;
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error;
- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave;
- (void)bannerViewActionDidFinish:(ADBannerView *)banner;

@end

@interface CommonBanner : UIViewController

/*!
 *  @brief  Call this method to start managing banners
 */
+ (void)startManaging;

/*!
 *  @brief  Call this method to stop managing banners
 */
+ (void)stopManaging;

@end

@interface UIViewController (BannerAdapter) <CommonBannerAdapter>

@end

@interface UITableViewController (BannerAdapter) <CommonBannerAdapter>

@end
