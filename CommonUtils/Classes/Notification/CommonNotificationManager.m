//  Created by Karen Lusinyan on 09/10/16.

#import "CommonNotificationManager.h"
#import "CommonNotificationView.h"
#import "CommonPicker.h"
#import "CommonSerilizer.h"
#import "DirectoryUtils.h"

#define keyCommonNotificationQueue @"keyCommonNotificationQueue"

NSString * const CommonNotificationDidShown = @"CommonNotificationDidShown";
NSString * const CommonNotificationDidHide  = @"CommonNotificationDidHide";
NSString * const CommonNotificationDidTap   = @"CommonNotificationDidTap";

@interface CommonNotification ()

@property (readwrite, nonatomic, strong) NSString *identifier;
@property (readwrite, nonatomic, strong) NSDate *creationDate;
@property (readwrite, nonatomic, strong) NSString *alertBody;
@property (readwrite, nonatomic, strong) NSString *alertMessage;
@property (readwrite, nonatomic, strong) NSString *alertAction;
@property (readwrite, nonatomic, strong) NSDate *fireDate;
@property (readwrite, nonatomic) CommonNotificationPriority priority;
@property (nonatomic) UIWindowLevel currentWindowLevel;

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
        self.presentFromTop = YES;
        self.checkNotificationsTimeInterval = 1.0;
        self.notificationHeight = 120.0;
        self.blurEffectStlye = UIBlurEffectStyleExtraLight;
        self.tappableOverlay = NO;
    }
    return self;
}

- (void)cleanFiredNotifications
{
    NSMutableArray *notifications = [[CommonSerilizer loadObjectForKey:keyCommonNotificationQueue] mutableCopy];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.fireDate <= %@", [NSDate date]];
    NSArray *firedNotifications = [notifications filteredArrayUsingPredicate:predicate];
    [notifications removeObjectsInArray:firedNotifications];
    [CommonSerilizer saveObject:notifications forKey:keyCommonNotificationQueue];
}

- (void)manageLifeCycle
{
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification
                                                      object:nil
                                                       queue:[NSOperationQueue currentQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      self.rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                                                  }];
    
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

- (void)startNotificationDispatcher
{
    if (self.notificationDispatcher == nil) {
        self.notificationDispatcher = [NSTimer scheduledTimerWithTimeInterval:self.checkNotificationsTimeInterval
                                                                       target:self
                                                                     selector:@selector(dispatchNotifications:)
                                                                     userInfo:nil
                                                                      repeats:YES];
    }
}

+ (CommonNotificationManager *)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] initOnce];
        [_sharedObject cleanFiredNotifications];
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
        notification.identifier = [NSString stringWithFormat:@"%@", [self progressiveID]];
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

- (void)cancelAllNotifications
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

- (CGFloat)viewHeight:(UIView *)view
{
    [view layoutIfNeeded];
    return [view systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
}

#pragma mark - getter/setter

- (void)setCheckNotificationsTimeInterval:(NSTimeInterval)checkNotificationsTimeInterval
{
    _checkNotificationsTimeInterval = checkNotificationsTimeInterval;

    if (checkNotificationsTimeInterval > 0) {
        [self.notificationDispatcher invalidate], self.notificationDispatcher = nil;
        [self startNotificationDispatcher];
    }
}

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
    commonPicker.tappableOverlay = self.tappableOverlay;
    commonPicker.bounceEnabled = YES;
    commonPicker.presentFromTop = self.presentFromTop;
    commonPicker.applyBlurEffect = YES;
    commonPicker.notificationMode = YES;
    commonPicker.blurEffectStyle = self.blurEffectStlye;
    commonPicker.pickerCornerradius = 10.0;
    //commonPicker.dynamicContentHeight = YES;
    
    CommonNotificationView *contentView = (CommonNotificationView *)[self loadNibForClass:NSClassFromString(@"CommonNotificationView")
                                                                                  atIndex:0];
    contentView.presentFromTop = self.presentFromTop;
    contentView.imageIcon = self.imageIcon;
    contentView.alertBody = notification.alertBody;
    contentView.alertMessage = notification.alertMessage;
    commonPicker.contentView = contentView;
    
    // unusual case: notification.alertMessage
    //contentView.alertMessage = @"Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate vel";
    //contentView.alertMessage = @"Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, ";

    return commonPicker;
}

- (void)dispatchNotifications:(NSTimer *)timer
{
    @synchronized (self) {
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            if (self.notificationShown) {
                return;
            }
            if ([self.notificationQueue count] > 0) {
                __block CommonNotification *notification = self.notificationQueue[0];
                notification.currentWindowLevel = [UIApplication sharedApplication].keyWindow.windowLevel;
                if (notification.fireDate != nil && [[NSDate date] timeIntervalSinceDate:notification.fireDate] > 0) {
                    [self.notificationQueue removeObjectAtIndex:0];
                    [CommonSerilizer saveObject:self.notificationQueue forKey:keyCommonNotificationQueue];
                    DebugLog(@"notificationQueue.count %@", @([self.notificationQueue count]));
                    return;
                }
                UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                if (self.rootViewController != rootViewController) {
                    return;
                }
                CommonPicker *commonPicker = [self createNotification:notification];
                commonPicker.target = self.rootViewController;
                commonPicker.sender = self.rootViewController.view;
                commonPicker.relativeSuperview = nil;
                                
                ///////////////////////////////////////////////////////////////
                ///////////////////// SHOW NOTIFICATION ///////////////////////
                
                CommonNotificationView *contentView = (CommonNotificationView *)commonPicker.contentView;
                if ([self.notificationQueue count] > 0) {
                    self.notificationShown = YES;
                    if (commonPicker.presentFromTop) {
                        [UIApplication sharedApplication].keyWindow.windowLevel = UIWindowLevelAlert;
                    }
                    [commonPicker showPickerWithCompletion:^{
                        [self postNotificationName:CommonNotificationDidShown object:self.notificationQueue[0]];
                        
                        ///////////////////////////////////////////////////////////////
                        /////////////////// NOTIFICATION TAP ACTION ///////////////////
                        
                        contentView.alertAction = ^(void){
                            [commonPicker dismissPickerWithCompletion:^{
                                if ([self.notificationQueue count] > 0) {
                                    [self postNotificationName:CommonNotificationDidTap object:self.notificationQueue[0]];
                                    [self removePresentedNotification];
                                    DebugLog(@"notificaton tapped");
                                }
                            }];
                        };
                        
                        /////////////////// NOTIFICATION TAP ACTION ///////////////////
                        ///////////////////////////////////////////////////////////////
                    }];
                }
                
                ///////////////////// SHOW NOTIFICATION ///////////////////////
                ///////////////////////////////////////////////////////////////
                
                ///////////////////////////////////////////////////////////////
                ///////////////// DRAG DOWN/UP NOTIFICATION ///////////////////
                
                commonPicker.expectedHeight = [self viewHeight:contentView];
                if (commonPicker.expectedHeight > self.notificationHeight) {
                    commonPicker.expectedHeight = [self viewHeight:contentView];
                    contentView.setExtandable = YES;
                    contentView.dragDown = ^(void) {
                        [commonPicker dragDown:^{
                            if (self.presentFromTop) {
                                DebugLog(@"notification dragged down");
                            }
                            else {
                                DebugLog(@"notification dragged up");
                            }
                        }];
                    };
                    contentView.dragUp = ^(void) {
                        [commonPicker dragUp:^{
                            if (self.presentFromTop) {
                                DebugLog(@"notification dragged up");
                            }
                            else {
                                DebugLog(@"notification dragged down");
                            }
                        }];
                    };
                }
                
                ///////////////// DRAG DOWN/UP NOTIFICATION ///////////////////
                ///////////////////////////////////////////////////////////////
                
                ///////////////////////////////////////////////////////////////
                //////////////// DRAG TO DISMISS NOTIFICATION /////////////////
                
                contentView.dragToDimiss = ^(void) {
                    [commonPicker dismissPickerWithCompletion:^{
                        if ([self.notificationQueue count] > 0) {
                            [self postNotificationName:CommonNotificationDidHide object:self.notificationQueue[0]];
                            [self removePresentedNotification];
                            DebugLog(@"notification dragged to dismiss");
                        }
                    }];
                };
                
                //////////////// DRAG TO DISMISS NOTIFICATION /////////////////
                ///////////////////////////////////////////////////////////////
            }
        }
    }
}

- (void)postNotificationName:(NSString *)name object:(id)anObject
{
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:anObject];
}

- (void)removePresentedNotification
{
    @synchronized (self) {
        self.notificationShown = NO;
        if ([self.notificationQueue count] > 0) {
            if (self.presentFromTop) {
                [UIApplication sharedApplication].keyWindow.windowLevel = [self.notificationQueue[0] currentWindowLevel];
            }
            [self.notificationQueue removeObjectAtIndex:0];
            [CommonSerilizer saveObject:self.notificationQueue forKey:keyCommonNotificationQueue];
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
    return self.notificationHeight;
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
    ///////////////////////////////////////////////////////////////
    ///////////////////// HIDE NOTIFICATION ///////////////////////

    @synchronized (self) {
        if ([self.notificationQueue count] > 0) {
            [self postNotificationName:CommonNotificationDidHide object:self.notificationQueue[0]];
            [self removePresentedNotification];
            DebugLog(@"notification overlay tapped");
        }
    }
    
    ///////////////////// HIDE NOTIFICATION ///////////////////////
    ///////////////////////////////////////////////////////////////
}

@end
