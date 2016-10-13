//  Created by Karen Lusinyan on 09/10/16.

#import <Foundation/Foundation.h>

extern NSString * const CommonNotificationDidShown;
extern NSString * const CommonNotificationDidHide;

typedef NS_ENUM(NSInteger, CommonNotificationPriority) {
    CommonNotificationPriorityDefault=0,
    CommonNotificationPriorityHigh
};

@interface CommonNotification : NSObject <NSCoding>

@property (readonly, nonatomic, strong) NSString *identifier;
@property (readonly, nonatomic, strong) NSDate *creationDate;
@property (readonly, nonatomic, strong) NSString *alertBody;
@property (readonly, nonatomic, strong) NSString *alertMessage;
@property (readonly, nonatomic, strong) NSString *alertAction;
@property (readonly, nonatomic, strong) NSDate *fireDate;
@property (readonly, nonatomic) CommonNotificationPriority priority;

@end

@interface CommonNotificationManager : NSObject <NSCoding>

// notification configuration
@property (nonatomic) BOOL presentOnTop;                                // default YES
@property (nonatomic) NSTimeInterval checkNotificationsTimeInterval;    // default 1 sec
@property (nonatomic, strong) NSString *rootViewControllerClassName;    // defualt nil
@property (nonatomic, strong) UIImage *imageIcon;                       // defualt nil
@property (nonatomic) CGFloat notificationHeight;                       // default 120.0

+ (CommonNotificationManager *)sharedInstance;

- (void)addNotificationWithAlertBody:(NSString *)alertBody
                        alertMessage:(NSString *)alertMessage
                         alertAction:(NSString *)alertAction
                            fireDate:(NSDate *)fireDate
                            priority:(CommonNotificationPriority)priority;

- (void)cancelAllNotification;

@end
