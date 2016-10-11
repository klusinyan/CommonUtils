//  Created by Karen Lusinyan on 09/10/16.

#import "CommonNotificationManager.h"
#import "CommonNotificationView.h"
#import "CommonPicker.h"
#import "CommonSerilizer.h"
#import "DirectoryUtils.h"

#define keyCommonNotificationQueue @"keyCommonNotificationQueue"

NSString * const CommonNotificationDidShown = @"CommonNotificationDidShown";
NSString * const CommonNotificationDidHide  = @"CommonNotificationDidHide";

@interface CommonNotification ()

@property (readwrite, nonatomic, strong) NSString *identifier;
@property (readwrite, nonatomic, strong) NSDate *creationDate;
@property (readwrite, nonatomic, strong) NSString *alertBody;
@property (readwrite, nonatomic, strong) NSString *alertMessage;
@property (readwrite, nonatomic, strong) NSString *alertAction;
@property (readwrite, nonatomic, strong) NSDate *fireDate;
@property (readwrite, nonatomic) CommonNotificationPriority priority;

@end

@implementation CommonNotification

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self){
        self.identifier = [decoder decodeObjectForKey:@"identifier"];
        self.creationDate = [decoder decodeObjectForKey:@"creationDate"];
        self.alertBody = [decoder decodeObjectForKey:@"alertBody"];
        self.alertMessage = [decoder decodeObjectForKey:@"alertMessage"];
        self.alertAction = [decoder decodeObjectForKey:@"alertAction"];
        self.fireDate = [decoder decodeObjectForKey:@"fireDate"];
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
    [encoder encodeObject:self.fireDate forKey:@"fireDate"];
    [encoder encodeInteger:self.priority forKey:@"priority"];
}

@end

@interface CommonNotificationManager ()
<
CommonPickerDataSource,
CommonPickerDelegate
>

@property (nonatomic, strong) NSMutableArray *notificationQueue;
@property (nonatomic, assign) NSTimer *notificationDispatcher;
@property (nonatomic) BOOL notificationShown;

@end

@implementation CommonNotificationManager

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

- (void)manageLifeCycle
{
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification
                                                      object:nil
                                                       queue:[NSOperationQueue currentQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      [self startNotificationDispatcher];
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      [self.notificationDispatcher invalidate], self.notificationDispatcher = nil;
                                                  }];
}

+ (CommonNotificationManager *)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] initOnce];
        [_sharedObject manageLifeCycle];
        [_sharedObject startNotificationDispatcher];
    });
    return _sharedObject;
}

- (void)addNotificationWithAlertBody:(NSString *)alertBody
                        alertMessage:(NSString *)alertMessage
                        alertAction:(NSString *)alertAction
                            fireDate:(NSDate *)fireDate
                            priority:(CommonNotificationPriority)priority
{
    @synchronized (self) {
        CommonNotification *notification = [CommonNotification new];
        notification.identifier = [self progressiveID];
        notification.creationDate = [NSDate date];
        notification.alertBody = alertBody;
        notification.alertMessage = alertMessage;
        notification.alertAction = alertAction;
        notification.fireDate = fireDate;
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
        CommonNotification *notificationObject = [self.notificationQueue lastObject];
        return @([notificationObject.identifier integerValue] + 1);
    }
}

- (UIView *)loadNibForClass:(Class)aClass atIndex:(NSInteger)index
{
    return [[[DirectoryUtils bundleWithName:kCommonBundleName] loadNibNamed:NSStringFromClass(aClass)
                                                                      owner:self
                                                                    options:nil] objectAtIndex:index];
}

- (void)startNotificationDispatcher
{
    if (self.notificationDispatcher == nil) {
        self.notificationDispatcher = [NSTimer scheduledTimerWithTimeInterval:1
                                                                       target:self
                                                                     selector:@selector(dispatchNotifications:)
                                                                     userInfo:nil
                                                                      repeats:YES];
    }
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

- (CommonPicker *)createNotification:(CommonNotification *)notification
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
    contentView.alertBody = notification.alertBody;
    contentView.alertMessage = notification.alertMessage;
    commonPicker.contentView = contentView;
    
    return commonPicker;
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
            rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
            if ([self.notificationQueue count] > 0) {
                __block CommonNotification *notification = self.notificationQueue[0];
                if (notification.fireDate != nil && [[NSDate date] timeIntervalSinceDate:notification.fireDate] > 0) {
                    [self.notificationQueue removeObjectAtIndex:0];
                    [CommonSerilizer saveObject:self.notificationQueue forKey:keyCommonNotificationQueue];
                    DebugLog(@"notificationQueue.count %@", @([self.notificationQueue count]));
                    return;
                }
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
                        [[NSNotificationCenter defaultCenter] postNotificationName:CommonNotificationDidShown object:notification];
                        
                        ///////////////////////////////////////////////////////////////
                        /////////////////// NOTIFICATION TAP ACTION ///////////////////
                        
                        CommonNotificationView *contentView = commonPicker.contentView;
                        contentView.alertAction = ^(void){
                            [commonPicker dismissPickerWithCompletion:^{
                                self.notificationShown = NO;
                                if ([self.notificationQueue count] > 0) {
                                    [self.notificationQueue removeObjectAtIndex:0];
                                    [CommonSerilizer saveObject:self.notificationQueue forKey:keyCommonNotificationQueue];
                                }
                                if (commonPicker.presentFromTop) {
                                    [UIApplication sharedApplication].keyWindow.windowLevel = UIWindowLevelNormal;
                                }
                                [[NSNotificationCenter defaultCenter] postNotificationName:CommonNotificationDidHide object:notification];
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
