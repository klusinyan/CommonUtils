//  Created by Karen Lusinyan on 09/10/16.

#import "CommonNotification.h"
#import "CommonNotificationView.h"
#import "CommonPicker.h"
#import "DirectoryUtils.h"

NSString * const CommonNotificationDidShown = @"CommonNotificationDidShown";
NSString * const CommonNotificationDidHide  = @"CommonNotificationDidHide";

@interface CommonNotification ()
<
CommonPickerDataSource,
CommonPickerDelegate
>

@property (nonatomic, strong) NSMutableArray *notificationQueue;
@property (nonatomic, assign) NSTimer *notificationDispatcher;
@property (nonatomic) BOOL notificationShown;

@end

@implementation CommonNotification

#pragma mark - utils

+ (UIView *)loadNibForClass:(Class)aClass atIndex:(NSInteger)index
{
    return [[[DirectoryUtils bundleWithName:kCommonBundleName] loadNibNamed:NSStringFromClass(aClass) owner:self options:nil] objectAtIndex:index];
}

#pragma mark - public methods

- (id)initOnce
{
    self = [super init];
    if (self) {
        self.presentOnTop = YES;
    }
    return self;
}

+ (CommonNotification *)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] initOnce];
        [_sharedObject startNotificationDispatcher];
    });
    return _sharedObject;
}

- (void)addNotificationWithAlertBody:(NSString *)alertBody
                        alertMessage:(NSString *)alertMessage
                            priority:(CommonNotificationPriority)priority
                         alertAction:(void(^)(void))alertAction
{
    @synchronized (self) {
        CommonPicker *notification = [CommonPicker new];
        notification.dataSource = self;
        notification.delegate = self;
        notification.toolbarHidden = YES;
        notification.needsOverlay = YES;
        notification.bounceEnabled = YES;
        notification.presentFromTop = self.presentOnTop;
        notification.applyBlurEffect = YES;
        notification.notificationMode = YES;
        notification.blurEffectStyle = UIBlurEffectStyleDark;
        notification.pickerCornerradius = 10.0;
        
        CommonNotificationView *contentView = (CommonNotificationView *)[CommonNotification loadNibForClass:NSClassFromString(@"CommonNotificationView") atIndex:0];
        contentView.alertBody = alertBody;
        contentView.alertMessage = alertMessage;
        contentView.imageIcon = self.imageIcon;
        notification.contentView = contentView;
        
        __weak __typeof(self) weakSelf = self;
        contentView.alertAction = ^(void){
            [notification dismissPickerWithCompletion:^{
                weakSelf.notificationShown = NO;
                if ([weakSelf.notificationQueue count] > 0) {
                    [weakSelf.notificationQueue removeObjectAtIndex:0];
                }
                if (notification.presentFromTop) {
                    [UIApplication sharedApplication].keyWindow.windowLevel = UIWindowLevelNormal;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:CommonNotificationDidHide object:nil];
                if (alertAction) alertAction();
            }];
        };
        
        if (priority == CommonNotificationPriorityHigh && [self.notificationQueue count] > 1) {
            [self.notificationQueue insertObject:notification atIndex:1];
        }
        else {
            [self.notificationQueue addObject:notification];
        }
        
        [self dispatchNotifications:self.notificationDispatcher];
    }
}
#pragma mark - private methods

#pragma mark - getter/setter

- (NSMutableArray *)notificationQueue
{
    if (_notificationQueue == nil) {
        _notificationQueue = [NSMutableArray array];
    }
    return _notificationQueue;
}

- (void)startNotificationDispatcher
{
    self.notificationDispatcher = [NSTimer scheduledTimerWithTimeInterval:5
                                                                   target:self
                                                                 selector:@selector(dispatchNotifications:)
                                                                 userInfo:nil
                                                                  repeats:YES];
}

- (void)dispatchNotifications:(NSTimer *)timer
{
    @synchronized (self) {
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            if (self.notificationShown) {
                return;
            }
            UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
            if (![rootViewController isMemberOfClass:NSClassFromString(self.rootViewControllerClassName)]) {
                return;
            }
            if ([self.notificationQueue count] > 0) {
                rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                CommonPicker *notification = self.notificationQueue[0];
                notification.target = rootViewController;
                notification.sender = rootViewController.view;
                notification.relativeSuperview = nil;
                if ([self.notificationQueue count] > 0) {
                    self.notificationShown = YES;
                    if (notification.presentFromTop) {
                        [UIApplication sharedApplication].keyWindow.windowLevel = UIWindowLevelAlert;
                    }
                    [notification showPickerWithCompletion:^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:CommonNotificationDidShown object:nil];
                    }];
                }
            }
        }
    }
}

#pragma mark CommonPickerDataSource protocol

- (id)contentForPicker:(CommonPicker *)picker
{
    return picker.contentView;
}

- (CGFloat)heightForPicker:(CommonPicker *)picker
{
    return 175.0;
}

- (CGFloat)widthForPicker:(CommonPicker *)picker
{
    CGFloat width = CGRectGetWidth([UIApplication sharedApplication].keyWindow.frame);
    if (iPad) {
        width = width / 2;
    }
    return width;
}

- (CGFloat)paddingForPicker:(CommonPicker *)picker
{
    return 5.0;
}

- (UIPopoverArrowDirection)popoverArrowDirectionForPicker:(CommonPicker *)picker
{
    return UIPopoverArrowDirectionDown;
}

#pragma mark CommonPickerDelegate protocol

- (void)pickerOverkayDidTap:(CommonPicker *)picker
{
    @synchronized (self) {
        self.notificationShown = NO;
        if ([self.notificationQueue count] > 0) {
            [self.notificationQueue removeObjectAtIndex:0];
        }
        if (picker.presentFromTop) {
            [UIApplication sharedApplication].keyWindow.windowLevel = UIWindowLevelNormal;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:CommonNotificationDidHide object:nil];
    }
}

@end
