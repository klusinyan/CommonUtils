//  Created by Karen Lusinyan on 18/09/14.
//  Copyright (c) 2014 Karen Lusinyan. All rights reserved.

@protocol CommonKeyboardDelegate;
@protocol CommonKeyboardDataSource;

@interface CommonKeyboard : NSObject

- (instancetype)initWithTarget:(UIScrollView *)target;

+ (void)registerClass:(Class)aClass withResponders:(NSArray *)responders;

+ (void)unregisterRespondersForClass:(Class)aClass;

@property (readwrite, nonatomic, assign) id<CommonKeyboardDelegate> delegate;

@property (readwrite, nonatomic, assign) id<CommonKeyboardDataSource> dataSource;

@property (readonly, nonatomic, getter = isVisible) BOOL visible;

@end

@protocol CommonKeyboardDelegate <NSObject>

@optional
@optional
- (void)keyboard:(CommonKeyboard *)keyboard willShowWithResponder:(id)responder;

- (void)keyboard:(CommonKeyboard *)keyboard didShowWithResponder:(id)responder;

- (void)keyboard:(CommonKeyboard *)keyboard willHideWithResponder:(id)responder;

- (void)keyboard:(CommonKeyboard *)keyboard didHideWithResponder:(id)responder;

@end

@protocol CommonKeyboardDataSource <NSObject>

@optional
- (CGFloat)offsetForKeyboard:(CommonKeyboard *)keyboard;

@end
