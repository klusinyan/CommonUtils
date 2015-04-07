//  Created by Karen Lusinyan on 16/07/14.

typedef void(^ShowCompletionHandler)(void);
typedef void(^HideCompletionHandler)(void);

/**
 Activity indicator type.
 */
typedef NS_ENUM(NSInteger, CommonProgressActivityIndicatorViewStyle) {
    /** A normal activity indicator view. About 78 * 78 in size */
    CommonProgressActivityIndicatorViewStyleNormal,
    /** A normal activity indicator view. About 37 * 37 in size */
    CommonProgressActivityIndicatorViewStyleSmall,
    /** A large activity indicator view. About 157 * 157 in size. */
    CommonProgressActivityIndicatorViewStyleLarge,
};

/**
 A simple activity indicator view. You can customize it's appearance with images.
 */
@interface CommonProgress : UIView

///-----------------
/// @name Properties
///-----------------

/**
 The background image.
 
 Should use the same size as the indicator view's for performance issue.
 */
@property (nonatomic, strong) UIImage *backgroundImage UI_APPEARANCE_SELECTOR;

/**
 The indicator image which may be applied with a rotarion animation.
 
 Usually, it's a circular progress bar. Should use the same size as the indicator view's.
 */
@property (nonatomic, strong) UIImage *indicatorImage UI_APPEARANCE_SELECTOR;

/**
 It determines whether the view will be hidden when the animation was stopped.
 
 The view sets its `hidden` property to accomplish it.
 */
@property (nonatomic, assign) BOOL hidesWhenStopped;

/**
 The duration time it takes the indicator to finish a 360-degree clockwise rotation.
 */
@property (nonatomic, assign) CFTimeInterval fullRotationDuration UI_APPEARANCE_SELECTOR;

/**
 The overall progress of the indicator. The acceptable value is `0.0f` to `1.0f`.
 
 The default value is 0.
 
 @warning For performance issue, you'd better control your invoking frequency during a period of time.
 */
@property (nonatomic, assign) CGFloat progress;

/**
 The minimal progress unit.
 
 The indicator will only be rotated when the delta value of the progress is larger than the unit value. The default value is `0.01f`.
 */
@property (nonatomic, assign) CGFloat minProgressUnit UI_APPEARANCE_SELECTOR;

/**
 The activity indicator view style. Default is `TYMActivityIndicatorViewStyleNormal`.
 */
@property (nonatomic, assign) CommonProgressActivityIndicatorViewStyle activityIndicatorViewStyle;

/**
 The network activity indicator should be visible or not while progress is animating
 */
@property (readwrite, nonatomic, getter = isNetworkActivityIndicatorVisible) BOOL networkActivityIndicatorVisible;

/**
 Background image color. Default is GRAY
 */
@property (readwrite, nonatomic, strong) UIColor *backgroundImageColor;

/**
 Indicator image color. Default is SKYBLUE
 */
@property (readwrite, nonatomic, strong) UIColor *indicatorImageColor;

///-------------------
/// @name Initializing
///-------------------

/**
 Initialize a indicator view with built-in sizes and resources according to the specific style.
 */
- (id)initWithActivityIndicatorStyle:(CommonProgressActivityIndicatorViewStyle)style;

///-----------------------------
/// @name Controlling Animations
///-----------------------------

/**
 Start animating. 360-degree clockwise rotation. Repeated forever.
 */
- (void)startAnimating;

/**
 Stop animating.
 */
- (void)stopAnimating;

/**
 Whether the indicator is animating.
 */
- (BOOL)isAnimating;

///---------------------------
/// @name Desired Initializing
///---------------------------

/**
 Shared instance to the specific style.
 */
+ (instancetype)sharedProgress;

/**
 Shows shared common prpgress, with default CommonProgressActivityIndicatorViewStyleNormal
 */
+ (void)showWithTarget:(id)target completion:(ShowCompletionHandler)completion;

/**
 Hides shared common prpgress
 */
+ (void)hideWithCompletion:(HideCompletionHandler)completion;

@end
