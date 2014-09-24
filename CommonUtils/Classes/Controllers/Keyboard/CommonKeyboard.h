//  Created by Karen Lusinyan on 18/09/14.
//  Copyright (c) 2014 Karen Lusinyan. All rights reserved.

@protocol CommonKeyboardDelegate;
@protocol CommonKeyboardDataSource;

@interface CommonKeyboard : NSObject

- (instancetype)initWithTarget:(UIScrollView *)target;

+ (void)registerResponders:(NSArray *)responders;

+ (void)unregisterResponders:(NSArray *)responders;

+ (void)registerResponder:(id)responder;

+ (void)unregisterResponder:(id)responder;

@property (readwrite, nonatomic, assign) id<CommonKeyboardDelegate> delegate;
@property (readwrite, nonatomic, assign) id<CommonKeyboardDataSource> dataSource;

@end

@protocol CommonKeyboardDelegate <NSObject>

@optional
- (void)keyboardDidShowWithResponder:(id)responder;

- (void)keyboardWillHideWithResponder:(id)responder;

@end

@protocol CommonKeyboardDataSource <NSObject>

@optional
//provide active view
//if activeView is not provided you can register
//by using registerResponders: for betch registrations
//or registerResponder: for single responder registration
- (UIView *)activeView;

//offset (not needed)
- (CGFloat)offset;

@end
