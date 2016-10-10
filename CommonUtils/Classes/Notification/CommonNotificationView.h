//  Created by Karen Lusinyan on 10/10/2016.

typedef void(^CommonNotificationViewAlertAction)(void);

#import <UIKit/UIKit.h>

@interface CommonNotificationView : UIView

@property (nonatomic, strong) NSString *alertBody;
@property (nonatomic, strong) NSString *alertMessage;
@property (nonatomic, copy) CommonNotificationViewAlertAction alertAction;
@property (nonatomic, strong) UIImage *imageIcon;

@end
