//  Created by Karen Lusinyan on 18/09/14.
//  Copyright (c) 2014 Karen Lusinyan. All rights reserved.

@protocol CommonPickerDataSource;
@protocol CommonPickerDelegate;

@interface CommonPicker : NSObject

/*----------------------------------------------------------------------*/
//target: viewcontoller that present the picker
//sender: should not be nil, supported types are UIBarButtonItem, UIView
//relativeSuperview: the relative superview of sender: could be nil
/*----------------------------------------------------------------------*/
- (instancetype)initWithTarget:(UIViewController *)target
                        sender:(id)sender
             relativeSuperview:(UIView *)relativeSuperview;

@property (readonly, nonatomic, assign) UIViewController *target;

@property (readwrite, nonatomic, assign) id<CommonPickerDataSource> dataSource;

@property (readwrite, nonatomic, assign) id<CommonPickerDelegate> delegate;

@property (readonly, nonatomic, getter=isVisible) BOOL visible;

@property (readwrite, nonatomic, getter=isToolbarHidden) BOOL toolbarHidden;    // default NO

@property (readwrite, nonatomic, assign) BOOL presentFromTop;                   // defualt NO

@property (readwrite, nonatomic, assign) BOOL needsOverlay;                     // default NO

@property (readwrite, nonatomic, assign) BOOL bounceEnabled;                    // default NO

@property (readwrite, nonatomic, assign) BOOL applyBlurEffect;                  // default NO

@property (readwrite, nonatomic, assign) UIBlurEffectStyle blurEffectStyle;     // default UIBlurEffectStyleLight

@property (readwrite, nonatomic, assign) NSTimeInterval bounceDuration;         // default 0.1

@property (readwrite, nonatomic, assign) CGFloat bouncePosition;                // default 20.0

@property (readwrite, nonatomic, assign) CGFloat pickerCornerradius;            // defualt 0

//only iPhone
@property (readwrite, nonatomic, assign) BOOL showAfterOrientationDidChange;

//indepenedly from iDevice call this method to show picker
- (void)showPickerWithCompletion:(void (^)(void))completion;

//indepenedly from iDevice call this method to hide picker
- (void)dismissPickerWithCompletion:(void (^)(void))completion;

@end

@protocol CommonPickerDataSource <NSObject>

@required
- (id)contentForPicker:(CommonPicker *)picker;

@optional
//if not specified the defualt value is: (iPhone) ? self.target.view.frame.size.width : 320.0f;
- (CGFloat)widthForPicker:(CommonPicker *)picker;

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
