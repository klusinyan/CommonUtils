//  Created by Karen Lusinyan on 18/09/14.
//  Copyright (c) 2014 Karen Lusinyan. All rights reserved.

@protocol CommonPickerDataSource;
@protocol CommonPickerDelegate;

@interface CommonPicker : NSObject

/*----------------------------------------------------------------------*/
// generic initializer
/*----------------------------------------------------------------------*/
- (id)init;

/*----------------------------------------------------------------------*/
// desicred initializer
/*----------------------------------------------------------------------*/
// target: viewcontoller that present the picker
// sender: should not be nil, supported types are UIBarButtonItem, UIView
// relativeSuperview: the relative superview of sender: could be nil
/*----------------------------------------------------------------------*/
- (id)initWithTarget:(UIViewController *)target
              sender:(id)sender
   relativeSuperview:(UIView *)relativeSuperview;

@property (nonatomic, strong) UIView *window;                       // main window where the picker will be presented, default is keyWindow
    
@property (nonatomic, strong) UIViewController *target;             // invocker: such that controller class
    
@property (nonatomic, strong) id sender;                            // sender: such that button where to present

@property (nonatomic, strong) UIView *relativeSuperview;            // sender's superView

@property (nonatomic, strong) UIView *contentView;                  // used for common notifications

@property (readonly, nonatomic, getter=isVisible) BOOL visible;     // call to check is picker is visibile

@property (nonatomic, getter=isToolbarHidden) BOOL toolbarHidden;   // default NO

@property (nonatomic) BOOL presentFromTop;                          // defualt NO

@property (nonatomic) BOOL notificationMode;                        // default NO

@property (nonatomic) BOOL needsOverlay;                            // default NO

@property (nonatomic) BOOL tappableOverlay;                         // default YES

@property (nonatomic) BOOL bounceEnabled;                           // default NO

@property (nonatomic) BOOL applyBlurEffect;                         // default NO

@property (nonatomic) UIBlurEffectStyle blurEffectStyle;            // default UIBlurEffectStyleLight

@property (nonatomic) NSTimeInterval bounceDuration;                // default 0.1

@property (nonatomic) CGFloat bouncePosition;                       // default 20.0

@property (nonatomic) CGFloat pickerCornerradius;                   // defualt 0.0

@property (nonatomic) CGFloat expectedHeight;                       // defualt 0.0

@property (nonatomic) BOOL dynamicContentHeight;                    // default NO

@property (nonatomic, assign) id<CommonPickerDataSource> dataSource;
    
@property (nonatomic, assign) id<CommonPickerDelegate> delegate;


//indepenedly from iDevice call this method to show picker
- (void)showPickerWithCompletion:(void (^)(void))completion;

//indepenedly from iDevice call this method to hide picker
- (void)dismissPickerWithCompletion:(void (^)(void))completion;

- (void)dragDown:(void(^)(void))completion;
- (void)dragUp:(void(^)(void))completion;

- (void)shrinkUp:(CGFloat)offset animated:(BOOL)animated completion:(void(^)(BOOL finished))completion;
- (void)shrinkDown:(BOOL)animated completion:(void(^)(BOOL finished))completion;

@end

@protocol CommonPickerDataSource <NSObject>

@required
- (id)contentForPicker:(CommonPicker *)picker;

@optional
//if not specified the defualt value is: (iPhone) ? self.target.view.frame.size.width : 320.0f;
- (CGFloat)widthForPicker:(CommonPicker *)picker;

// if specified the width is equal to superview's width * multiplier
- (CGFloat)widthMultiplierForPicker:(CommonPicker *)picker;

//if not specified the defualt value is: (iPhone), default is 0
- (CGFloat)paddingForPicker:(CommonPicker *)picker;

//if not specified the default value is: 260.0f
- (CGFloat)heightForPicker:(CommonPicker *)picker;

//implement this method to provide the custom toolbar
- (id)toolbar:(UIToolbar *)toolbar forPicker:(CommonPicker *)picker;

//this value becomes mandatory when custom toolbar is proveded by at "toolbarForPicker:"
- (CGFloat)toolbarHeightForPicker:(CommonPicker *)picker;

//default nil
- (UILabel *)toolbarTitleLabelForPicker:(CommonPicker *)picker;

//default is nil
- (NSString *)toolbarTitleForPicker:(CommonPicker *)picker;

//defualt is white
- (UIColor *)toolbarTitleColorForPicker:(CommonPicker *)picker;

//if not specified the default value is UIPopoverArrowDirectionAny
- (UIPopoverArrowDirection)popoverArrowDirectionForPicker:(CommonPicker *)picker;

@end

@protocol CommonPickerDelegate <NSObject>

@optional
- (void)picker:(CommonPicker *)picker cancelActionCallback:(id)sender;

- (void)picker:(CommonPicker *)picker doneActionCallback:(id)sender;

- (void)pickerOverkayDidTap:(CommonPicker *)picker;

@end
