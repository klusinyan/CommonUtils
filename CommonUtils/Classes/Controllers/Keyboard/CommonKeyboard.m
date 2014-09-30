//  Created by Karen Lusinyan on 18/09/14.
//  Copyright (c) 2014 Karen Lusinyan. All rights reserved.

#import "CommonKeyboard.h"

static NSMutableDictionary *classResponders = nil;

@interface CommonKeyboard ()
<
UIScrollViewDelegate,
UIGestureRecognizerDelegate
>

@property (readwrite, nonatomic, strong) UIScrollView *scrollView;
@property (readwrite, nonatomic, strong) UIGestureRecognizer *tapGestureRegognizer;

@end

@implementation CommonKeyboard

- (void)dealloc
{
    [self removeObservers];
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ Failed to call init: you should call +commonKeyboard.", NSStringFromClass([self class])] userInfo:nil];
}

- (instancetype)initWithTarget:(UIScrollView *)target
{
    self = [super init];
    if (self) {
        
        self.scrollView = target;
        
        [self addObservers];
        [self configureScrollView];
    }
    
    return self;
}

+ (void)registerClass:(Class)aClass withResponders:(NSArray *)responders
{
    NSString *className = NSStringFromClass(aClass);
    if (!classResponders) {
        classResponders = [[NSMutableDictionary alloc] init];
    }
    if (![classResponders objectForKey:className]) {
        [classResponders setObject:responders forKey:className];
    }
    else {
        NSMutableArray *compoundResponders = [[classResponders objectForKey:className] mutableCopy];
        [compoundResponders addObjectsFromArray:responders];
        [classResponders setObject:compoundResponders forKey:className];
    }
}

+ (void)unregisterRespondersForClass:(Class)aClass
{
    if (classResponders) {
        if ([classResponders objectForKey:NSStringFromClass(aClass)]) {
            [classResponders removeObjectForKey:NSStringFromClass(aClass)];
        }
    }
    if ([classResponders count] == 0) {
        classResponders = nil;
    }
}

- (id)firstResponder
{
    __block id firstResponder = nil;
    
    for (NSString *className in [classResponders allKeys]) {
        NSArray *responders = [classResponders objectForKey:className];
        [responders enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isFirstResponder]) {
                firstResponder = obj;
                *stop = YES;
            }
        }];
    }
    return firstResponder;
}

- (void)configureScrollView
{
    self.tapGestureRegognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                        action:@selector(hideKeyboard:)];
    self.tapGestureRegognizer.cancelsTouchesInView = NO;
    self.tapGestureRegognizer.delegate = self;
    [self.scrollView addGestureRecognizer:_tapGestureRegognizer];
}

- (void)addObservers
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeObservers
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

#pragma mark -
#pragma mark Notifications

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(keyboardWasShownWithResponder:)]) {
        [self.delegate keyboardWasShownWithResponder:[self firstResponder]];
    }
    
    CGFloat offest = 0;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(keyboardOffset)]) {
        offest = [self.dataSource keyboardOffset];
    }
    
    NSDictionary* info = [aNotification userInfo];
    CGRect kbRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    kbRect = [self.scrollView convertRect:kbRect fromView:self.scrollView.window];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbRect.size.height + offest, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    
    UIView *activeView = [self firstResponder];
    if (!activeView) {
        NSLog(@"Warning: \"no active view is detected, please provide a valid one by implementing activeView of dataSource or register responders by calling registerResponders: or registerResponder:.\"");
        return;
    }
    
    CGRect aRect = self.scrollView.frame;
    aRect.size.height -= kbRect.size.height;
    CGPoint aPoint = activeView.frame.origin;
    aPoint.y += CGRectGetHeight(activeView.frame);
    if (!CGRectContainsPoint(aRect, aPoint)) {
        [self.scrollView scrollRectToVisible:activeView.frame animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(keyboardWillBeHiddenWithResponder:)]) {
        [self.delegate keyboardWillBeHiddenWithResponder:[self firstResponder]];
    }
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)hideKeyboard:(id)sender
{
    [[self firstResponder] resignFirstResponder];
}

#pragma mark
#pragma mark - UIGestureRecognizerDelegate protocol

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (gestureRecognizer == [self tapGestureRegognizer]) {
        //don't interfere with taps on UIControls
        if ([touch.view isKindOfClass:[UIControl class]]) {
            return NO;
        }
    }
    return YES;
}

@end
