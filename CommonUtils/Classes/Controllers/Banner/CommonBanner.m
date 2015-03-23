//  Created by Karen Lusinyan on 11/02/14.
//  Copyright (c) 2014 Karen Lusinyan. All rights reserved.

#import "CommonBanner.h"

NSString * const BannerViewActionWillBegin = @"BannerViewActionWillBegin";
NSString * const BannerViewActionDidFinish = @"BannerViewActionDidFinish";

@interface CommonBanner () <ADBannerViewDelegate>

@property (readwrite, nonatomic, retain) ADBannerView *bannerView;
@property (readwrite, nonatomic, assign) BOOL bannerDidShown;

@end

@implementation CommonBanner

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//desired private initalizer
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.animated = YES;
        self.position = BannerPositionBottom;
    }
    return self;
}

//public initializer
+ (instancetype)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (void)addBannerWithDelegate:(id<CommonBannerDelegate>)delegate
{
    static dispatch_once_t pred = 0;
    __strong static ADBannerView *sharedBanner = nil;
    dispatch_once(&pred, ^{
        // On iOS 6 ADBannerView introduces a new initializer, use it when available.
        if ([ADBannerView instancesRespondToSelector:@selector(initWithAdType:)]) {
            sharedBanner = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
        } else {
            sharedBanner = [[ADBannerView alloc] init];
        }
        sharedBanner.delegate = self;
        sharedBanner.backgroundColor = [UIColor clearColor];
    });
    
    self.bannerView = sharedBanner;
    self.delegate = delegate;

    if ([self.delegate isKindOfClass:[UIViewController class]]) {
        UIViewController *contentController = (UIViewController *)delegate;
        [contentController.view addSubview:self.bannerView];
        
        CGRect contentFrame = contentController.view.bounds;
        CGRect bannerFrame = self.bannerView.frame;
        
        if (self.position == BannerPositionBottom) {
            bannerFrame.origin.y = CGRectGetMaxY([UIScreen mainScreen].bounds);
        }
        else if (self.position == BannerPositionTop) {
            bannerFrame.origin.y = CGRectGetMinY([UIScreen mainScreen].bounds)-50;
        }
        bannerFrame.size = [self.bannerView sizeThatFits:contentFrame.size];
        self.bannerView.frame = bannerFrame;
        
        if (self.bannerView.bannerLoaded) {
            [self showBannerAnimated:self.animated completion:^(BOOL finished) {
                //do something
            }];
        }
    }
}

- (void)removeBannerWithDelegate:(id<CommonBannerDelegate>)contentController
{
    [self hideBannerAnimated:self.animated completion:^(BOOL finished) {
        //do something
    }];
}

- (void)showBannerAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!self.bannerDidShown) {
                //resize banner
                CGRect bannerFrame = self.bannerView.frame;
                if (self.position == BannerPositionBottom) {
                    bannerFrame.origin.y -= bannerFrame.size.height;
                }
                else if (self.position == BannerPositionTop) {
                    bannerFrame.origin.y += bannerFrame.size.height;
                }
                
                //resize content
                UIView *content = nil;
                CGRect contentFrame = CGRectZero;
                if (self.dataSource && [self.dataSource respondsToSelector:@selector(content)]) {
                    content = [self.dataSource content];
                    contentFrame = content.frame;
                    contentFrame.size.height -= bannerFrame.size.height;
                }
                [UIView animateWithDuration:animated ? 0.25f : 0.0f
                                      delay:0.0
                                    options:UIViewAnimationOptionCurveLinear
                                 animations:^{
                                     self.bannerView.frame = bannerFrame;
                                     if (content) {
                                         content.frame = contentFrame;
                                     }
                                 } completion:^(BOOL finished) {
                                     if (completion) completion(finished);
                                     self.bannerDidShown = YES;
                                     DebugLog(@"banner.frame when shown = %@", NSStringFromCGRect(self.bannerView.frame));
                                     if (content) {
                                         DebugLog(@"content.ftame when shown = %@", NSStringFromCGRect(content.frame));
                                     }
                                 }];
            }
        });
    });
}

- (void)hideBannerAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.bannerDidShown) {
                //resize banner
                CGRect bannerFrame = self.bannerView.frame;
                if (self.position == BannerPositionBottom) {
                    bannerFrame.origin.y += bannerFrame.size.height;
                }
                else if (self.position == BannerPositionTop) {
                    bannerFrame.origin.y -= bannerFrame.size.height;

                }
                
                //resize content
                UIView *content = nil;
                CGRect contentFrame = CGRectZero;
                if (self.dataSource && [self.dataSource respondsToSelector:@selector(content)]) {
                    content = [self.dataSource content];
                    contentFrame = content.frame;
                    contentFrame.size.height += bannerFrame.size.height;
                }
                [UIView animateWithDuration:animated ? 0.25f : 0.0f
                                      delay:0
                                    options:UIViewAnimationOptionCurveLinear
                                 animations:^{
                                     self.bannerView.frame = bannerFrame;
                                     if (content) {
                                         content.frame = contentFrame;
                                     }
                                 } completion:^(BOOL finished) {
                                     if (completion) completion(finished);
                                     self.bannerDidShown = NO;
                                     DebugLog(@"banner.frame when hidden = %@", NSStringFromCGRect(self.bannerView.frame));
                                     if (content) {
                                         DebugLog(@"content.ftame when hidden = %@", NSStringFromCGRect(content.frame));
                                     }
                                 }];
            }
        });
    });
}

#pragma mark -
#pragma mark ADBannerViewDelegate methods

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if ([self.delegate canDisplayAds]) {
        [self showBannerAnimated:self.animated completion:^(BOOL finished) {
            //do something
        }];
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(bannerDidShow:)]) {
        [self.delegate bannerDidShow:self.bannerView];
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    if ([self.delegate canDisplayAds]) {
        [self hideBannerAnimated:self.animated completion:^(BOOL finished) {
            //do something
        }];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(bannerDidHide:)]) {
        [self.delegate bannerDidHide:self.bannerView];
    }
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    [[NSNotificationCenter defaultCenter] postNotificationName:BannerViewActionWillBegin object:self];
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    [[NSNotificationCenter defaultCenter] postNotificationName:BannerViewActionDidFinish object:self];
}

@end
