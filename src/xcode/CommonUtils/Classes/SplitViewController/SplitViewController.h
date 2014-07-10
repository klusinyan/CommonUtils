//  Created by Adrian Bardasu on 9/11/11.
//  Modified by Karen Lusinyan on 5/14/13.
#pragma mark version - 1.0.2

#import <UIKit/UIKit.h>

extern NSString * const NotificationMenuWillStartOpening;
extern NSString * const NotificationMenuWillStartClosing;
extern NSString * const NotificationMenuDidFinishOpening;
extern NSString * const NotificationMenuDidFinishClosing;

typedef enum {
    MenuStateOpen,
    MenuStateClosed,
} MenuState;

typedef enum {
    MenuModeShownAlways,
    MenuModeHiddenInPortrait,
    MenuModeHidden,
} MenuMode;

typedef enum {
    RevealButtonStateOpenShown,
    RevealButtonStateOpenHidden,
    RevealButtonStateCloseShown,
    RevealButtonStateCloseHidden,
}RevealButtonState;

@interface SplitViewController : UIViewController

@property (readwrite, nonatomic, assign) BOOL shadowEnabled;                        // default YES

@property (readwrite, nonatomic, assign) BOOL menuShadow;                           // default YES

@property (readwrite, nonatomic, assign) BOOL resizeDetail;                         // default NO only in MenuModeHiddenInPortrait

@property (readwrite, nonatomic, assign) CGFloat menuWidth;                         // default 320

@property (readwrite, nonatomic, assign) CGFloat menuOverlay;                       // default 3

@property (readwrite, nonatomic, assign) CGFloat shadowRadius;                      // default 10.0

@property (readwrite, nonatomic, assign) CGFloat shadowOpacity;                     // default 0.75

@property (readwrite, nonatomic, retain) UIColor *shadowColor;                      // default [UIColor blackColor]

@property (readwrite, nonatomic, assign) NSTimeInterval openningAnimationDuration;  // default 0.3

@property (readwrite ,nonatomic, assign) NSTimeInterval closingAnimationDuration;   // default 0.1

@property (readwrite ,nonatomic, assign) NSString *openningTimingFunctionName;      // default kCAMediaTimingFunctionEaseOut

@property (readwrite ,nonatomic, assign) NSString *closingTimingFunctionName;       // default kCAMediaTimingFunctionEaseOut

@property (readwrite, nonatomic, assign) MenuState menuState;

@property (readwrite, nonatomic, assign) MenuMode menuMode;

@property (readwrite, nonatomic, retain) UIImage *imageCloseMenu;

@property (readwrite, nonatomic, retain) UIImage *imageOpenMenu;

@property (readonly, nonatomic, retain) UINavigationController *masterNavigationController;

@property (readonly, nonatomic, retain) UINavigationController *detailNavigationController;

- (void) addMasterController:(UIViewController*)controller animated:(BOOL)animated;

- (void) addDetailController:(UIViewController*)controller animated:(BOOL)animated;

- (void) addChildToMasterController:(UIViewController *)childController;

- (void) addChildToDetailController:(UIViewController *)childController;

- (void) removeChildFromParentController:(UIViewController *)childController;

- (void) openMenu:(BOOL)animated;

- (void) closeMenu:(BOOL)animated;

- (void) changeRevealButtonState:(RevealButtonState)state;

@end
