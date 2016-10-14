//  Created by Karen Lusinyan on 15/04/14.

#import "AppDelegate.h"
#import "TestViewController.h"
#import "Appirater.h"

#import "CommonCrash.h"
//#import "CommonBanner.h"

#import "FICImageCache.h"
#import "CUImage.h"
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "CommonNotificationManager.h"
#import "NSDate+DateTools.h"

@interface AppDelegate () <FICImageCacheDelegate>

@property (nonatomic, strong) NSOperationQueue *requestQueue;

@end

@implementation AppDelegate

// TESTING NOTIFICATIONS
+ (NSString *)loremIpsum
{
    return @"Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.";
}

+ (NSString *)loremIpsumMedium
{
    return @"Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
}

+ (NSString *)loremIpsumShort
{
    return @"Lorem ipsum dolor sit er elit lamet";
}

+ (NSString *)rndLoremIpsum
{
    int rnd = arc4random_uniform((u_int32_t)[self loremIpsum].length);
    return [[self loremIpsum] substringWithRange:NSMakeRange(0, rnd)];
}

+ (NSString *)rndLoremIpsumShort
{
    int rnd = arc4random_uniform((u_int32_t)[self loremIpsumShort].length);
    return [[self loremIpsumShort] substringWithRange:NSMakeRange(0, rnd)];
}

- (void)configureCommonNotifications
{
    [CommonNotificationManager sharedInstance].presentOnTop = YES;
    [CommonNotificationManager sharedInstance].checkNotificationsTimeInterval = 10.0;
    [CommonNotificationManager sharedInstance].imageIcon = [UIImage imageNamed:@"apple"];
    [CommonNotificationManager sharedInstance].notificationHeight = 120.0;
}

- (void)generateNotifications
{
    [NSTimer scheduledTimerWithTimeInterval:5
                                     target:self
                                   selector:@selector(runGenerateNotifications:)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)runGenerateNotifications:(NSTimer *)timer
{
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    
    NSDate *fireDate = (arc4random_uniform(2)) ? [date dateByAddingMinutes:1] : nil;
    [[CommonNotificationManager sharedInstance] addNotificationWithAlertBody:[dateFormatter stringFromDate:date]
                                                                alertMessage:[[self class] rndLoremIpsum]
                                                                 alertAction:nil
                                                                    fireDate:fireDate
                                                                    priority:CommonNotificationPriorityDefault];
}
// TESTING NOTIFICATIONS

- (void)setupAFNetworking
{
    self.requestQueue = [NSOperationQueue new];
    self.requestQueue.maxConcurrentOperationCount = 5;
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
}

- (void)setupFastImageCache
{
    FICImageFormat *photoThumbnailImageFormat = [[FICImageFormat alloc] init];
    photoThumbnailImageFormat.name = CUPhotoSquareImage32BitBGRAFormatName;
    photoThumbnailImageFormat.family = CUPhotoImageFormatFamily;
    photoThumbnailImageFormat.style = FICImageFormatStyle32BitBGRA;
    photoThumbnailImageFormat.imageSize = CUPhotoThumnailSize;
    photoThumbnailImageFormat.maximumCount = 250;
    photoThumbnailImageFormat.devices = FICImageFormatDevicePhone | FICImageFormatDevicePad;
    photoThumbnailImageFormat.protectionMode = FICImageFormatProtectionModeNone;

    // Configure the image cache
    FICImageCache *sharedImageCache = [FICImageCache sharedImageCache];
    [sharedImageCache setDelegate:self];
    [sharedImageCache setFormats:@[photoThumbnailImageFormat]];
}

#pragma mark - FICImageCacheDelegate protocol

// download from network
- (void)imageCache:(FICImageCache *)imageCache wantsSourceImageForEntity:(id<FICEntity>)entity
    withFormatName:(NSString *)formatName
   completionBlock:(FICImageRequestCompletionBlock)completionBlock {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        // grab the url from "entity"
        NSURL *URL = [entity sourceImageURLWithFormatName:formatName];

        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager GET:URL.absoluteString
          parameters:nil
            progress:nil
             success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                 completionBlock(responseObject);
                 DebugLog(@"success with image %@", responseObject);
             } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                 DebugLog(@"error %@", error);
             }];
    });
}

// read from disk
/*
- (void)imageCache:(FICImageCache *)imageCache
wantsSourceImageForEntity:(id<FICEntity>)entity
    withFormatName:(NSString *)formatName
   completionBlock:(FICImageRequestCompletionBlock)completionBlock {
    // Images typically come from the Internet rather than from the app bundle directly, so this would be the place to fire off a network request to download the image.
    // For the purposes of this demo app, we'll just access images stored locally on disk.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *sourceImage = [(FICDPhoto *)entity sourceImage];
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(sourceImage);
        });
    });
}
//*/

- (BOOL)imageCache:(FICImageCache *)imageCache
shouldProcessAllFormatsInFamily:(NSString *)formatFamily
         forEntity:(id<FICEntity>)entity {
    return NO;
}

- (void)imageCache:(FICImageCache *)imageCache
errorDidOccurWithMessage:(NSString *)errorMessage {
    DebugLog(@"%@", errorMessage);
}

#pragma CommonCrashDelegate protocol

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self configureCommonNotifications];
    [self generateNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:CommonNotificationDidHide
                                                      object:nil
                                                       queue:[NSOperationQueue currentQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      if ([[note object] isMemberOfClass:[CommonNotification class]]) {
                                                          CommonNotification *notification = (CommonNotification *)[note object];
                                                          DebugLog(@"notification %@", notification);
                                                      }
                                                  }];

    application.idleTimerDisabled = YES;
    
    /*
    [CommonBanner regitserProvider:[CommonBannerProvideriAd class]
                      withPriority:CommonBannerPriorityHigh
                     requestParams:nil];
    
    [CommonBanner regitserProvider:[CommonBannerProviderGAd class]
                      withPriority:CommonBannerPriorityLow
                     requestParams:@{keyAdUnitID    : @"ca-app-pub-3940256099942544/2934735716",
                                     keyTestDevices : @[kDFPSimulatorID]}];

     //[CommonBanner regitserProvider:[CommonBannerProviderCustom class]
     //withPriority:CommonBannerPriorityLow
     //requestParams:nil];
    
    [CommonBanner setDebugMode:NO];
    [CommonBanner startManaging];
     
     //*/
    [Appirater setAppId:@"770699556"];                  //iTunes ID
    [Appirater setDaysUntilPrompt:0];                   //days after first prompt
    [Appirater setUsesUntilPrompt:5];                   //number of times for next visualizzation
    [Appirater setSignificantEventsUntilPrompt:-1];     //set significant event by calling userDidSignificantEvent:
    [Appirater setTimeBeforeReminding:0];               //value in days
    [Appirater setDebug:NO];                            //for production use always NO
    [Appirater appLaunched:YES];                        //start launching rater
    
    // your controllers
    /*
    TestViewController *vc = [[TestViewController alloc] init];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];

    // set CommonBanner as a rootViewController of window
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [CommonBanner bannerControllerWithRootViewController:nc];
    [self.window makeKeyAndVisible];
     //*/

    [self setupAFNetworking];
    [self setupFastImageCache];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [Appirater appEnteredForeground:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
