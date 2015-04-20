//  Created by Karen Lusinyan on 11/02/14.
//  Copyright (c) 2014 Karen Lusinyan. All rights reserved.

#import "CommonBanner.h"
#import "CommonTask.h"
#import <objc/runtime.h>

@import GoogleMobileAds;

NSString * const CommonBannerDidCompleteSetup = @"CommonBannerDidCompleteSetup";

NSString * const BannerProviderIsReadyToDisplayAd = @"BannerProviderIsReadyToDisplayAd";

@interface BannerProvider : NSObject

@property (nonatomic, getter=isReady) BOOL ready;
@property (nonatomic, getter=isShown) BOOL shown;

@property (nonatomic) CommonBannerPriority priority;
@property (nonatomic) id<CommonBannerPovider> provider;

- (instancetype)initWithProvider:(Class)provider priority:(CommonBannerPriority)priority;

@end

@implementation BannerProvider

- (id)initWithProvider:(Class)provider priority:(CommonBannerPriority)priority
{
    self = [super init];
    if (self) {
        self.provider = [NSClassFromString(NSStringFromClass(provider)) sharedInstance];
        self.priority = priority;
    }
    return self;
}

- (void)setReady:(BOOL)ready
{
    _ready = ready;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BannerProviderIsReadyToDisplayAd object:nil];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"provider.class=%@, provider.priority=%@, isReady=%@, isShown=%@", NSStringFromClass([self.provider class]), @(self.priority), (self.isReady) ? @"Y" : @"N", (self.isShown) ? @"Y" : @"N"];
}

@end

@interface CommonBanner ()

@property (nonatomic, strong) UIViewController *contentController;

@property (nonatomic, getter=isStopped) BOOL stopped;

@property (nonatomic) CommonBannerPosition bannerPosition;
@property (nonatomic) id <CommonBannerAdapter> adapter;
@property (nonatomic, strong) id<CommonBannerPovider> bannerProvider;

@property (nonatomic, strong) NSMutableArray *providersQueue;

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
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification
                                                          object:nil
                                                           queue:[NSOperationQueue currentQueue]
                                                      usingBlock:^(NSNotification *note) {
                                                          [self waitAndReload];
                                                      }];
        [[NSNotificationCenter defaultCenter] addObserverForName:BannerProviderIsReadyToDisplayAd
                                                          object:nil
                                                           queue:[NSOperationQueue currentQueue]
                                                      usingBlock:^(NSNotification *note) {
                                                          [sharedInstance manageProvidersQueue];
                                                      }];
    });
    
    return sharedInstance;
}

+ (void)regitserProvider:(Class)provider withPriority:(CommonBannerPriority)priority
{
    [[self sharedInstance] setProvider:provider withPriority:priority];
}

+ (void)startManaging
{
    @synchronized(self) {
        static dispatch_once_t pred = 0;
        dispatch_once(&pred, ^{
            [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification
                                                              object:nil
                                                               queue:[NSOperationQueue currentQueue]
                                                          usingBlock:^(NSNotification *note) {
                                                              [[self sharedInstance] setup];
                                                          }];
        });
    }
}

+ (void)stopManaging
{
    [self sharedInstance].stopped = YES;
}

+ (void)waitAndReload
{
    [self sharedInstance].stopped = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self sharedInstance].stopped = NO;
    });
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
    
    // setup did compete
    [[NSNotificationCenter defaultCenter] postNotificationName:CommonBannerDidCompleteSetup object:nil];
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

- (BannerProvider *)provider:(Class)provider
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"provider.class = %@", provider];
    return [[self.providersQueue filteredArrayUsingPredicate:predicate] firstObject];
}

- (void)setProvider:(Class)provider withPriority:(CommonBannerPriority)priority
{
    BannerProvider *bannerProvider = [[BannerProvider alloc] initWithProvider:provider priority:priority];
    if (self.providersQueue == nil) {
        self.providersQueue = [NSMutableArray array];
    }
    [[self providersQueue] addObject:bannerProvider];
}

- (void)manageProvidersQueue
{
    @synchronized(self) {
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:NO];
        NSArray *providers = [self.providersQueue sortedArrayUsingDescriptors:@[sort]];
        [providers enumerateObjectsUsingBlock:^(BannerProvider *bannerProvider, NSUInteger idx, BOOL *stop) {
            //*******************DEBUG*******************//
            DebugLog(@"bannerProvider %@", bannerProvider);
            //*******************DEBUG*******************//
            if (bannerProvider.priority == CommonBannerPriorityHigh && bannerProvider.isShown) {
                *stop = YES;
            }
            else if ([bannerProvider isReady]) {
                *stop = YES;
                // stop immediately
                self.stopped = YES;
                // hide previuous
                [self.bannerProvider bannerView].hidden = YES;
                // assign provider
                self.bannerProvider = [bannerProvider provider];
                // takes a time to prepare banner view
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.01f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.view addSubview:[self.bannerProvider bannerView]];
                    [self.bannerProvider bannerView].hidden = NO;
                    // takes a time to reload
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.25f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        self.stopped = NO;
                    });
                });
            }
        }];
    }
}

#pragma getter/setter

- (void)setStopped:(BOOL)stopped
{
    @synchronized(self) {
        [self displayBanner:!stopped animated:!stopped completion:nil];
        _stopped = stopped;
    }
}

- (void)viewWillLayoutSubviews
{
    CGRect contentFrame = self.view.bounds, bannerFrame = CGRectZero;
    
    // All we need to do is ask the banner for a size that fits into the layout area we are using.
    // At this point in this method contentFrame=self.view.bounds, so we'll use that size for the layout.
    bannerFrame.size = [[self.bannerProvider bannerView] sizeThatFits:contentFrame.size];
    
    //DebugLog(@"adapter [%@] canDisplayAds [%@]", NSStringFromClass([self.adapter class]), [self.adapter canDisplayAds] ? @"Y" : @"N");
    
    if (self.bannerProvider.isBannerLoaded && [self.adapter canDisplayAds] && !self.isStopped) {
        if (self.bannerPosition == CommonBannerPositionBottom) {
            contentFrame.size.height -= bannerFrame.size.height;
            bannerFrame.origin.y = contentFrame.size.height;
        }
        else if (self.bannerPosition == CommonBannerPositionTop) {
            bannerFrame.origin.y = 0;
            contentFrame.origin.y += bannerFrame.size.height;
            contentFrame.size.height -= bannerFrame.size.height;
        }
        
        [self provider:[self.bannerProvider class]].shown = YES;
    }
    else {
        if (self.bannerPosition == CommonBannerPositionBottom) {
            bannerFrame.origin.y = contentFrame.size.height;
        }
        else if (self.bannerPosition == CommonBannerPositionTop) {
            bannerFrame.origin.y -= bannerFrame.size.height;
            contentFrame = self.view.bounds;
        }
        
        [self provider:[self.bannerProvider class]].shown = NO;
    }
    
    if ([self.adapter shouldCoverContent]) {
        contentFrame = self.view.bounds;
    }
    
    self.contentController.view.frame = contentFrame;
    [self.bannerProvider bannerView].frame = bannerFrame;
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

- (void)displayBanner:(BOOL)display animated:(BOOL)animated completion:(void (^)(BOOL finished))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            DebugLog(@"isBannerLoaded=[%@] display=[%@] animated=[%@]", self.bannerProvider.isBannerLoaded ? @"Y" : @"N", display ? @"Y" : @"N", ([self.adapter animated] && animated) ? @"Y" : @"N");
            [UIView animateWithDuration:[self.adapter animated] && animated ? .25f : .0f animations:^{
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
    });
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
    
    [[CommonBanner sharedInstance] displayBanner:canDisplayAds animated:YES completion:nil];
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

@interface CommonBannerProvideriAd () <ADBannerViewDelegate>

@property (nonatomic, strong) ADBannerView *bannerView;

@end

@implementation CommonBannerProvideriAd

+ (instancetype)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static CommonBannerProvideriAd *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[self alloc] init];
        
        // on iOS 6 ADBannerView introduces a new initializer, use it when available.
        if ([ADBannerView instancesRespondToSelector:@selector(initWithAdType:)]) {
            sharedInstance.bannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
        }
        else {
            sharedInstance.bannerView = [[ADBannerView alloc] init];
        }
        
        // start request
        sharedInstance.bannerView.delegate = sharedInstance;
    });
    
    return sharedInstance;
}

- (BOOL)isBannerLoaded
{
    return [[CommonBanner sharedInstance] provider:[self class]].ready;
}

#pragma ADBannerViewDelegate protocol

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    [[CommonBanner sharedInstance] provider:[self class]].ready = YES;
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    [[CommonBanner sharedInstance] provider:[self class]].ready = NO;
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    id<CommonBannerAdapter> adapter = [CommonBanner sharedInstance].adapter;
    if (adapter && [adapter respondsToSelector:@selector(bannerViewActionShouldBegin)]) {
        [adapter bannerViewActionShouldBegin];
    }
    
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    id<CommonBannerAdapter> adapter = [CommonBanner sharedInstance].adapter;
    if (adapter && [adapter respondsToSelector:@selector(bannerViewActionDidFinish)]) {
        [adapter bannerViewActionDidFinish];
    }
}

@end

@interface CommonBannerProviderGAd () <GADBannerViewDelegate>

@property (nonatomic, strong) GADBannerView *bannerView;

@end

@implementation CommonBannerProviderGAd

+ (instancetype)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static CommonBannerProviderGAd *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[self alloc] init];
        
        sharedInstance.bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
        
        // Replace this ad unit ID with your own ad unit ID.
        sharedInstance.bannerView.adUnitID = @"ca-app-pub-3940256099942544/2934735716";
        sharedInstance.bannerView.rootViewController = [CommonBanner sharedInstance];
        sharedInstance.bannerView.delegate = sharedInstance;
        
        GADRequest *request = [GADRequest request];
        // Requests test ads on devices you specify. Your test device ID is printed to the console when
        // an ad request is made. GADBannerView automatically returns test ads when running on a
        // simulator.
        request.testDevices = @[@"2077ef9a63d2b398840261c8221a0c9a"];
        
        // start request
        [sharedInstance.bannerView loadRequest:request];
    });
    
    return sharedInstance;
}

- (BOOL)isBannerLoaded
{
    return [[CommonBanner sharedInstance] provider:[self class]].ready;
}

#pragma GADBannerViewDelegate

- (void)adViewDidReceiveAd:(GADBannerView *)view
{
    [[CommonBanner sharedInstance] provider:[self class]].ready = YES;
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error
{
    [[CommonBanner sharedInstance] provider:[self class]].ready = NO;
}

- (void)adViewWillLeaveApplication:(GADBannerView *)adView
{
    id<CommonBannerAdapter> adapter = [CommonBanner sharedInstance].adapter;
    if (adapter && [adapter respondsToSelector:@selector(bannerViewActionShouldBegin)]) {
        [adapter bannerViewActionShouldBegin];
    }
}

- (void)adViewWillDismissScreen:(GADBannerView *)adView
{
    id<CommonBannerAdapter> adapter = [CommonBanner sharedInstance].adapter;
    if (adapter && [adapter respondsToSelector:@selector(bannerViewActionDidFinish)]) {
        [adapter bannerViewActionDidFinish];
    }
}

@end
