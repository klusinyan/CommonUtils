//  Created by Karen Lusinyan on 11/02/14.
//  Copyright (c) 2014 Karen Lusinyan. All rights reserved.

#import "CommonBanner.h"
#import "CommonTask.h"
#import "AFNetworkReachabilityManager.h"
#import <objc/runtime.h>

// requested params of AdMob
NSString * const keyAdUnitID = @"adUnitID";
NSString * const keyTestDevices = @"testDevices";

@import GoogleMobileAds;

NSString * const CommonBannerDidCompleteSetup = @"CommonBannerDidCompleteSetup";

NSString * const BannerProviderStatusDidChnage = @"BannerProviderStatusDidChnage";

typedef NS_ENUM(NSInteger, BannerProviderState) {
    BannerProviderStateIdle=1,
    BannerProviderStateReady,
    BannerProviderStateShown
};

@interface Provider : NSObject

@property (nonatomic) id<CommonBannerProvider> bannerProvider;
@property (nonatomic) CommonBannerPriority priority;

@property (nonatomic) BannerProviderState state;

- (id)initWithProvider:(Class)provider priority:(CommonBannerPriority)priority requestParams:(NSDictionary *)requestParams;

@end

@implementation Provider

- (id)initWithProvider:(Class)provider priority:(CommonBannerPriority)priority requestParams:(NSDictionary *)requestParams
{
    self = [super init];
    if (self) {
        // configure banner provider
        self.bannerProvider = [NSClassFromString(NSStringFromClass(provider)) sharedInstance];
        [self.bannerProvider setRequestParams:requestParams];
        
        // add options to provider
        self.priority = priority;
        self.state = BannerProviderStateIdle;
        
        // dispatch_once
        [self.bannerProvider startLoading];
    }
    return self;
}

- (void)setState:(BannerProviderState)state
{
    _state = state;

    [[NSNotificationCenter defaultCenter] postNotificationName:BannerProviderStatusDidChnage object:nil];
}

- (BOOL)isEqual:(id)object
{
    return ([self.bannerProvider class] == [((Provider *)object).bannerProvider class]);
}

- (NSString *)providerPriority
{
    switch (self.priority) {
        case CommonBannerPriorityHigh:
            return @"CommonBannerPriorityHigh";
        case CommonBannerPriorityLow:
            return @"CommonBannerPriorityLow";
        default:
            return @"Unknown";
    }
}

- (NSString *)providerState
{
    switch (self.state) {
        case BannerProviderStateIdle:
            return @"BannerProviderStateIdle";
        case BannerProviderStateReady:
            return @"BannerProviderStateReady";
        case BannerProviderStateShown:
            return @"BannerProviderStateShown";
        default:
            return @"Unknown";
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"\n\"provider\" : {\n\t\"category\" : \"%@\", \n\t\"priority\" : \"%@\", \n\t\"state\" : \"%@\"\n}\n",
            NSStringFromClass([self.bannerProvider class]), [self providerPriority], [self providerState]];
}

@end

@interface CommonBanner ()

@property (nonatomic, strong) UIViewController *contentController;

@property (nonatomic, getter=isStopped) BOOL stopped;

@property (nonatomic) CommonBannerPosition bannerPosition;
@property (nonatomic) id <CommonBannerAdapter> adapter;
@property (nonatomic, strong) id<CommonBannerProvider> bannerProvider;

// ivar "locked" needs to synchronize dispatch_queue
@property (nonatomic, getter=isLocked) BOOL locked;

// ivar that indicates if diplay banner is called
@property (nonatomic, getter=isLayoutNeeded) BOOL layoutNeeded;

@property (nonatomic, strong) NSMutableArray *providersQueue;

@end

@implementation CommonBanner

- (void)dealloc
{
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (CommonBanner *)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[self alloc] init];
        
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            if (![AFNetworkReachabilityManager sharedManager].isReachable) {
                [sharedInstance stopLoading];
            }
            else {
                [sharedInstance startLoading];
            }
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification
                                                          object:nil
                                                           queue:[NSOperationQueue currentQueue]
                                                      usingBlock:^(NSNotification *note) {
                                                          [self waitAndReload];
                                                      }];
        [[NSNotificationCenter defaultCenter] addObserverForName:BannerProviderStatusDidChnage
                                                          object:nil
                                                           queue:[NSOperationQueue currentQueue]
                                                      usingBlock:^(NSNotification *note) {
                                                          [sharedInstance dispatchProvidersQueue];
                                                      }];
   });
    
    return sharedInstance;
}

+ (void)regitserProvider:(Class)aClass withPriority:(CommonBannerPriority)priority requestParams:(NSDictionary *)requestParams
{
    [[self sharedInstance] setProvider:aClass withPriority:priority requestParams:requestParams];
}

+ (void)updatePriorityIfNeeded:(CommonBannerPriority)priority forClass:(Class)aClass
{
    [[self sharedInstance] updatePriorityIfNeeded:priority forClass:aClass];
}

+ (CommonBannerPriority)priorityForClass:(Class)aClass
{
    return [[self sharedInstance] priorityForClass:aClass];
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
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        [[self sharedInstance] stopLoading];
    });
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

- (void)stopLoading
{
    [self syncTask:^{
        if (!self.isStopped) {
            self.stopped = YES;
            [self.providersQueue enumerateObjectsUsingBlock:^(Provider *provider, NSUInteger idx, BOOL *stop) {
                provider.state = BannerProviderStateIdle;
            }];
            DebugLog(@"/////%@/////", NSStringFromSelector(_cmd));
        }
    } withLockStatusChangeBlock:^(BOOL locked) {
        if (!locked) {
            [self dispatchProvidersQueue];
        }
    }];
}

- (void)startLoading
{
    [self syncTask:^{
        if (self.isStopped) {
            [self.providersQueue enumerateObjectsUsingBlock:^(Provider *provider, NSUInteger idx, BOOL *stop) {
                provider.state = ([provider.bannerProvider isBannerLoaded]) ? BannerProviderStateReady : BannerProviderStateIdle;
            }];
            self.stopped = NO;
            DebugLog(@"/////%@/////", NSStringFromSelector(_cmd));
        }
    } withLockStatusChangeBlock:^(BOOL locked) {
        if (!locked) {
            [self dispatchProvidersQueue];
        }
    }];
}

- (Provider *)provider:(Class)provider
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bannerProvider.class = %@", provider];
    return [[self.providersQueue filteredArrayUsingPredicate:predicate] firstObject];
}

- (void)setProvider:(Class)aClass withPriority:(CommonBannerPriority)priority requestParams:(NSDictionary *)requestParams
{
    Provider *provider = [[Provider alloc] initWithProvider:aClass priority:priority requestParams:requestParams];
    if (self.providersQueue == nil) {
        self.providersQueue = [NSMutableArray array];
    }
    [[self providersQueue] addObject:provider];
}

- (void)updatePriorityIfNeeded:(CommonBannerPriority)priority forClass:(Class)aClass
{
    [self.providersQueue enumerateObjectsUsingBlock:^(Provider *provider, NSUInteger idx, BOOL *stop) {
        if ([provider.bannerProvider isMemberOfClass:aClass]) {
            if (provider.priority != priority) {
                provider.priority = priority;
                
                // try to update immediately
                [self dispatchProvidersQueue];
            }
            *stop = YES;
        }
    }];
}

- (CommonBannerPriority)priorityForClass:(Class)aClass
{
    return [[[self provider:aClass] valueForKey:@"priority"] integerValue];
}

- (void)setStopped:(BOOL)stopped
{
    @synchronized(self) {
        [self displayBanner:!stopped animated:!stopped completion:nil];
        [self.bannerProvider bannerView].hidden = stopped;
        _stopped = stopped;
    }
}

- (Provider *)currentProvider
{
    return [self provider:[self.bannerProvider class]];
}

- (void)syncTask:(void(^)(void))task
{
    [self syncTask:task withLockStatusChangeBlock:nil];
}

- (void)syncTask:(void(^)(void))task withLockStatusChangeBlock:(void(^)(BOOL locked))lockStatus
{
    @synchronized(self) {
        self.locked = YES;
        if (lockStatus) lockStatus(self.locked);
        DebugLog(@"locking...");
        if (task) task();
        DebugLog(@"unlocking...");
        self.locked = NO;
        if (lockStatus) lockStatus(self.locked);
    }
}

- (void)dispatchProvidersQueue
{
    @synchronized(self) {
        if (self.isLocked) {
            DebugLog(@"waiting for lock...");
            return;
        }
        
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:NO];
        NSArray *providers = [self.providersQueue sortedArrayUsingDescriptors:@[sort]];
        for (int i = 0; i < [providers count]; i++) {
            Provider *provider = [self.providersQueue objectAtIndex:i];
            //*******************DEBUG*******************//
            DebugLog(@"provider = %@", provider);
            DebugLog(@"currentProvider = %@", [self currentProvider]);
            //*******************DEBUG*******************//
            if (self.adapter != nil) {
                if (![self.adapter canDisplayAds]) {
                    [self syncTask:^{
                        self.stopped = YES;
                        if ([self currentProvider].state == BannerProviderStateShown) {
                            [self currentProvider].state = BannerProviderStateReady;
                        }
                        self.bannerProvider = nil;
                        return;
                    }];
                }
                else {
                    // if current banner provider shown with priority=1 then skip
                    if ([self currentProvider].state != BannerProviderStateShown || [self currentProvider].priority != CommonBannerPriorityHigh) {
                        // if current banner provider changes state to idle then hide
                        if ([self currentProvider].state == BannerProviderStateIdle) {
                            [self syncTask:^{
                                self.stopped = YES;
                                self.bannerProvider = nil;
                                return;
                            }];
                        }
                        // if provider changes its state to ready
                        else if ((provider.state == BannerProviderStateReady) && !([provider isEqual:[self currentProvider]])) {
                            [self syncTask:^{
                                DebugLog(@"preparing to show...%@", [[provider bannerProvider] class]);
                                // stop immediately
                                self.stopped = YES;
                                // set old provider to [state=ready]
                                if ([self currentProvider].state == BannerProviderStateShown) {
                                    [self currentProvider].state = BannerProviderStateReady;
                                }
                                // get new provider
                                self.bannerProvider = [provider bannerProvider];
                                // set new provider to [state=shown]
                                [self currentProvider].state = BannerProviderStateShown;
                                // takes a time to prepare banner view
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.25f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    [self.view addSubview:[self.bannerProvider bannerView]];
                                    // takes a time to reload
                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.25f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                        self.stopped = NO;
                                        DebugLog(@"%@", [self currentProvider]);
                                    });
                                });
                            }];
                        }
                    }
                }
            }
        }
    }
}

// call "before" to set layout needed ivar
- (void)setNeedsLayout
{
    self.layoutNeeded = YES;
}

// call "after" to layout if requested before by calling [self setNeedsLayout]
- (void)layoutIfNeeded:(void(^)(void))completion
{
    if (!self.isLayoutNeeded) return;

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
    }
    else {
        if (self.bannerPosition == CommonBannerPositionBottom) {
            bannerFrame.origin.y = contentFrame.size.height;
        }
        else if (self.bannerPosition == CommonBannerPositionTop) {
            bannerFrame.origin.y -= bannerFrame.size.height;
            contentFrame = self.view.bounds;
        }
    }
    
    if ([self.adapter shouldCoverContent]) {
        contentFrame = self.view.bounds;
    }
    
    self.contentController.view.frame = contentFrame;
    [self.bannerProvider bannerView].frame = bannerFrame;
    
    if (completion) completion();
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self layoutIfNeeded:^{
        self.layoutNeeded = NO;
    }];
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
            
            [self setNeedsLayout];
            
            //****************************DEBUG****************************//
            DebugLog(@"isBannerLoaded=[%@] display=[%@] animated=[%@]",
                     self.bannerProvider.isBannerLoaded ? @"Y" : @"N",
                     display ? @"Y" : @"N",
                     ([self.adapter animated] && animated) ? @"Y" : @"N");
            //****************************DEBUG****************************//
            if ([self.adapter animated] && animated) {
                [UIView animateWithDuration:.25f animations:^{
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
            }
            else {
                [self layoutIfNeeded:^{
                    self.layoutNeeded = NO;
                    if (completion) completion(YES);
                }];
            }
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
    
    [[CommonBanner sharedInstance] dispatchProvidersQueue];
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
@property (readwrite, nonatomic, getter=isBannerLoaded) BOOL bannerLoaded;

@end

@implementation CommonBannerProvideriAd
@synthesize requestParams;

+ (instancetype)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)startLoading
{
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        // on iOS 6 ADBannerView introduces a new initializer, use it when available.
        if ([ADBannerView instancesRespondToSelector:@selector(initWithAdType:)]) {
            self.bannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
        }
        else {
            self.bannerView = [[ADBannerView alloc] init];
        }
        self.bannerView.delegate = self;
    });
}

- (BOOL)isBannerLoaded
{
    if (_bannerLoaded) {
        Provider *provider = [[CommonBanner sharedInstance] provider:[self class]];
        if (provider.state == BannerProviderStateIdle) provider.state = BannerProviderStateReady;
    }
    return _bannerLoaded;
}


#pragma ADBannerViewDelegate protocol

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    self.bannerLoaded = YES;
    
    Provider *provider = [[CommonBanner sharedInstance] provider:[self class]];
    if (provider.state == BannerProviderStateIdle) provider.state = BannerProviderStateReady;
    
    id<CommonBannerAdapter> adapter = [CommonBanner sharedInstance].adapter;
    if (adapter && [adapter respondsToSelector:@selector(bannerViewDidLoad)]) {
        [adapter bannerViewDidLoad];
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    self.bannerLoaded = NO;
    
    Provider *provider = [[CommonBanner sharedInstance] provider:[self class]];
    if (provider.state != BannerProviderStateIdle) provider.state = BannerProviderStateIdle;
   
    id<CommonBannerAdapter> adapter = [CommonBanner sharedInstance].adapter;
    if (adapter && [adapter respondsToSelector:@selector(bannerViewDidFailToReceiveWithError:)]) {
        [adapter bannerViewDidFailToReceiveWithError:error];
    }
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
@property (readwrite, nonatomic, getter=isBannerLoaded) BOOL bannerLoaded;

@end

@implementation CommonBannerProviderGAd
@synthesize requestParams;

+ (instancetype)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)startLoading
{
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        self.bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
        self.bannerView.adUnitID = [self.requestParams objectForKey:keyAdUnitID];
        self.bannerView.rootViewController = [CommonBanner sharedInstance];
        self.bannerView.delegate = self;
        
        GADRequest *request = [GADRequest request];
        // Requests test ads on devices you specify. Your test device ID is printed to the console when
        // an ad request is made. GADBannerView automatically returns test ads when running on a
        // simulator.
        if (DEBUG) {
            request.testDevices = [self.requestParams objectForKey:keyTestDevices];
        }
        [self.bannerView loadRequest:request];
    });
}

- (BOOL)isBannerLoaded
{
    if (_bannerLoaded) {
        Provider *provider = [[CommonBanner sharedInstance] provider:[self class]];
        if (provider.state == BannerProviderStateIdle) provider.state = BannerProviderStateReady;
    }
    return _bannerLoaded;
}


#pragma GADBannerViewDelegate

- (void)adViewDidReceiveAd:(GADBannerView *)view
{
    self.bannerLoaded = YES;
    
    Provider *provider = [[CommonBanner sharedInstance] provider:[self class]];
    if (provider.state == BannerProviderStateIdle) provider.state = BannerProviderStateReady;
    
    id<CommonBannerAdapter> adapter = [CommonBanner sharedInstance].adapter;
    if (adapter && [adapter respondsToSelector:@selector(bannerViewDidLoad)]) {
        [adapter bannerViewDidLoad];
    }
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error
{
    self.bannerLoaded = NO;
    
    Provider *provider = [[CommonBanner sharedInstance] provider:[self class]];
    if (provider.state != BannerProviderStateIdle) provider.state = BannerProviderStateIdle;
    
    id<CommonBannerAdapter> adapter = [CommonBanner sharedInstance].adapter;
    if (adapter && [adapter respondsToSelector:@selector(bannerViewDidFailToReceiveWithError:)]) {
        [adapter bannerViewDidFailToReceiveWithError:error];
    }
}

- (void)adViewWillLeaveApplication:(GADBannerView *)adView
{
    id<CommonBannerAdapter> adapter = [CommonBanner sharedInstance].adapter;
    if (adapter && [adapter respondsToSelector:@selector(bannerViewActionShouldBegin)]) {
        [adapter bannerViewActionShouldBegin];
    }
}

- (void)adViewDidDismissScreen:(GADBannerView *)adView
{
    id<CommonBannerAdapter> adapter = [CommonBanner sharedInstance].adapter;
    if (adapter && [adapter respondsToSelector:@selector(bannerViewActionDidFinish)]) {
        [adapter bannerViewActionDidFinish];
    }
}

@end
