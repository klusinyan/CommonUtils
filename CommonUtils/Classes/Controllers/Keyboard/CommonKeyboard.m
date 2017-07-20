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
@property (readwrite, nonatomic, getter = isVisible) BOOL visible;

@end

@implementation CommonKeyboard

- (void)dealloc
{
    self.delegate = nil;
    self.dataSource = nil;
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
    if (!responders || [responders count] == 0) return;

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
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification
                                                  object:nil];
}

#pragma mark -
#pragma mark Notifications

- (void)keyboardWillShow:(NSNotification *)aNotification
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(commonKeyboard:willShowWithResponder:)]) {
        [self.delegate commonKeyboard:self willShowWithResponder:[self firstResponder]];
    }
}

- (void)keyboardDidHide:(NSNotification *)aNotification
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(commonKeyboard:didHideWithResponder:)]) {
        [self.delegate commonKeyboard:self didHideWithResponder:[self firstResponder]];
    }
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardDidShow:(NSNotification *)aNotification
{
    self.visible = YES;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(commonKeyboard:didShowWithResponder:)]) {
        [self.delegate commonKeyboard:self didShowWithResponder:[self firstResponder]];
    }
    
    CGFloat offest = 0;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(offsetForKeyboard:)]) {
        offest = [self.dataSource offsetForKeyboard:self];
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
        /*
        DebugLog(@"Warning: \"no active view is detected, please provide a valid one by implementing activeView of dataSource or register responders by calling registerResponders: or registerResponder:.\"");
         //*/
        return;
    }
    
    CGRect aRect = self.scrollView.frame;
    aRect.size.height -= kbRect.size.height;
    
    //CGPoint aPoint = activeView.frame.origin;
    //contro esempio: se la view sta su una cella di table view [CGPoint aPoint = activeView.frame.origin] non funziona
    //quindi bisogna prendere il punto relativo a self.scrollView
    CGPoint aPoint = [activeView convertPoint:activeView.frame.origin toView:self.scrollView];
    CGRect aFrame = [[activeView superview] convertRect:activeView.frame toView:self.scrollView];
    
    //aggiunto, ma puo' essere toglto se e' attivo [self.scrollView.contentOffset = CGPointZero]
    //esempio: tableView che non risponde a self.tableView.contentInset = UIEdgeInsetsZero
    //quindi bisogna forzare con contentOffest = CGPointZero
    aPoint.y -= self.scrollView.contentOffset.y;
    
    aPoint.y += CGRectGetHeight(aFrame);
    if (!CGRectContainsPoint(aRect, aPoint)) {
        [self.scrollView scrollRectToVisible:aFrame animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillHide:(NSNotification*)aNotification
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(commonKeyboard:willHideWithResponder:)]) {
        [self.delegate commonKeyboard:self willHideWithResponder:[self firstResponder]];
    }
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    //decidere, e' neccessario per tableView o no???
    //una volta fixato aPoint.y -= self.scrollView.contentOffset.y], non dovrebbe essere piu' neccessario
    //self.scrollView.contentOffset = CGPointZero;
    
    self.visible = NO;
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
