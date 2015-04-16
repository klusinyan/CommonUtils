//  Created by Karen Lusinyan on 03/03/15.
//  Copyright (c) 2015 Karen Lusinyan. All rights reserved.

#import "CommonGameCenter.h"
#import "CommonSerilizer.h"
#import "DirectoryUtils.h"

#define kBundleName @"CommonGameCenter.bundle"

NSString * const CommonGameCenterWillStartSynchronizing  = @"CommonGameCenterWillStartSynchronizing";
NSString * const CommonGameCenterDidFinishSynchronizing  = @"CommonGameCenterDidFinishSynchronizing";
NSString * const CommonGameCenterLocalPlayerDidChange    = @"CommonGameCenterLocalPlayerDidChange";
NSString * const CommonGameCenterLocalPlayerPhotoDidLoad = @"CommonGameCenterLocalPlayerPhotoDidLoad";

#define keyUserCancelledAuthentication @"userCancelledAuthentication"
#define keyPlayerScores @"playerScores"
#define kUnsignedPlayerID @"unsignedPlayer"

typedef void(^CompletionWhenGameViewControllerDisappeared)(void);

@interface CommonGameCenter () <GKGameCenterControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSArray *leaderboards;
@property (nonatomic, strong) UIViewController *viewController;

// persistent
// key:      (NSString)playerId
// value:    (NSDictionary)scores
@property (nonatomic, strong) NSMutableDictionary *playerScores;

// volatile
// key:      (GK)Leaderboard.identifier
// value:    (GK)Score.value
@property (nonatomic, strong) NSMutableDictionary *scores;
@property (nonatomic, copy) CompletionWhenGameViewControllerDisappeared controllerDismissed;
@property (nonatomic) id target;

// volatile variable saves local player's ID, local player's photo (if exists)
@property (nonatomic, copy) NSString *localPlayerID;
@property (nonatomic, strong) UIImage *localPlayerPhoto;

@end

@implementation CommonGameCenter
@synthesize localPlayerID = _localPlayerID;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init
{
    self = [super init];
    if (self) {
        
        self.playerScores = [CommonSerilizer loadObjectForKey:keyPlayerScores];
        if (self.playerScores == nil) {
            self.playerScores = [NSMutableDictionary dictionary];
        }
        
        // Important: system calls every type app wakes up
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerDidChange:)
                                                     name:GKPlayerDidChangeNotificationName
                                                   object:nil];
    }

    return self;
}

- (NSString *)localPlayerDisplayName
{
    NSString *displayName = nil;
    if ([GKLocalPlayer localPlayer].isAuthenticated) {
        displayName = [GKLocalPlayer localPlayer].displayName;
    }
    return displayName;
}

- (UIImage *)localPlayerPhoto
{
    @synchronized(self) {
        if (_localPlayerPhoto == nil) {
            _localPlayerPhoto = [DirectoryUtils imageExistsWithName:[self localPlayerID] moduleName:@"images"];
            if (_localPlayerPhoto == nil) {
                _localPlayerPhoto = [DirectoryUtils imageWithName:@"defaultPhoto" bundleName:kBundleName];
                NSString *path = [DirectoryUtils imagePathWithName:[self localPlayerID] moduleName:@"images"];
                [DirectoryUtils saveImage:_localPlayerPhoto
                               toFilePath:path
                      imageRepresentation:UIImageRepresentationPNG];
            }
        }
        return _localPlayerPhoto;
    }
}

- (NSString *)localPlayerID
{
    @synchronized(self) {
        if (_localPlayerID == nil) {
            return kUnsignedPlayerID;
        }
        return _localPlayerID;
    }
}

- (NSMutableDictionary *)scores
{
    @synchronized(self) {
        if (_scores == nil) {
            if ([self.playerScores objectForKey:[self localPlayerID]] != nil) {
                _scores = [self.playerScores objectForKey:[self localPlayerID]];
            }
            else {
                _scores = [NSMutableDictionary dictionary];
                [self.playerScores setObject:_scores forKey:[self localPlayerID]];
                [CommonSerilizer saveObject:self.playerScores forKey:keyPlayerScores];
            }
        }
        return _scores;
    }
}

#pragma player did change notification

- (void)playerDidChange:(NSNotification *)notification
{
    @synchronized(self) {
        NSString *playerID = [[notification object] playerID];
        
        ///*
        // luser logged to game center
        BOOL cond1 = (playerID != nil && _localPlayerID == nil);
        if (cond1) DebugLog(@"USER LOGGED IN GAME CENTER. LAST ID=[%@], CURRENT ID=[%@]", [self localPlayerID], playerID);
        
        // user logout from game center
        BOOL cond2 = (playerID == nil && _localPlayerID != nil);
        if (cond2) DebugLog(@"USER LOGOUT FROM GAME CENTER. LAST ID=[%@], CURRENT ID=[%@]", [self localPlayerID], playerID);
        
        // player did change
        if (cond1 || cond2) {
            
            // save new player
            self.localPlayerID = playerID;
            
            // reset current photo
            self.localPlayerPhoto = nil;
            
            // force reset all scores for previous player
            self.scores = nil;
            
            // async call
            [self loadPlayerPhotoIfNeeded];
            
            // player did change notification send to subscribers
            [[NSNotificationCenter defaultCenter] postNotificationName:CommonGameCenterLocalPlayerDidChange object:[self localPlayerID]];
        }
        //*/
    }
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

+ (void)startAuthenticationWithCompletion:(void (^)(BOOL authenticated, NSError *error))completion
{
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        [[self sharedInstance] startManaginWithCompletion:completion];
    });
}

+ (void)stopWithCompletion:(void (^)(void))completion
{
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        [[self sharedInstance] stopWithCompletion:completion];
    });
}

+ (BOOL)playerIsAuthenticated
{
    return [GKLocalPlayer localPlayer].isAuthenticated;
}

+ (NSString *)localPlayerDisplayName
{
    return [[self sharedInstance] localPlayerDisplayName];
}

+ (UIImage *)localPlayerPhoto
{
    return [[self sharedInstance] localPlayerPhoto];
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

- (void)startManaginWithCompletion:(void (^)(BOOL authenticated, NSError *error))completion
{
    [self startAuthenticationWithCompletion:completion];
}

- (void)startAuthenticationWithCompletion:(void (^)(BOOL authenticated, NSError *error))completion
{
    [self authenticateUserWithCompletion:^(UIViewController *viewController, NSError *error) {
        if (viewController) {
            if ([[CommonSerilizer loadObjectForKey:keyUserCancelledAuthentication] boolValue]) {
                if (completion) completion(NO, error);
                [self synchronizationDidFinish];
                return;
            }
            [[self rootViewController] dismissViewControllerAnimated:NO completion:nil];
            [[self rootViewController] presentViewController:viewController
                                                    animated:YES
                                                  completion:nil];
        }
        else if (!error && [GKLocalPlayer localPlayer].isAuthenticated) {
            [self loadLeaderboards];
            if (completion) completion (YES, error);
        }
        else if (error) {
            //user cancelled authentification
            if (error.code == 2) {
                [CommonSerilizer saveObject:@(YES) forKey:keyUserCancelledAuthentication];
            }
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
}

- (void)loadPlayerPhotoIfNeeded
{
    if ([GKLocalPlayer localPlayer].isAuthenticated) {
        [[GKLocalPlayer localPlayer] loadPhotoForSize:GKPhotoSizeNormal
                                withCompletionHandler:^(UIImage *photo, NSError *error) {
                                    if (photo != nil) {
                                        // path last component is md5 of [self localPlayerID]
                                        NSString *path = [DirectoryUtils imagePathWithName:[self localPlayerID] moduleName:@"images"];
                                        // save to disk
                                        [DirectoryUtils saveImage:photo
                                                       toFilePath:path
                                              imageRepresentation:UIImageRepresentationPNG];
                                        
                                        // notify notification subscribers
                                        [[NSNotificationCenter defaultCenter]
                                         postNotificationName:CommonGameCenterLocalPlayerPhotoDidLoad object:photo];
                                    }
                                }];
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
        }
    }
    [self.playerScores setObject:self.scores forKey:[self localPlayerID]];
    [CommonSerilizer saveObject:self.playerScores forKey:keyPlayerScores];
}

- (void)synchronizeLeaderboards
{
    __block NSInteger syncCount = 0;
    
    for (int i = 0; i < [self.leaderboards count]; i++) {
        @autoreleasepool {
            __block GKLeaderboard *leaderboard = [self.leaderboards objectAtIndex:i];
            DebugLog(@"start sync leaderboard at index=[%@]", @(i));
            [leaderboard loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error) {
                if (error) {
                    [self synchronizationDidFinish];
                    leaderboard = nil;
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
                                [self.playerScores setObject:self.scores forKey:[self localPlayerID]];
                                [CommonSerilizer saveObject:self.playerScores forKey:keyPlayerScores];
                            }
                            // if local score higher than remote score then send it
                            else if (leaderboard.localPlayerScore.value < local.value) {
                                __block GKScore *remote = [[GKScore alloc] initWithLeaderboardIdentifier:leaderboard.identifier];
                                remote.value = local.value;
                                [GKScore reportScores:@[remote] withCompletionHandler:^(NSError *error) {
                                    DebugLog(@"Uploading score did finish with error %@", [error localizedDescription]);
                                    remote = nil;
                                }];
                            }
                        }
                        
                        DebugLog(@"finish sync leaderboard at index=[%@]", @(i));
                        syncCount++;
                        if (syncCount == [self.leaderboards count]) {
                            [self synchronizationDidFinish];
                            leaderboard = nil;
                        }
                    }
                    // if local score does not exists and it remote score exists then save it
                    else if (leaderboard.localPlayerScore) {
                        [self.scores setObject:leaderboard.localPlayerScore forKey:leaderboard.identifier];
                        [self.playerScores setObject:self.scores forKey:[self localPlayerID]];
                        [CommonSerilizer saveObject:self.playerScores forKey:keyPlayerScores];
                        
                        DebugLog(@"finish sync leaderboard at index=[%@]", @(i));
                        syncCount++;
                        if (syncCount == [self.leaderboards count]) {
                            [self synchronizationDidFinish];
                            leaderboard = nil;
                        }
                    }
                    else {
                        // proceed in any case
                        [self synchronizationDidFinish];
                        leaderboard = nil;
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
        // report score to game center
        __block GKScore *remote = [[GKScore alloc] initWithLeaderboardIdentifier:identifier];
        remote.value = score;
        NSArray *scores = @[remote];
        [GKScore reportScores:scores withCompletionHandler:^(NSError *error) {
            DebugLog(@"Uploading score did finish with error %@", [error localizedDescription]);
            remote = nil;
        }];
    }
    
    // save score locally if needed
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
    
    [self.playerScores setObject:self.scores forKey:[self localPlayerID]];
    [CommonSerilizer saveObject:self.playerScores forKey:keyPlayerScores];
}

- (GKScore *)obtainScoreForLeaderboard:(NSString *)identifier
{
    if (![self.scores objectForKey:identifier]) {
        GKScore *local = [[GKScore alloc] initWithLeaderboardIdentifier:identifier];
        [self.scores setObject:local forKey:identifier];
        [self.playerScores setObject:self.scores forKey:[self localPlayerID]];
        [CommonSerilizer saveObject:self.playerScores forKey:keyPlayerScores];
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
        [self.playerScores setObject:self.scores forKey:[self localPlayerID]];
        [CommonSerilizer saveObject:self.playerScores forKey:keyPlayerScores];
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
    [[NSNotificationCenter defaultCenter] postNotificationName:CommonGameCenterWillStartSynchronizing object:nil];
    
    DebugLog(@"//**************BEFORE GAME-CENTER SYNCRONIZATION**************//");
    [self print];
    DebugLog(@"//**************BEFORE GAME-CENTER SYNCRONIZATION**************//");
}

- (void)synchronizationDidFinish
{
    [[NSNotificationCenter defaultCenter] postNotificationName:CommonGameCenterDidFinishSynchronizing object:nil];
    
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

@end
