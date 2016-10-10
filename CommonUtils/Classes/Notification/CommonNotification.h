//  Created by Karen Lusinyan on 09/10/16.

#import <Foundation/Foundation.h>

extern NSString * const CommonNotificationDidShown;
extern NSString * const CommonNotificationDidHide;

typedef NS_ENUM(NSInteger, CommonNotificationPriority) {
    CommonNotificationPriorityDefault=0,
    CommonNotificationPriorityHigh
};

@interface CommonNotification : NSObject <NSCoding>

// notification configuration
@property (nonatomic) BOOL presentOnTop;                                // default YES
@property (nonatomic, strong) NSString *rootViewControllerClassName;    // defualt nil
@property (nonatomic, strong) UIImage *imageIcon;                       // defualt nil

+ (CommonNotification *)sharedInstance;

- (void)addNotificationWithAlertBody:(NSString *)alertBody
                        alertMessage:(NSString *)alertMessage
                            priority:(CommonNotificationPriority)priority
                         alertAction:(void(^)(void))alertAction;

@end
