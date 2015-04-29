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

typedef void(^Task)(void);

typedef NS_ENUM(NSInteger, LockState) {
    LockStateReleased,
    LockStateAcquired,
    LockStateBusy
};

@interface CommonBanner ()

@property (nonatomic, strong) UIViewController *contentController;

@property (nonatomic) CommonBannerPosition bannerPosition;
@property (nonatomic) id <CommonBannerAdapter> adapter;
@property (nonatomic, strong) id<CommonBannerProvider> currentBannerProvider;
@property (nonatomic, strong) UIView *bannerContainer;

// ivar "locked" needs to synchronize dispatch_queue
@property (nonatomic, getter=isLocked) BOOL locked;

@property (nonatomic, strong) NSMutableArray *providersQueue;

@property (nonatomic, copy) Task task;

@property (nonatomic, getter=isDebugMode) BOOL debugMode;

@end

@implementation CommonBanner

//**********************************************************//
//************************DEBUG MODE************************//
//**********************************************************//
// static method to LOG provider state and selector
static void inline LOG(Provider *provider, SEL selector) {
    if ([CommonBanner isDebugMode]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@\n%@",
                                                                 NSStringFromClass([provider.bannerProvider class]),
                                                                 NSStringFromSelector(selector)]
                                                        message:[NSString stringWithFormat:@"state=%@", [provider providerState]]
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

+ (void)setDebugMode:(BOOL)debugMode
{
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        [[self sharedInstance] setDebugMode:debugMode];
    });
}

+ (BOOL)isDebugMode
{
    return [[self sharedInstance] isDebugMode];
}
//**********************************************************//
//************************DEBUG MODE************************//
//**********************************************************//

- (void)dealloc
{
    /* not used
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
    //*/
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init
{
    self = [super init];
    if (self) {
        // custom init
    }
    return self;
}

+ (CommonBanner *)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[self alloc] init];

        /* // not used
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            if (![AFNetworkReachabilityManager sharedManager].isReachable) {
                [sharedInstance stopLoading:YES];
            }
            else {
                [sharedInstance startLoading:YES];
            }
        }];
         //*/

        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification
                                                          object:nil
                                                           queue:[NSOperationQueue currentQueue]
                                                      usingBlock:^(NSNotification *note) {
                                                          [sharedInstance dispatchProvidersQueue];
                                                      }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:BannerProviderStatusDidChnage
                                                          object:nil
                                                           queue:[NSOperationQueue currentQueue]
                                                      usingBlock:^(NSNotification *note) {
                                                          [sharedInstance dispatchProvidersQueue];
                                                      }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidChangeStatusBarOrientationNotification
                                                          object:nil
                                                           queue:[NSOperationQueue currentQueue]
                                                      usingBlock:^(NSNotification *note) {
                                                          if ([[sharedInstance bannerProvider] respondsToSelector:@selector(layoutBannerIfNeeded)]) {
                                                              [[sharedInstance bannerProvider] layoutBannerIfNeeded];
                                                          }
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
                                                              [[self sharedInstance] applicationDidFinishLaunching:note];
                                                          }];
            [[self sharedInstance] startLoading:YES];
        });
    }
}

+ (void)stopManaging
{
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        [[self sharedInstance] stopLoading:YES];
    });
}


/* // not used
+ (void)waitAndReload
{
    [[self sharedInstance] stopLoading:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[self sharedInstance] startLoading:YES];
    });
}
 //*/

+ (void)setBannerPosition:(CommonBannerPosition)bannerPosition
{
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        [self sharedInstance].bannerPosition = bannerPosition;
    });
}

// dispatch_once
- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    if (self.contentController == nil) {
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

- (UIView *)bannerContainer
{
    if (_bannerContainer == nil) {
        _bannerContainer = [[UIView alloc] init];
        [self.view addSubview:_bannerContainer];
    }
    return _bannerContainer;
}

- (UIViewController *)contentController
{
    if (_contentController == nil) {
        if ([[self childViewControllers] count] > 0) {
            _contentController = [self childViewControllers][0];
        }
    }
    return _contentController;
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

- (Provider *)currentProvider
{
    return [self provider:[self.currentBannerProvider class]];
}

- (void)syncTask:(void(^)(void))task
{
    @synchronized(self) {
        self.locked = YES;
        DebugLog(@"locking...");
        if (task) task();
        DebugLog(@"unlocking...");
        self.locked = NO;
    }
}

- (void)syncTaskWithCallback:(void(^)(void))task withLockStatusChangeBlock:(void(^)(LockState lockState))lockStatus
{
    @synchronized(self) {
        if (self.isLocked) {
            self.task = task;
            DebugLog(@"busy...");
            if (lockStatus) lockStatus(LockStateBusy);
            return;
        }
        self.locked = YES;
        DebugLog(@"locking...");
        if (lockStatus) lockStatus(LockStateAcquired);
        if (task) task();
        DebugLog(@"unlocking...");
        self.locked = NO;
        if (lockStatus) lockStatus(LockStateReleased);
        
        if (self.task) {
            self.task();
            self.task = nil;
        }
    }
}

/*!
 *  @brief  Call this method so stop loading banners
 *
 *  @param forced  stops provider completely by cancalling "delegate", means no any banner notification will posted
 */
- (void)stopLoading:(BOOL)forced
{
    [self syncTaskWithCallback:^{
        [self.providersQueue enumerateObjectsUsingBlock:^(Provider *provider, NSUInteger idx, BOOL *stop) {
            if (forced) {
                [provider.bannerProvider stopLoading];
            }
        }];
    } withLockStatusChangeBlock:^(LockState lockState) {
        if (lockState == LockStateReleased) {
            [self dispatchProvidersQueue];
        }
    }];
}

/*!
 *  @brief  Call this method so start loading banners
 *
 *  @param forced  starts providers by re-setting "delegate" means they will be ready to post notifications
 */
- (void)startLoading:(BOOL)forced
{
    [self syncTaskWithCallback:^{
        [self.providersQueue enumerateObjectsUsingBlock:^(Provider *provider, NSUInteger idx, BOOL *stop) {
            if (forced) {
                [provider.bannerProvider startLoading];
            }
        }];
    } withLockStatusChangeBlock:^(LockState lockState) {
        if (lockState == LockStateReleased) {
            [self dispatchProvidersQueue];
        }
    }];
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
            Provider *provider = [providers objectAtIndex:i];
            //*******************DEBUG*******************//
            DebugLog(@"provider = %@", provider);
            DebugLog(@"currentProvider = %@", [self currentProvider]);
            //*******************DEBUG*******************//
            if (self.adapter != nil) {
                if (![self.adapter canDisplayAds]) {
                    if (self.currentBannerProvider != nil) {
                        [self syncTask:^{
                            [self currentProvider].state = BannerProviderStateIdle;
                            [self displayBanner:NO animated:NO completion:^(BOOL finished) {
                                self.currentBannerProvider = nil;
                            }];
                        }];
                    }
                }
                else {
                    // if current banner provider shown with priority=1 then skip
                    if ([self currentProvider].state != BannerProviderStateShown || [self currentProvider].priority != CommonBannerPriorityHigh) {
                        // if current banner provider changes state to idle then hide
                        if (self.currentBannerProvider != nil && [self currentProvider].state == BannerProviderStateIdle) {
                            [self syncTask:^{
                                [self displayBanner:NO animated:NO completion:^(BOOL finished) {
                                    self.currentBannerProvider = nil;
                                }];
                            }];
                        }
                        else if ([provider.bannerProvider isBannerLoaded] && !([provider isEqual:[self currentProvider]])) {
                            DebugLog(@"preparing to show...%@", [[provider bannerProvider] class]);
                            [self syncTask:^{
                                [self displayBanner:NO animated:NO completion:^(BOOL finished) {
                                    // remove current banner from bannerContainer
                                    [[self.currentBannerProvider bannerView] removeFromSuperview];
                                    // set old provider to [state=ready]
                                    [self currentProvider].state = BannerProviderStateIdle;
                                    // get new provider
                                    self.currentBannerProvider = [provider bannerProvider];
                                    // set new provider to [state=shown]
                                    [self currentProvider].state = BannerProviderStateShown;
                                    // add current banner to bannerContainer
                                    [self.bannerContainer addSubview:[self.currentBannerProvider bannerView]];
                                    // animated
                                    [self displayBanner:YES animated:YES completion:^(BOOL finished) {
                                        DebugLog(@"currentProvider %@", [self currentProvider]);
                                        LOG([self currentProvider], _cmd);
                                    }];
                                }];
                            }];
                            break;
                        }
                    }
                }
            }
        }
    }
}

- (void)displayBanner:(BOOL)display animated:(BOOL)animated completion:(void (^)(BOOL finished))completion
{
    //****************************DEBUG****************************//
    DebugLog(@"isBannerLoaded=[%@] display=[%@] animated=[%@]",
             [self.currentBannerProvider isBannerLoaded] ? @"Y" : @"N",
             display ? @"Y" : @"N",
             ([self.adapter adsShouldDisplayAnimated] && animated) ? @"Y" : @"N");
    //****************************DEBUG****************************//
    if ([self.adapter adsShouldDisplayAnimated] && animated) {
        [UIView animateWithDuration:0.25 animations:^{
            // viewDidLayoutSubviews will handle positioning the banner view so that it is visible.
            // You must not call [self.view layoutSubviews] directly.  However, you can flag the view
            // as requiring layout...
            [self.view setNeedsLayout];
            // ... then ask it to lay itself out immediately if it is flagged as requiring layout...
            [self.view layoutIfNeeded];
            // ... which has the same effect.
        } completion:^(BOOL finished) {
            if (completion) completion(YES);
        }];
    }
    else {
        [self layoutBannerContainer];
        if (completion) completion(YES);
    }
}

- (void)layoutBannerContainer
{
    CGRect contentFrame = self.view.bounds, bannerFrame = CGRectZero;
    
    // All we need to do is ask the banner for a size that fits into the layout area we are using.
    // At this point in this method contentFrame=self.view.bounds, so we'll use that size for the layout.
    bannerFrame.size = [[self.currentBannerProvider bannerView] sizeThatFits:contentFrame.size];
    
    if ([self.currentBannerProvider isBannerLoaded] && [self.adapter canDisplayAds]) {
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
    
    if ([self.adapter adsShouldCoverContent]) {
        contentFrame = self.view.bounds;
    }
    
    self.contentController.view.frame = contentFrame;
    self.bannerContainer.frame = bannerFrame;
}

- (void)viewDidLayoutSubviews
{
    [self layoutBannerContainer];
}

@end

@implementation UIViewController (BannerAdapter)
@dynamic canDisplayAds, adsShouldCoverContent, adsShouldDisplayAnimated;

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

- (BOOL)adsShouldCoverContent
{
    return [objc_getAssociatedObject(self, @selector(adsShouldCoverContent)) boolValue];
}

- (void)setAdsShouldCoverContent:(BOOL)adsShouldCoverContent
{
    objc_setAssociatedObject(self, @selector(adsShouldCoverContent), @(adsShouldCoverContent), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)adsShouldDisplayAnimated
{
    return [objc_getAssociatedObject(self, @selector(adsShouldDisplayAnimated)) boolValue];
}

- (void)setAdsShouldDisplayAnimated:(BOOL)adsShouldDisplayAnimated
{
    objc_setAssociatedObject(self, @selector(adsShouldDisplayAnimated), @(adsShouldDisplayAnimated), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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

- (void)stopLoading
{
    self.bannerView.delegate = nil;
    
    // set to idle state
    Provider *provider = [[CommonBanner sharedInstance] provider:[self class]];
    provider.state = BannerProviderStateIdle;
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
        
        // layout banner if orientation did change
        [self layoutBannerIfNeeded];
    });

    // start receiving callbacks
    self.bannerView.delegate = self;
}

- (void)layoutBannerIfNeeded
{
    CGRect frame = self.bannerView.frame;
    frame.size = [self.bannerView sizeThatFits:[UIScreen mainScreen].bounds.size];
    self.bannerView.frame = frame;
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
    
    LOG(provider, _cmd);
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
    
    LOG(provider, _cmd);
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

@property (nonatomic, strong) GADRequest *request;
@property (nonatomic, strong) GADBannerView *bannerView;
@property (readwrite, nonatomic, getter=isBannerLoaded) BOOL bannerLoaded;

@end

@implementation CommonBannerProviderGAd
@synthesize requestParams;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)stopLoading
{
    self.bannerView.delegate = nil;
    
    // set to idle state
    Provider *provider = [[CommonBanner sharedInstance] provider:[self class]];
    provider.state = BannerProviderStateIdle;
}

- (void)startLoading
{
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        self.bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
        self.bannerView.adUnitID = [self.requestParams objectForKey:keyAdUnitID];
        self.bannerView.rootViewController = [CommonBanner sharedInstance];
        self.bannerView.autoloadEnabled = YES;
        
        self.request = [GADRequest request];
        // Requests test ads on devices you specify. Your test device ID is printed to the console when
        // an ad request is made. GADBannerView automatically returns test ads when running on a
        // simulator.
        self.request.testDevices = [self.requestParams objectForKey:keyTestDevices];
        
        // layout banner if orientation did change
        [self layoutBannerIfNeeded];
    });

    // start receiving callbacks
    self.bannerView.delegate = self;
}

- (void)layoutBannerIfNeeded
{
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        self.bannerView.adSize = kGADAdSizeSmartBannerPortrait;
    }
    else {
        self.bannerView.adSize = kGADAdSizeSmartBannerLandscape;
    }
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
    
    LOG(provider, _cmd);
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
    
    LOG(provider, _cmd);
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

@interface CommonBannerProviderCustom () <GADBannerViewDelegate>

@property (nonatomic, strong) UIView *bannerView;
@property (readwrite, nonatomic, getter=isBannerLoaded) BOOL bannerLoaded;

@end

@implementation CommonBannerProviderCustom
@synthesize requestParams;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)stopLoading
{
    self.bannerLoaded = NO;
    
    // set to idle state
    Provider *provider = [[CommonBanner sharedInstance] provider:[self class]];
    provider.state = BannerProviderStateIdle;
}

- (void)startLoading
{
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        self.bannerView = [[UIView alloc] initWithFrame:(CGRect){0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 50.0f}];
        self.bannerView.backgroundColor = [UIColor greenColor];
        
        // layout banner if orientation did change
        [self layoutBannerIfNeeded];
    });
    
    // start receiving callbacks
    self.bannerLoaded = YES;
}

- (void)layoutBannerIfNeeded
{
    CGRect frame = self.bannerView.frame;
    frame.size.width = [[UIScreen mainScreen] bounds].size.width;
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        frame.size.height = 50;
        self.bannerView.backgroundColor = [UIColor greenColor];
    }
    else {
        frame.size.height = 20;
        self.bannerView.backgroundColor = [UIColor orangeColor];
    }
    self.bannerView.frame = frame;
}

@end
