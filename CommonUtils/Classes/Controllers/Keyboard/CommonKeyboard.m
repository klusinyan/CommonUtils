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
@property (readwrite, nonatomic, getter = isKeyboardShown) BOOL keyboardShown;
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
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChangeFrame:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
}

- (void)removeObservers
{

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillChangeFrameNotification
                                                  object:nil];
}

#pragma mark -
#pragma mark Notifications

- (void)keyboardDidShow:(NSNotification *)notification
{
    self.keyboardShown = YES;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(keyboardDidShowWithResponder:)]) {
        [self.delegate keyboardDidShowWithResponder:[self firstResponder]];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    self.scrollView.contentOffset = CGPointZero;
    
    self.keyboardShown = NO;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(keyboardWillHideWithResponder:)]) {
        [self.delegate keyboardWillHideWithResponder:[self firstResponder]];
    }
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    //keyboard frame
    CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    //convert keyboardFrame to view's coordinate system, because it is given in the window's which is always portrait
    CGRect convertedFrame = [self.scrollView convertRect:keyboardFrame fromView:self.scrollView.window];

    [self handleScrollingWithKeyboardFrame:convertedFrame];
}

#pragma mark -
#pragma mark Scrolling

- (void)handleScrollingWithKeyboardFrame:(CGRect)keyboardFrame
{
    keyboardFrame = CGRectIntersection(self.scrollView.frame, keyboardFrame);
    
    //keyboard offset if needed
    CGFloat offset = 0.0f;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(offset)]) {
        offset = [self.dataSource offset];
    }
    
    UIEdgeInsets contentInsets =
    UIEdgeInsetsMake(0.0f, 0.0f, keyboardFrame.size.height + self.scrollView.contentOffset.y + offset, 0.0f);
    
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    if (!self.isKeyboardShown) {
        
        CGRect aRect = self.scrollView.frame;
        aRect.size.height -= keyboardFrame.size.height;

        UIView *activeView = [self firstResponder];
        if (!activeView) {
            NSLog(@"Warning: \"no active view is detected, please provide a valid one by implementing activeView of dataSource or register responders by calling registerResponders: or registerResponder:.\"");
            return;
        }
        
        // convert viewToScroll to view's coordinate system, maybe the view's superview is in the other coordinate system
        CGRect rectToScroll = [self.scrollView convertRect:activeView.frame fromView:[activeView superview]];
        
        //equivalent to upper method
        //CGRect frameToScroll = [[viewToScroll superview] convertRect:viewToScroll.frame toView:self.scrollView];

        //call to scroll to visible rect (done always)
        [self.scrollView scrollRectToVisible:rectToScroll animated:YES];

        //not used: should be used the one above the one above
        /*
        if (!CGRectContainsPoint(aRect, rectToScroll.origin)) {
            [self.scrollView scrollRectToVisible:rectToScroll animated:YES];
        }
        //*/
    }
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
