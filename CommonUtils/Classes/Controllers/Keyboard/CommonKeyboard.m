//  Created by Karen Lusinyan on 18/09/14.
//  Copyright (c) 2014 Karen Lusinyan. All rights reserved.

#import "CommonKeyboard.h"

static __strong NSMutableArray * firstResponders = nil;

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
        
        firstResponders = [NSMutableArray array];
    }
    
    return self;
}

+ (void)registerResponders:(NSArray *)responders
{
    if (responders) {
        [firstResponders addObjectsFromArray:responders];
    }
}

+ (void)unregisterResponders:(NSArray *)responders
{
    if (responders) {
        [firstResponders removeObjectsInArray:responders];
    }
}

+ (void)registerResponder:(id)responder
{
    if (responder) {
        [firstResponders addObject:responder];
    }
}

+ (void)unregisterResponder:(id)responder
{
    if (responder) {
        [firstResponders removeObject:responder];
    }
}

- (id)firstResponder
{
    __block id firstResponder = nil;
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(activeView)]) {
        firstResponder = [self.dataSource activeView];
    }
    if (!firstResponder) {
        [firstResponders enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
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
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(offset)]) {
        offest = [self.dataSource offset];
    }
    
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height + offest, 0.0);
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
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, activeView.frame.origin) ) {
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
