//  Created by Karen Lusinyan on 11/02/14.
//  Copyright (c) 2014 Karen Lusinyan. All rights reserved.

#import <iAd/iAd.h>

@protocol CommonBannerDelegate <NSObject>

@property (readwrite, nonatomic, assign) BOOL canDisplayAds;

@optional
- (void)bannerDidShow:(ADBannerView *)bannerView;
- (void)bannerDidHide:(ADBannerView *)bannerView;

@end

@protocol CommonBannerDataSource <NSObject>

@optional
- (id)content;

@end

UIKIT_EXTERN NSString * const BannerViewActionWillBegin;
UIKIT_EXTERN NSString * const BannerViewActionDidFinish;

typedef NS_ENUM(NSInteger, BannerPosition) {
    BannerPositionBottom=0,
    BannerPositionTop
};

@interface CommonBanner : NSObject

@property (readwrite, nonatomic, assign) id<CommonBannerDelegate> delegate;

@property (readwrite, nonatomic, assign) id<CommonBannerDataSource> dataSource;

@property (readwrite, nonatomic, getter=isAnimated) BOOL animated;      //default YES

@property (readwrite, nonatomic, assign) BannerPosition position;       //defualt BannerPositionBottom

+ (instancetype)sharedInstance;

- (void)addBannerWithDelegate:(id<CommonBannerDelegate>)delegate;

- (void)removeBannerWithDelegate:(id<CommonBannerDelegate>)delegate;

@end
