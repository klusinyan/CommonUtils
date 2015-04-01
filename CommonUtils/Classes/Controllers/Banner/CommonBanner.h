//  Created by Karen Lusinyan on 11/02/14.
//  Copyright (c) 2014 Karen Lusinyan. All rights reserved.

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

extern NSString * const BannerViewActionWillBegin;
extern NSString * const BannerViewActionDidFinish;

@protocol CommonBannerAdapter <NSObject>

@required
@property (readwrite, nonatomic, assign) BOOL canDisplayAds;

@optional
@property (readwrite, nonatomic, assign) BOOL shouldCoverContent;
@property (readwrite, nonatomic, assign) BOOL animated;             

@optional
- (void)bannerDidShow:(ADBannerView *)bannerView;
- (void)bannerDidHide:(ADBannerView *)bannerView;

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
