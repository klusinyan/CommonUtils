//  Created by Karen Lusinyan on 11/02/14.
//  Copyright (c) 2014 Karen Lusinyan. All rights reserved.

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

extern NSString * const CommonBannerDidCompleteSetup;

typedef NS_ENUM(NSInteger, CommonBannerPosition) {
    CommonBannerPositionBottom=0,
    CommonBannerPositionTop
};

@protocol CommonBannerAdapter <NSObject>

@required
@property (readwrite, nonatomic, assign) BOOL canDisplayAds;

@optional
@property (readwrite, nonatomic, assign) BOOL shouldCoverContent;
@property (readwrite, nonatomic, assign) BOOL animated;

@optional
- (void)bannerViewActionShouldBegin;
- (void)bannerViewActionDidFinish;

@end

@protocol CommonBannerPovider <NSObject>

@required
@property (readonly, nonatomic) UIView *bannerView;

@required
+ (instancetype)sharedInstance;
- (BOOL)isBannerLoaded;

@end

typedef NS_ENUM(NSInteger, CommonBannerPriority) {
    CommonBannerPriorityLow=0,
    CommonBannerPriorityHigh
};

@interface CommonBanner : UIViewController

/*!
 *  @brief  Call this method to initialize provider bannner
 *
 *  @param provider reflection class of type CommonBannerProvideriAd, CommonBannerProviderGAd
 *  @param priority of type CommonBannerPriority
 */
+ (void)regitserProvider:(Class)provider withPriority:(CommonBannerPriority)priority;

/*!
 *  @brief  Call this method to start managing banners
 */
+ (void)startManaging;

/*!
 *  @brief  Call this method to stop managing banners. Important: when stopped can not be restarted again, restart the app.
 */
+ (void)stopManaging;

/*!
 *  @brief  Call this method to set banner position
 *
 *  @param bannerPosition Default value is CommonBannerPositionBottom.
 *  @warning Setup once
 *  @warning If window.rootViewController is kind of UINavigationController class then banner position forced to CommonBannerPositionBottom
 *  for usability issues.
 */
+ (void)setBannerPosition:(CommonBannerPosition)bannerPosition;

@end

@interface UIViewController (BannerAdapter) <CommonBannerAdapter>

@end

@interface CommonBannerProvideriAd : NSObject <CommonBannerPovider>

@end

@interface CommonBannerProviderGAd : NSObject <CommonBannerPovider>

@end
