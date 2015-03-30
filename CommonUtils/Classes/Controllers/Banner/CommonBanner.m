//  Created by Karen Lusinyan on 11/02/14.
//  Copyright (c) 2014 Karen Lusinyan. All rights reserved.

#import "CommonBanner.h"
#import <objc/runtime.h>

NSString * const BannerViewActionWillBegin = @"BannerViewActionWillBegin";
NSString * const BannerViewActionDidFinish = @"BannerViewActionDidFinish";

@interface CommonBanner () <ADBannerViewDelegate>

@property (nonatomic, strong) ADBannerView *bannerView;
@property (nonatomic, strong) UIViewController *contentController;

@property (readwrite, nonatomic, assign) id <CommonBannerPrototype> prototype;

@end

#pragma mark -

@implementation CommonBanner

- (id)init
{
    self = [super init];
    if (self) {
        //do something
    }
    return self;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[self alloc] init];
        [sharedInstance setupBanner];
    });
    
    return sharedInstance;
}

- (void)setupBannerLayout
{
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        [self setupBanner];
        [self setupBannerController];
    });
}

- (void)setupBanner
{
    // On iOS 6 ADBannerView introduces a new initializer, use it when available.
    if ([ADBannerView instancesRespondToSelector:@selector(initWithAdType:)]) {
        self.bannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
    } else {
        self.bannerView = [[ADBannerView alloc] init];
    }
    self.bannerView.delegate = self;
    
    [self.view addSubview:self.bannerView];
}

- (void)setupBannerController
{
    UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    rootViewController.view.frame = self.view.frame;
    [self.view addSubview:rootViewController.view];
    [self addChildViewController:rootViewController];
    
    [[UIApplication sharedApplication] keyWindow].rootViewController = self;
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupBannerLayout];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.contentController = self.childViewControllers[0];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [self.contentController preferredInterfaceOrientationForPresentation];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return [self.contentController supportedInterfaceOrientations];
}

- (void)viewDidLayoutSubviews
{
    CGRect contentFrame = self.view.bounds, bannerFrame = CGRectZero;
    
    // All we need to do is ask the banner for a size that fits into the layout area we are using.
    // At this point in this method contentFrame=self.view.bounds, so we'll use that size for the layout.
    bannerFrame.size = [self.bannerView sizeThatFits:contentFrame.size];
    
    DebugLog(@"prototype [%@] canDisplayAds [%@]", NSStringFromClass([self.prototype class]), [self.prototype canDisplayAds] ? @"Y" : @"N");
    
    BOOL canDisplayAds = YES;
    if (self.prototype && [self.prototype respondsToSelector:@selector(canDisplayAds)]) {
        canDisplayAds = [self.prototype canDisplayAds];
    }
    
    if (self.bannerView.isBannerLoaded && canDisplayAds) {
        contentFrame.size.height -= bannerFrame.size.height;
        bannerFrame.origin.y = contentFrame.size.height;
    } else {
        bannerFrame.origin.y = contentFrame.size.height;
    }
    
    if (self.prototype && [self.prototype respondsToSelector:@selector(shouldResizeContent)]) {
        if (![self.prototype shouldResizeContent]) {
            contentFrame = self.view.bounds;
        }
    }
    
    self.contentController.view.frame = contentFrame;
    self.bannerView.frame = bannerFrame;
}

- (void)displayBanner:(BOOL)display
{
    DebugLog(@"isBannerLoaded=[%@] display=[%@]", self.bannerView.isBannerLoaded ? @"Y" : @"N", display ? @"Y" : @"N");
    
    BOOL animted = YES;
    if (self.prototype && [self.prototype respondsToSelector:@selector(animated)]) {
        animted = [self.prototype animated];
    }
    
    [UIView animateWithDuration:animted ? 0.25f : 0.0f animations:^{
        
        // viewDidLayoutSubviews will handle positioning the banner view so that it is visible.
        // You must not call [self.view layoutSubviews] directly.  However, you can flag the view
        // as requiring layout...
        [self.view setNeedsLayout];
        // ... then ask it to lay itself out immediately if it is flagged as requiring layout...
        [self.view layoutIfNeeded];
        // ... which has the same effect.
    }];
}


#pragma ADBannerViewDelegate protocol

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    [self displayBanner:YES];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    [self displayBanner:NO];

    DebugLog(@"error %@", [error localizedDescription]);
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

@implementation UIViewController (Prototype)
@dynamic canDisplayAds, shouldResizeContent, animated;

- (BOOL)canDisplayAds
{
    return [objc_getAssociatedObject(self, @selector(canDisplayAds)) boolValue];
}

- (void)setCanDisplayAds:(BOOL)canDisplayAds
{
    objc_setAssociatedObject(self, @selector(canDisplayAds), @(canDisplayAds), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [[CommonBanner sharedInstance] setPrototype:self];
    
    [[CommonBanner sharedInstance] displayBanner:canDisplayAds];
}

- (BOOL)shouldResizeContent
{
    return [objc_getAssociatedObject(self, @selector(shouldResizeContent)) boolValue];
}

- (void)setShouldResizeContent:(BOOL)shouldResizeContent
{
    objc_setAssociatedObject(self, @selector(shouldResizeContent), @(shouldResizeContent), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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

@implementation UITableViewController (Prototype)
@dynamic canDisplayAds, shouldResizeContent, animated;

- (BOOL)canDisplayAds
{
    return [objc_getAssociatedObject(self, @selector(canDisplayAds)) boolValue];
}

- (void)setCanDisplayAds:(BOOL)canDisplayAds
{
    objc_setAssociatedObject(self, @selector(canDisplayAds), @(canDisplayAds), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [[CommonBanner sharedInstance] setPrototype:self];
    
    [[CommonBanner sharedInstance] displayBanner:canDisplayAds];
}

- (BOOL)shouldResizeContent
{
    return [objc_getAssociatedObject(self, @selector(shouldResizeContent)) boolValue];
}

- (void)setShouldResizeContent:(BOOL)shouldResizeContent
{
    objc_setAssociatedObject(self, @selector(shouldResizeContent), @(shouldResizeContent), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
