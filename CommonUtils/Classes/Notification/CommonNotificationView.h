//  Created by Karen Lusinyan on 10/10/2016.

typedef void(^CommonNotificationViewAlertAction)(void);
typedef void(^CommonNotificationViewDragDown)(void);
typedef void(^CommonNotificationViewDragUp)(void);

#import <UIKit/UIKit.h>

@interface CommonNotificationView : UIView

@property (nonatomic) BOOL presentOnTop;
@property (nonatomic, strong) NSString *alertBody;
@property (nonatomic, strong) NSString *alertMessage;
@property (nonatomic, copy) CommonNotificationViewAlertAction alertAction;
@property (nonatomic, copy) CommonNotificationViewDragDown dragDown;
@property (nonatomic, copy) CommonNotificationViewDragUp dragUp;
@property (nonatomic, strong) UIImage *imageIcon;

- (void)setContentDraggable;

@end