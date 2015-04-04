//  Created by Karen Lusinyan on 03/03/15.
//  Copyright (c) 2015 Karen Lusinyan. All rights reserved.

#import "CommonGameCenter.h"
#import "CommonSerilizer.h"

typedef NS_ENUM(NSInteger, GameCenterRequestChoice) {
    GameCenterRequestChoiceDenied = 0,
    GameCenterRequestChoiceRememberMe,
    GameCenterRequestChoiceGranted,
};

NSString * const NotificationGameCenterWillStartSynchronizing = @"NotificationGameCenterWillStartSynchronizing";
NSString * const NotificationGameCenterDidFinishSynchronizing = @"NotificationGameCenterDidFinishSynchronizing";

#define keyScores @"scores"
#define keyGameCenterRequestChoice @"gameCenterRequestChoice"

typedef void(^CompletionWhenGameViewControllerDisappeared)(void);

@interface CommonGameCenter () <GKGameCenterControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSArray *leaderboards;
@property (nonatomic, assign) UIViewController *viewController;

//key:      (GK)Leaderboard.identifier
//value:    (GK)Score.value
@property (nonatomic, strong) NSMutableDictionary *scores;
@property (nonatomic, copy) CompletionWhenGameViewControllerDisappeared controllerDismissed;
@property (nonatomic) id target;

@end

@implementation CommonGameCenter

- (id)init
{
    self = [super init];
    if (self) {
        self.scores = [CommonSerilizer loadObjectForKey:keyScores];
        if (!self.scores) {
            self.scores = [NSMutableDictionary dictionary];
        }
    }
    return self;
}

#pragma public methods

+ (instancetype)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

+ (void)startWithCompletion:(void (^)(BOOL authenticated, NSError *error))completion
{
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        [[self sharedInstance] startWithCompletion:completion];
    });
}

+ (void)stopWithCompletion:(void (^)(void))completion
{
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        [[self sharedInstance] stopWithCompletion:completion];
    });
}

+ (BOOL)userAuthenticated
{
    return [GKLocalPlayer localPlayer].isAuthenticated;
}

+ (void)reportScore:(int64_t)score forLeaderboard:(NSString*)identifier
{
    [[self sharedInstance] reportScore:score forLeaderboard:identifier];
}

+ (GKScore *)obtainScoreForLeaderboard:(NSString *)identifier
{
    return [[self sharedInstance] obtainScoreForLeaderboard:identifier];
}

+ (void)createLeaderboardIfNotExists:(NSString *)identifier attributes:(NSDictionary *)attributes
{
    [[self sharedInstance] createLeaderboardIfNotExists:identifier attributes:attributes];
}

+ (NSArray *)leaderboards
{
    return [[self sharedInstance] leaderboards];
}

+ (void)setDefaultLeaderboard:(NSString *)identifier
{
    [[self sharedInstance] setDefaultLeaderboard:identifier];
}

+ (void)showLeaderboard:(NSString *)identifier withTarget:(id)target completionWhenDismissed:(void (^)(void))completion
{
    [[self sharedInstance] showLeaderboard:identifier withTarget:target completionWhenDismissed:completion];
}

#pragma private methods

- (UIViewController *)rootViewController
{
    return [[UIApplication sharedApplication].keyWindow rootViewController];
}

- (void)startWithCompletion:(void (^)(BOOL authenticated, NSError *error))completion
{
    [self startAuthenticationWithCompletion:completion];
}

- (void)stopWithCompletion:(void (^)(void))completion
{
    if (completion) completion();
}

- (void)startAuthenticationWithCompletion:(void (^)(BOOL authenticated, NSError *error))completion
{
    [self authenticateUserWithCompletion:^(UIViewController *viewController, NSError *error) {
        if (viewController) {   //needs login to game center

            /*
            [[self rootViewController] presentViewController:self.viewController
                                                    animated:YES
                                                  completion:nil];

            //*/
            
            //**********************HANDLE USER ACCESS TO GAMECENTER ACCOUNT**********************//
            self.viewController = viewController;
            if ([CommonSerilizer loadObjectForKey:keyGameCenterRequestChoice] != nil) {
                NSInteger lastChoice = [[CommonSerilizer loadObjectForKey:keyGameCenterRequestChoice] integerValue];
                if (lastChoice == GameCenterRequestChoiceDenied) {
                    [self synchronizationDidFinish];
                    return;
                }
            }
            [self askForGameCenterAccess];
            //**********************HANDLE USER ACCESS TO GAMECENTER ACCOUNT**********************//

            if (completion) completion(NO, error);
        }
        else if (!error && [GKLocalPlayer localPlayer].isAuthenticated) {
            [self loadLeaderboards];
            if (completion) completion (YES, nil);
        }
        else if (error) {
            [self synchronizationDidFinish];
            if (completion) completion(NO, error);
        }
    }];
}

- (void)authenticateUserWithCompletion:(void (^)(UIViewController *viewController, NSError *error))completion
{   
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    if (localPlayer.authenticated == NO) {
        [localPlayer setAuthenticateHandler:^(UIViewController *viewController, NSError *error) {
            if (completion) completion(viewController, error);
        }];
    }
    else {
        if (completion) completion(nil, nil);
    }
}

- (void)loadLeaderboards
{
    [self synchronizationWillStart];
    
    [GKLeaderboard loadLeaderboardsWithCompletionHandler:^(NSArray *leaderboards, NSError *error) {
        //DebugLog(@"Leaderboards %@", leaderboards);
        self.leaderboards = leaderboards;
        if (error || self.leaderboards == nil) {
            [self synchronizationDidFinish];
        }
        else {
            [self synchronizeLeaderboards];
        }
    }];
}

#pragma scores

- (void)restoreScores
{
    for (GKLeaderboard *leaderboard in self.leaderboards) {
        if ([self.scores objectForKey:leaderboard.identifier]) {
            [self.scores removeObjectForKey:leaderboard.identifier];
            [CommonSerilizer saveObject:self.scores forKey:keyScores];
        }
    }
}

- (void)synchronizeLeaderboards
{
    __block NSInteger syncCount = 0;
    
    for (int i = 0; i < [self.leaderboards count]; i++) {
        @autoreleasepool {
            GKLeaderboard *leaderboard = [self.leaderboards objectAtIndex:i];
            DebugLog(@"start sync leaderboard at index=[%@]", @(i));
            [leaderboard loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error) {
                if (error) {
                    [self synchronizationDidFinish];
                }
                else {
                    // if local score exists
                    if ([self.scores objectForKey:leaderboard.identifier]) {
                        GKScore *local = [self.scores objectForKey:leaderboard.identifier];
                        // if remote score exists
                        if (leaderboard.localPlayerScore) {
                            //if remote score higher than local score then save it
                            if (leaderboard.localPlayerScore.value > local.value) {
                                [self.scores setObject:leaderboard.localPlayerScore forKeyedSubscript:leaderboard.identifier];
                                [CommonSerilizer saveObject:self.scores forKey:keyScores];
                            }
                            // if local score higher than remote score then send it
                            else if (leaderboard.localPlayerScore.value < local.value) {
                                GKScore *remote = [[GKScore alloc] initWithLeaderboardIdentifier:leaderboard.identifier];
                                remote.value = local.value;
                                [GKScore reportScores:@[remote] withCompletionHandler:^(NSError *error) {
                                    DebugLog(@"Uploading score did finish with error %@", [error localizedDescription]);
                                }];
                            }
                        }
                        
                        DebugLog(@"finish sync leaderboard at index=[%@]", @(i));
                        syncCount++;
                        if (syncCount == [self.leaderboards count]) {
                            [self synchronizationDidFinish];
                        }
                    }
                    // if local score does not exists and it remote score exists then save it
                    else if (leaderboard.localPlayerScore) {
                        [self.scores setObject:leaderboard.localPlayerScore forKey:leaderboard.identifier];
                        [CommonSerilizer saveObject:self.scores forKey:keyScores];
                        
                        DebugLog(@"finish sync leaderboard at index=[%@]", @(i));
                        syncCount++;
                        if (syncCount == [self.leaderboards count]) {
                            [self synchronizationDidFinish];
                        }
                    }
                    else {
                        // proceed in any case
                        [self synchronizationDidFinish];
                    }
                }
            }];
        }
    }
}

- (BOOL)leaderboardExistsWithIdentifier:(NSString *)identifier
{
    return ([[self.leaderboards filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"identifier = %@", identifier]] firstObject] != nil);
}

- (void)reportScore:(int64_t)score forLeaderboard:(NSString *)identifier
{
    NSString *assert = [NSString stringWithFormat:@"Assertion in %@ 'identifier' can not be nil", NSStringFromSelector(_cmd)];
    NSAssert(identifier, assert);
    
    if ([GKLocalPlayer localPlayer].isAuthenticated && [self leaderboardExistsWithIdentifier:identifier]) {
        //report score to game center
        GKScore *remote = [[GKScore alloc] initWithLeaderboardIdentifier:identifier];
        remote.value = score;
        
        NSArray *scores = @[remote];
        [GKScore reportScores:scores withCompletionHandler:^(NSError *error) {
            DebugLog(@"Uploading score did finish with error %@", [error localizedDescription]);
        }];
    }
    
    //save score locally if needed
    GKScore *local = nil;
    if ([self.scores objectForKey:identifier]) {
        local = [self.scores objectForKey:identifier];
        if (score > local.value) local.value = score;
    }
    else {
        local = [[GKScore alloc] initWithLeaderboardIdentifier:identifier];
        local.value = score;
        [self.scores setObject:local forKey:identifier];
    }
    
    [CommonSerilizer saveObject:self.scores forKey:keyScores];
}

- (GKScore *)obtainScoreForLeaderboard:(NSString *)identifier
{
    if (![self.scores objectForKey:identifier]) {
        GKScore *local = [[GKScore alloc] initWithLeaderboardIdentifier:identifier];
        [self.scores setObject:local forKey:identifier];
        [CommonSerilizer saveObject:self.scores forKey:keyScores];
    }

    return [self.scores objectForKey:identifier];
}

- (void)createLeaderboardIfNotExists:(NSString *)identifier attributes:(NSDictionary *)attributes
{
    if (![self.scores objectForKey:identifier]) {
        GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier:identifier];
        if (attributes) {
            [score setValuesForKeysWithDictionary:attributes];
        }
        [self.scores setObject:score forKey:identifier];
        [CommonSerilizer saveObject:self.scores forKey:keyScores];
    }
}

#pragma leaderboard

- (void)setDefaultLeaderboard:(NSString *)identifier
{
    [[GKLocalPlayer localPlayer] setDefaultLeaderboardIdentifier:identifier completionHandler:^(NSError *error) {
        if (self.controllerDismissed) self.controllerDismissed();
    }];
}

- (void)showLeaderboard:(NSString *)identifier withTarget:(id)target completionWhenDismissed:(void (^)(void))completion
{
    self.target = target;

    if ([GKLocalPlayer localPlayer].isAuthenticated) {
        GKGameCenterViewController *gameCenterController = [[GKGameCenterViewController alloc] init];
        if (gameCenterController != nil) {
            gameCenterController.gameCenterDelegate = self;
            gameCenterController.viewState = GKGameCenterViewControllerStateLeaderboards;
            gameCenterController.leaderboardIdentifier = identifier;
            [target presentViewController:gameCenterController
                                 animated:YES
                               completion:nil];
            
            self.controllerDismissed = completion;
        }
    }
}

#pragma GKGameCenterControllerDelegate

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [gameCenterViewController dismissViewControllerAnimated:YES completion:^{
        if (self.controllerDismissed) self.controllerDismissed();
    }];
}

- (void)synchronizationWillStart
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationGameCenterWillStartSynchronizing object:nil];
    
    DebugLog(@"//**************BEFORE GAME-CENTER SYNCRONIZATION**************//");
    [self print];
    DebugLog(@"//**************BEFORE GAME-CENTER SYNCRONIZATION**************//");
}

- (void)synchronizationDidFinish
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationGameCenterDidFinishSynchronizing object:nil];
    
    DebugLog(@"//**************AFTER GAME-CENTER SYNCRONIZATION**************//");
    [self print];
    DebugLog(@"//**************AFTER GAME-CENTER SYNCRONIZATION**************//");
}

- (void)print
{
    for (NSString *identifier in [self.scores allKeys]) {
        GKScore *local = [self.scores objectForKey:identifier];
        DebugLog(@"leaderbaord %@ player score %@", identifier, @(local.value));
    }
}

- (void)askForGameCenterAccess
{
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Game Center Requested"
                                                 message:[NSString stringWithFormat:@"%@ would like to access your Game Center account", appName]
                                                delegate:self
                                       cancelButtonTitle:@"Cancel"
                                       otherButtonTitles:@"Decide later", @"Sign in", nil];
    [av show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == GameCenterRequestChoiceDenied || buttonIndex == GameCenterRequestChoiceRememberMe) {
        [self synchronizationDidFinish];
    }
    else  {
        [[self rootViewController] presentViewController:self.viewController
                                                animated:YES
                                              completion:nil];
    }
    
    [CommonSerilizer saveObject:@(buttonIndex) forKey:keyGameCenterRequestChoice];
}

@end
