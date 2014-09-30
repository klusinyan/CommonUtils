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

@property (readwrite, nonatomic, assign) id<CommonPickerDataSource> dataSource;

@property (readwrite, nonatomic, assign) id<CommonPickerDelegate> delegate;

@property (readonly, nonatomic, getter = isVisible) BOOL visible;

@property (readwrite, nonatomic, getter = isToolbarHidden) BOOL toolbarHidden;  //default NO

@property (readwrite, nonatomic, assign) BOOL needsOverlay;                     //default NO

@property (readwrite, nonatomic, assign) CGFloat pickerCornerradius;            //defualt 0

//only iPhone
@property (readwrite, nonatomic, assign) BOOL showAfterOrientationDidChange;

//indepenedly from iDevice call this method to show picker
- (void)showPickerWithCompletion:(void (^)(void))completion;

//indepenedly from iDevice call this method to hide picker
- (void)dismissPickerWithCompletion:(void (^)(void))completion;

@end

@protocol CommonPickerDataSource <NSObject>

@required
- (id)pickerContent;

@optional
//if not specified the defualt value is: (iPhone) ? self.target.view.frame.size.width : 320.0f;
- (CGFloat)pickerWidth;

//if not specified the default value is: 260.0f
- (CGFloat)pickerHeight;

//implement this method to provide the custom toolbar
- (id)pickerToolbar;

//this value becomes mandatory when custom toolbar is proveded by at "pickerToolbar"
- (CGFloat)pickerToolbarHeight;

//default is nil
- (NSString *)pickerToolbarTitle;

//if not specified the default value is UIPopoverArrowDirectionAny
- (UIPopoverArrowDirection)pickerArrowDirection;

@end

@protocol CommonPickerDelegate <NSObject>

@optional
- (void)cancelActionCallback:(id)sender;

- (void)doneActionCallback:(id)sender;

@end