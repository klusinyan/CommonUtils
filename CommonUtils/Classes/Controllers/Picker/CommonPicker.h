//  Created by Karen Lusinyan on 18/09/14.
//  Copyright (c) 2014 Karen Lusinyan. All rights reserved.

@protocol CommonPickerDataSource;
@protocol CommonPickerDelegate;

@interface CommonPicker : NSObject

//sender and relativeSuperview needs only for iPad
//to postion popoverController correctly
//these values are not considered for iPhone
- (instancetype)initWithTarget:(id)target
                        sender:(id)sender
             relativeSuperview:(id)relativeSuperview;

@property (readwrite, nonatomic, assign) id<CommonPickerDataSource> dataSource;

@property (readwrite, nonatomic, assign) id<CommonPickerDelegate> delegate;

@property (readonly, nonatomic, getter = isVisible) BOOL visible;

@property (readwrite, nonatomic, assign) BOOL toolbarHidden;

@property (readwrite, nonatomic, assign) BOOL needsOverlay;

@property (readwrite, nonatomic, assign) BOOL shouldChangeOrientation;

@property (readwrite, nonatomic, assign) CGFloat pickerWidth;

@property (readwrite, nonatomic, assign) CGFloat pickerHeight;

@property (readwrite, nonatomic, assign) CGFloat pickerCornerradius;

@property (readwrite, nonatomic, assign) UIPopoverArrowDirection popoverArrowDirection;

- (void)showPickerWithCompletion:(void (^)(void))completion;

- (void)dismissPickerWithCompletion:(void (^)(void))completion;

//only iPad: changes popover size dynamically
- (void)reloadPickerWithCompletion:(void(^)(void))completion;

@end

@protocol CommonPickerDataSource <NSObject>

@required
- (id)pickerContent;

@optional
//if nil or not implemented: returns default toolbar
- (id)pickerToolbar;

//if toolbarHeight is specified with the value <= 0 then toolbar is not visualzied
//this method has no effect if the default is shown
- (CGFloat)toolbarHeight;

- (NSString *)toolbarTitle;

@end

@protocol CommonPickerDelegate <NSObject>

@optional
- (void)cancelActionCallback:(id)sender;

- (void)doneActionCallback:(id)sender;

@end