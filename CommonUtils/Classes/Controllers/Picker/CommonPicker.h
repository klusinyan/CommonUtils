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
             relativeSuperview:(id)relativeSuperview
                     withTitle:(NSString *)title;

@property (readwrite, nonatomic, assign) id<CommonPickerDataSource> dataSource;

@property (readwrite, nonatomic, assign) id<CommonPickerDelegate> delegate;

@property (readonly, nonatomic, getter = isVisible) BOOL visible;

@property (readwrite, nonatomic, assign) BOOL showToolbar;

@property (readwrite, nonatomic, assign) BOOL needsOverlay;

@property (readwrite, nonatomic, assign) BOOL shouldChangeOrientation;

@property (readwrite, nonatomic, assign) CGFloat pickerWidth;

@property (readwrite, nonatomic, assign) CGFloat pickerHeight;

@property (readwrite, nonatomic, assign) CGFloat pickerCornerradius;

@property (readwrite, nonatomic, strong) UIColor *toolbarBarTintColor;

@property (readwrite, nonatomic, strong) UIColor *toolbarTintColor;

@property (readwrite, nonatomic, strong) UIColor *titleColor;

@property (readwrite, nonatomic, assign) UIPopoverArrowDirection popoverArrowDirection;

- (void)showPickerWithCompletion:(void (^)(void))completion;

- (void)dismissPickerWithCompletion:(void (^)(void))completion;

@end

@protocol CommonPickerDataSource <NSObject>

@required
- (id)pickerContent;

@end

@protocol CommonPickerDelegate <NSObject>

@optional
- (void)pickerDidCancelShowing;

- (void)pickerDidFinishShowing;

@end