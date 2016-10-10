//  Created by Karen Lusinyan on 09/10/16.

#import "CommonNotification.h"
#import "CommonNotificationView.h"
#import "CommonPicker.h"
#import "CommonSerilizer.h"
#import "DirectoryUtils.h"

#define keyCommonNotificationQueue @"keyCommonNotificationQueue"

NSString * const CommonNotificationDidShown = @"CommonNotificationDidShown";
NSString * const CommonNotificationDidHide  = @"CommonNotificationDidHide";

typedef void(^AlertAction)(void);

@interface CommonNotificationObject : NSObject <NSCoding>

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, copy) NSString *alertBody;
@property (nonatomic, copy) NSString *alertMessage;
@property (nonatomic, copy) AlertAction alertAction;
@property (nonatomic) CommonNotificationPriority priority;

@end

@implementation CommonNotificationObject

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self){
        self.identifier = [decoder decodeObjectForKey:@"identifier"];
        self.creationDate = [decoder decodeObjectForKey:@"creationDate"];
        self.alertBody = [decoder decodeObjectForKey:@"alertBody"];
        self.alertMessage = [decoder decodeObjectForKey:@"alertMessage"];
        self.alertAction = [decoder decodeObjectForKey:@"alertAction"];
        self.priority = [decoder decodeIntegerForKey:@"priority"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.identifier forKey:@"identifier"];
    [encoder encodeObject:self.creationDate forKey:@"creationDate"];
    [encoder encodeObject:self.alertBody forKey:@"alertBody"];
    [encoder encodeObject:self.alertMessage forKey:@"alertMessage"];
    [encoder encodeObject:self.alertAction forKey:@"alertAction"];
    [encoder encodeInteger:self.priority forKey:@"priority"];
}

@end

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

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self){
        self.notificationQueue = [decoder decodeObjectForKey:keyCommonNotificationQueue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.notificationQueue forKey:keyCommonNotificationQueue];
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
        CommonNotificationObject *notification = [CommonNotificationObject new];
        notification.identifier = [self progressiveID];
        notification.creationDate = [NSDate date];
        notification.alertBody = alertBody;
        notification.alertMessage = alertMessage;
        notification.alertAction = alertAction;
        notification.priority = priority;
        
        if (notification.priority == CommonNotificationPriorityHigh && [self.notificationQueue count] > 1) {
            [self.notificationQueue insertObject:notification atIndex:1];
        }
        else {
            [self.notificationQueue addObject:notification];
        }
        
        [CommonSerilizer saveObject:self.notificationQueue forKey:keyCommonNotificationQueue];
        
        [self dispatchNotifications:self.notificationDispatcher];
    }
}

- (void)cancelAllNotification
{
    [self.notificationQueue removeAllObjects];
    
    [CommonSerilizer saveObject:self.notificationQueue forKey:keyCommonNotificationQueue];
}

#pragma mark - private methods

#pragma mark - utils

// get progressive identifier
// start from 1 if buffer is empty
- (NSNumber *)progressiveID
{
    if ([self.notificationQueue count] == 0) {
        return @(1);
    }
    else {
        CommonNotificationObject *notificationObject = [self.notificationQueue lastObject];
        return @([notificationObject.identifier integerValue] + 1);
    }
}

- (UIView *)loadNibForClass:(Class)aClass atIndex:(NSInteger)index
{
    return [[[DirectoryUtils bundleWithName:kCommonBundleName] loadNibNamed:NSStringFromClass(aClass)
                                                                      owner:self
                                                                    options:nil] objectAtIndex:index];
}

#pragma mark - getter/setter

- (NSMutableArray *)notificationQueue
{
    if (_notificationQueue == nil) {
        _notificationQueue = [CommonSerilizer loadObjectForKey:keyCommonNotificationQueue];
        if (_notificationQueue == nil) {
            _notificationQueue = [NSMutableArray array];
        }
    }
    return _notificationQueue;
}

- (CommonPicker *)createNotification:(CommonNotificationObject *)obj
{
    CommonPicker *commonPicker = [CommonPicker new];
    commonPicker.dataSource = self;
    commonPicker.delegate = self;
    commonPicker.toolbarHidden = YES;
    commonPicker.needsOverlay = YES;
    commonPicker.bounceEnabled = YES;
    commonPicker.presentFromTop = self.presentOnTop;
    commonPicker.applyBlurEffect = YES;
    commonPicker.notificationMode = YES;
    commonPicker.blurEffectStyle = UIBlurEffectStyleDark;
    commonPicker.pickerCornerradius = 10.0;
    
    CommonNotificationView *contentView = [self loadNibForClass:NSClassFromString(@"CommonNotificationView") atIndex:0];
    contentView.imageIcon = self.imageIcon;
    contentView.alertBody = obj.alertBody;
    contentView.alertMessage = obj.alertMessage;
    contentView.alertAction = obj.alertAction;
    commonPicker.contentView = contentView;
    
    return commonPicker;
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
                __block CommonNotificationObject *notification = self.notificationQueue[0];
                CommonPicker *commonPicker = [self createNotification:notification];
                commonPicker.target = rootViewController;
                commonPicker.sender = rootViewController.view;
                commonPicker.relativeSuperview = nil;
                
                ///////////////////////////////////////////////////////////////
                ///////////////////// SHOW NOTIFICATION ///////////////////////
                
                if ([self.notificationQueue count] > 0) {
                    self.notificationShown = YES;
                    if (commonPicker.presentFromTop) {
                        [UIApplication sharedApplication].keyWindow.windowLevel = UIWindowLevelAlert;
                    }
                    [commonPicker showPickerWithCompletion:^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:CommonNotificationDidShown object:nil];
                        
                        ///////////////////////////////////////////////////////////////
                        /////////////////// NOTIFICATION TAP ACTION ///////////////////
                        
                        CommonNotificationView *contentView = commonPicker.contentView;
                        contentView.alertAction = ^(void){
                            [commonPicker dismissPickerWithCompletion:^{
                                self.notificationShown = NO;
                                if ([self.notificationQueue count] > 0) {
                                    [self.notificationQueue removeObjectAtIndex:0];
                                }
                                if (commonPicker.presentFromTop) {
                                    [UIApplication sharedApplication].keyWindow.windowLevel = UIWindowLevelNormal;
                                }
                                [[NSNotificationCenter defaultCenter] postNotificationName:CommonNotificationDidHide object:nil];
                                if (notification.alertAction) notification.alertAction();
                            }];
                        };
                        
                        /////////////////// NOTIFICATION TAP ACTION ///////////////////
                        ///////////////////////////////////////////////////////////////
                    }];
                }
                
                ///////////////////// SHOW NOTIFICATION ///////////////////////
                ///////////////////////////////////////////////////////////////
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
