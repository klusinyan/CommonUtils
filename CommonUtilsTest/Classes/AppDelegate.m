//  Created by Karen Lusinyan on 15/04/14.

#import "AppDelegate.h"
#import "TestViewController.h"
#import "Appirater.h"

#import "CommonCrash.h"
#import "CommonBanner.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

#pragma CommonCrashDelegate protocol

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    application.idleTimerDisabled = YES;
    
    [CommonBanner regitserProvider:[CommonBannerProvideriAd class]
                      withPriority:CommonBannerPriorityHigh
                     requestParams:nil];
    
    [CommonBanner regitserProvider:[CommonBannerProviderGAd class]
                      withPriority:CommonBannerPriorityLow
                     requestParams:@{keyAdUnitID    : @"ca-app-pub-3940256099942544/2934735716",
                                     keyTestDevices : @[kDFPSimulatorID]}];
    /*
     [CommonBanner regitserProvider:[CommonBannerProviderCustom class]
     withPriority:CommonBannerPriorityLow
     requestParams:nil];
     //*/
    
    [CommonBanner setDebugMode:NO];
    [CommonBanner startManaging];

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
