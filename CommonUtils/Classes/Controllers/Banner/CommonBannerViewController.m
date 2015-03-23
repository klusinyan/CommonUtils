//  Created by Karen Lusinyan on 15/06/14.
//  Copyright (c) 2014 Karen Lusinyan. All rights reserved.

#import "CommonBannerViewController.h"

@interface CommonBannerViewController ()

@property (readwrite, nonatomic, assign) ADBannerView *bannerView;

@end

@implementation CommonBannerViewController

- (void)dealloc
{
    self.canDisplayAds = NO;
}

#pragma mark -
#pragma mark getter/setter

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)setCanDisplayAds:(BOOL)canDisplayAds
{
    if (canDisplayAds) {
        [[CommonBanner sharedInstance] addBannerWithDelegate:self];
    }
    else {
        [[CommonBanner sharedInstance] removeBannerWithDelegate:self];
    }
    _canDisplayAds = canDisplayAds;
}

#pragma mark -
#pragma mark BannerManagerDelegate protocol

- (void)bannerDidShow:(ADBannerView *)bannerView
{
    //do something
    /*
    [UIView animateWithDuration:0.25 animations:^{
        // -viewDidLayoutSubviews will handle positioning the banner such that it is either visible
        // or hidden depending upon whether its bannerLoaded property is YES or NO (It will be
        // YES if -bannerViewDidLoadAd: was last called).  We just need our view
        // to (re)lay itself out so -viewDidLayoutSubviews will be called.
        // You must not call [self.view layoutSubviews] directly.  However, you can flag the view
        // as requiring layout...
        [self.view setNeedsLayout];
        // ...then ask it to lay itself out immediately if it is flagged as requiring layout...
        [self.view layoutIfNeeded];
        // ...which has the same effect.
    }];
    //*/
}

- (void)bannerDidHide:(ADBannerView *)bannerView
{
    //do something
    /*
    [UIView animateWithDuration:0.25 animations:^{
        // -viewDidLayoutSubviews will handle positioning the banner such that it is either visible
        // or hidden depending upon whether its bannerLoaded property is YES or NO (It will be
        // YES if -bannerViewDidLoadAd: was last called).  We just need our view
        // to (re)lay itself out so -viewDidLayoutSubviews will be called.
        // You must not call [self.view layoutSubviews] directly.  However, you can flag the view
        // as requiring layout...
        [self.view setNeedsLayout];
        // ...then ask it to lay itself out immediately if it is flagged as requiring layout...
        [self.view layoutIfNeeded];
        // ...which has the same effect.
    }];
    //*/
}

@end
