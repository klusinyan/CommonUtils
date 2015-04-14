//  Created by Karen Lusinyan on 03/03/15.
//  Copyright (c) 2015 Karen Lusinyan. All rights reserved.

#import <GameKit/GameKit.h>

extern NSString * const CommonGameCenterWillStartSynchronizing;
extern NSString * const CommonGameCenterDidFinishSynchronizing;
extern NSString * const CommonGameCenterLocalPlayerDidChange;
extern NSString * const CommonGameCenterLocalPlayerPhotoDidLoad;

@interface CommonGameCenter : NSObject

/*!
 *  @brief  Call this method to start managing game center
 *
 *  @param completion completion of authentification
 */
+ (void)startWithCompletion:(void (^)(BOOL authenticated, NSError *error))completion;

/*!
 *  @brief  Call this method to stop managing game center
 */
+ (void)stopWithCompletion:(void (^)(void))completion;

/*!
 *  @brief  Call this method to get user's authentification state
 *
 *  @return return YES if user is logged in game center
 */
+ (BOOL)userAuthenticated;

/*!
 *  @brief  Call this method to get local player photo
 *
 *  @return return placeholder if not exists in game center
 */
+ (UIImage *)localPlayerPhoto;

/*!
 *  @brief  Call this method to sent score to specific leaderboard
 *
 *  @param score       player's score to report to game center
 *  @param identifier  leaderboard identifier
 *  @param synchronize set YES if leader exists in game center
 */
+ (void)reportScore:(int64_t)score forLeaderboard:(NSString *)identifier;

/*!
 *  @brief  Call this method to obtain local Player score for given leaderboard
 *
 *  @param identifier leaderboard identifier
 *  @param defaultValue  defualt value if needed
 *  @return local player score
 */
+ (GKScore *)obtainScoreForLeaderboard:(NSString *)identifier;

/*!
 *  @brief  Call this method to create local leaderboard
 *
 *  @param identifier leaderboard identifier
 *  @param attributes pass GKScore attributes as a dictionary
 *
 *  @return returns score
 */
+ (void)createLeaderboardIfNotExists:(NSString *)identifier attributes:(NSDictionary *)attributes;

/*!
 *  @brief  Call thid method to get leaderboard indentifiers
 *
 *  @return leaderboard identifiers
 */
+ (NSArray *)leaderboards;

/*!
 *  @brief  Call this method to set defualt leaderboard
 *
 *  @param identifier leaderboard identifier to set
 */
+ (void)setDefaultLeaderboard:(NSString *)identifier;

/*!
 *  @brief  Call this method to display leaderboard
 *
 *  @param identifier leaderboardID leaderboard's identifier to display
 *  @param target     target ViewController
 *  @param completion completion after leaderboard controller dismissed
 */
+ (void)showLeaderboard:(NSString *)identifier withTarget:(id)target completionWhenDismissed:(void (^)(void))completion;

@end
