//  Created by Karen Lusinyan on 11/02/14.
//  Copyright (c) 2014 Karen Lusinyan. All rights reserved.

#import "CommonBanner.h"
#import "CommonTask.h"
#import <objc/runtime.h>

NSString * const CommonBannerDidCompleteSetup = @"CommonBannerDidCompleteSetup";

@interface CommonBanner () <ADBannerViewDelegate>

@property (nonatomic, strong) UIViewController *contentController;
@property (nonatomic, strong) ADBannerView *bannerView;

@property (nonatomic, getter=isDisplayed) BOOL displayed;
@property (nonatomic, getter=isStopped) BOOL stopped;
@property (nonatomic, getter=isForcedHidden) BOOL forceHide;

@property (nonatomic) id <CommonBannerAdapter> adapter;
@property (nonatomic) CommonBannerPosition bannerPosition;

@end

#pragma mark -

@implementation CommonBanner

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (CommonBanner *)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

+ (void)startManaging
{
    @synchronized(self) {
        static dispatch_once_t pred = 0;
        dispatch_once(&pred, ^{
            [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification
                                                              object:nil
                                                               queue:[NSOperationQueue mainQueue]
                                                          usingBlock:^(NSNotification *note) {
                                                              [[self sharedInstance] setup];
                                                              [[self sharedInstance] start];
                                                          }];
            [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification
                                                              object:nil
                                                               queue:[NSOperationQueue mainQueue]
                                                          usingBlock:^(NSNotification *note) {
                                                              [CommonTask performBackgroundTask:^{
                                                                  [[self sharedInstance] displayBanner:NO completion:nil];
                                                              }];
                                                          }];
            
            [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification
                                                              object:nil
                                                               queue:[NSOperationQueue mainQueue]
                                                          usingBlock:^(NSNotification *note) {
                                                              [CommonTask performBackgroundTask:^{
                                                                  [[self sharedInstance] displayBanner:YES completion:nil];
                                                              }];
                                                          }];
        });
        if ([self sharedInstance].isStopped) {
            [[self sharedInstance] start];
        }
    }
}

+ (void)stopManaging
{
    [self sharedInstance].stopped = YES;
}

+ (void)setBannerPosition:(CommonBannerPosition)bannerPosition
{
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        [self sharedInstance].bannerPosition = bannerPosition;
    });
}

- (void)setup
{
    //****************SETUP COMMON BANNER****************//
    self.contentController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    if ([self.contentController isKindOfClass:[UINavigationController class]]) {
        self.bannerPosition = CommonBannerPositionBottom;
    }
    [self.view addSubview:self.contentController.view];
    [self addChildViewController:self.contentController];
    
    // switch root view controller
    [[UIApplication sharedApplication] keyWindow].rootViewController = self;
    //****************SETUP COMMON BANNER****************//
    
    //****************SETUP BANNER VIEW****************//
    // on iOS 6 ADBannerView introduces a new initializer, use it when available.
    if ([ADBannerView instancesRespondToSelector:@selector(initWithAdType:)]) {
        self.bannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
    }
    else {
        self.bannerView = [[ADBannerView alloc] init];
    }
    
    // add banner to view
    [self.view addSubview:self.bannerView];
    
    // setup did compete
    [[NSNotificationCenter defaultCenter] postNotificationName:CommonBannerDidCompleteSetup object:nil];
}

- (void)start
{
    self.stopped = NO;
    
    // ready to receive banners
    self.bannerView.delegate = self;
}

- (void)loadView
{
    // call in case if initialized from XIB
    [super loadView];
    
    // create view if not initialized from XIB
    if (self.view == nil) {
        self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.view.backgroundColor = [UIColor clearColor];
    }
}


#pragma getter/setter

- (void)setStopped:(BOOL)stopped
{
    @synchronized(self) {
        if (stopped) {
            if ([self.bannerView isBannerLoaded] && [self.adapter canDisplayAds]) {
                [self displayBanner:NO completion:^(BOOL finished) {
                    self.bannerView.delegate = nil;
                }];
            }
        }
        _stopped = stopped;
    }
}

- (void)viewDidLayoutSubviews
{
    CGRect contentFrame = self.view.bounds, bannerFrame = CGRectZero;
    
    // All we need to do is ask the banner for a size that fits into the layout area we are using.
    // At this point in this method contentFrame=self.view.bounds, so we'll use that size for the layout.
    bannerFrame.size = [self.bannerView sizeThatFits:contentFrame.size];
    
    DebugLog(@"adapter [%@] canDisplayAds [%@]", NSStringFromClass([self.adapter class]), [self.adapter canDisplayAds] ? @"Y" : @"N");
    
    if (self.bannerView.isBannerLoaded && [self.adapter canDisplayAds] && !self.isForcedHidden) {
        if (self.bannerPosition == CommonBannerPositionBottom) {
            contentFrame.size.height -= bannerFrame.size.height;
            bannerFrame.origin.y = contentFrame.size.height;
        }
        else if (self.bannerPosition == CommonBannerPositionTop) {
            bannerFrame.origin.y = 0;
            contentFrame.origin.y += bannerFrame.size.height;
            contentFrame.size.height -= bannerFrame.size.height;
        }
        
        self.displayed = YES;
    }
    else {
        if (self.bannerPosition == CommonBannerPositionBottom) {
            bannerFrame.origin.y = contentFrame.size.height;
        }
        else if (self.bannerPosition == CommonBannerPositionTop) {
            bannerFrame.origin.y -= bannerFrame.size.height;
            contentFrame = self.view.bounds;
        }
        
        self.displayed = NO;
    }
    
    if ([self.adapter shouldCoverContent]) {
        contentFrame = self.view.bounds;
    }
    
    self.contentController.view.frame = contentFrame;
    self.bannerView.frame = bannerFrame;
}


#pragma orientation

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [self.contentController preferredInterfaceOrientationForPresentation];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return [self.contentController supportedInterfaceOrientations];
}

- (void)displayBanner:(BOOL)display completion:(void (^)(BOOL finished))completion
{
    if ((self.isDisplayed && display) || (!self.isDisplayed && !display)) return;
    
    self.forceHide = !display;

    CGFloat animDuration = (display) ? 0.25f : 0.1;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        DebugLog(@"isBannerLoaded=[%@] display=[%@]", self.bannerView.isBannerLoaded ? @"Y" : @"N", display ? @"Y" : @"N");
        [UIView animateWithDuration:[self.adapter animated] ? animDuration : 0.0f animations:^{
            // viewDidLayoutSubviews will handle positioning the banner view so that it is visible.
            // You must not call [self.view layoutSubviews] directly.  However, you can flag the view
            // as requiring layout...
            [self.view setNeedsLayout];
            // ... then ask it to lay itself out immediately if it is flagged as requiring layout...
            [self.view layoutIfNeeded];
            // ... which has the same effect.
        } completion:^(BOOL finished) {
            if (completion) completion(finished);
        }];
        
    });
}


#pragma ADBannerViewDelegate protocol

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    [self displayBanner:YES completion:nil];
    
    if (self.adapter && [self.adapter respondsToSelector:@selector(bannerViewDidLoadAd:)]) {
        [self.adapter bannerViewDidLoadAd:banner];
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    [self displayBanner:NO completion:nil];
    
    if (self.adapter && [self.adapter respondsToSelector:@selector(bannerView:didFailToReceiveAdWithError:)]) {
        [self.adapter bannerView:banner didFailToReceiveAdWithError:error];
    }
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    if (self.adapter && [self.adapter respondsToSelector:@selector(bannerViewActionShouldBegin:willLeaveApplication:)]) {
        [self.adapter bannerViewActionShouldBegin:banner willLeaveApplication:willLeave];
    }
    
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    if (self.adapter && [self.adapter respondsToSelector:@selector(bannerViewActionDidFinish:)]) {
        [self.adapter bannerViewActionDidFinish:banner];
    }
}

@end

@implementation UIViewController (BannerAdapter)
@dynamic canDisplayAds, shouldCoverContent, animated;

- (BOOL)canDisplayAds
{
    return [objc_getAssociatedObject(self, @selector(canDisplayAds)) boolValue];
}

- (void)setCanDisplayAds:(BOOL)canDisplayAds
{
    objc_setAssociatedObject(self, @selector(canDisplayAds), @(canDisplayAds), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [[CommonBanner sharedInstance] setAdapter:self];
    
    [[CommonBanner sharedInstance] displayBanner:canDisplayAds completion:nil];
}

- (BOOL)shouldCoverContent
{
    return [objc_getAssociatedObject(self, @selector(shouldCoverContent)) boolValue];
}

- (void)setShouldCoverContent:(BOOL)shouldCoverContent
{
    objc_setAssociatedObject(self, @selector(shouldCoverContent), @(shouldCoverContent), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)animated
{
    return [objc_getAssociatedObject(self, @selector(animated)) boolValue];
}

- (void)setAnimated:(BOOL)animated
{
    objc_setAssociatedObject(self, @selector(animated), @(animated), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation UITableViewController (BannerAdapter)
@dynamic canDisplayAds, shouldCoverContent, animated;

- (BOOL)canDisplayAds
{
    return [objc_getAssociatedObject(self, @selector(canDisplayAds)) boolValue];
}

- (void)setCanDisplayAds:(BOOL)canDisplayAds
{
    objc_setAssociatedObject(self, @selector(canDisplayAds), @(canDisplayAds), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [[CommonBanner sharedInstance] setAdapter:self];
    
    [[CommonBanner sharedInstance] displayBanner:canDisplayAds completion:nil];
}

- (BOOL)shouldCoverContent
{
    return [objc_getAssociatedObject(self, @selector(shouldCoverContent)) boolValue];
}

- (void)setShouldCoverContent:(BOOL)shouldCoverContent
{
    objc_setAssociatedObject(self, @selector(shouldCoverContent), @(shouldCoverContent), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)animated
{
    return [objc_getAssociatedObject(self, @selector(animated)) boolValue];
}

- (void)setAnimated:(BOOL)animated
{
    objc_setAssociatedObject(self, @selector(animated), @(animated), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end