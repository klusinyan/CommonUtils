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
- (void)commonKeyboard:(CommonKeyboard *)commonKeyboard willShowWithResponder:(id)responder;

- (void)commonKeyboard:(CommonKeyboard *)commonKeyboard didShowWithResponder:(id)responder;

- (void)commonKeyboard:(CommonKeyboard *)commonKeyboard willHideWithResponder:(id)responder;

- (void)commonKeyboard:(CommonKeyboard *)commonKeyboard didHideWithResponder:(id)responder;

@end

@protocol CommonKeyboardDataSource <NSObject>

@optional
- (CGFloat)offsetForKeyboard:(CommonKeyboard *)keyboard;

@end
