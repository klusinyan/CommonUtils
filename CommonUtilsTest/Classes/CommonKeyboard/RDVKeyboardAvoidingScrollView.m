// RDVKeyboardAvoidingScrollView.m
// RDVKeyboardAvoiding
//
// Copyright (c) 2013 Robert Dimitrov
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "RDVKeyboardAvoidingScrollView.h"

@interface RDVKeyboardAvoidingScrollView () <UIGestureRecognizerDelegate> {
    UIView *_activeTextView;
}

@property (getter = isKeyboardShown) BOOL keyboardShown;
@property (strong) UIGestureRecognizer *tapGestureRegognizer;

@end

@implementation RDVKeyboardAvoidingScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureKeyboardAvoiding];
    }
    return self;
}

- (void)awakeFromNib {
    [self configureKeyboardAvoiding];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Methods

- (void)hideKeyboard:(id)sender {
    [self.activeTextView resignFirstResponder];
}

- (void)configureKeyboardAvoiding {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
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
    
    _tapGestureRegognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                    action:@selector(hideKeyboard:)];
    [_tapGestureRegognizer setCancelsTouchesInView:NO];
    [_tapGestureRegognizer setDelegate:self];
    [self addGestureRecognizer:_tapGestureRegognizer];
}

#pragma mark - Keyboard avoiding

- (void)keyboardWasShown:(NSNotification *)notification {
    [self setKeyboardShown:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.contentInset = contentInsets;
    self.scrollIndicatorInsets = contentInsets;
    self.contentOffset = CGPointZero;
    
    [self setKeyboardShown:NO];
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    // convert keyboardFrame to view's coordinate system, because it is given in the window's which is always portrait
    // http://stackoverflow.com/questions/9746417/keyboard-willshow-and-willhide-vs-rotation
    CGRect convertedFrame = [self convertRect:keyboardFrame fromView:self.window];
    [self moveContentFromBeneathTheKeyboard:convertedFrame];
}

- (void)moveContentFromBeneathTheKeyboard:(CGRect)keyboardFrame {
    keyboardFrame = CGRectIntersection(self.frame, keyboardFrame);
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardFrame.size.height, 0.0);
    self.contentInset = contentInsets;
    self.scrollIndicatorInsets = contentInsets;
    
    if (![self isKeyboardShown]) {
        // Change the content offset only for the first activeTextView, the system handles the rest
        CGRect aRect = self.frame;
        aRect.size.height -= keyboardFrame.size.height;
        
        if (!CGRectContainsPoint(aRect, self.activeTextView.frame.origin)) {
            [self scrollRectToVisible:self.activeTextView.frame animated:YES];
        }
    }
}

- (UIView *)activeTextView {
    if (![_activeTextView isFirstResponder]) {
        UIView *activeView = [self activeTextViewFromSubviews:self.subviews];
        if (activeView.isFirstResponder) {
            _activeTextView = activeView;
            if (_activeTextView) {
                [self scrollRectToVisible:_activeTextView.frame animated:YES];
            }
        }
    }
    return _activeTextView;
}

- (UIView *)activeTextViewFromSubviews:(NSArray *)subviews {
    for (UIView *view in subviews) {
        if (view.subviews.count) {
            UIView *activeView = [self activeTextViewFromSubviews:view.subviews];
            if (activeView.isFirstResponder) {
                return activeView;
            }
        }
        else {
            if (view.isFirstResponder) {
                return view;
            }
        }
    }
    return nil;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer == [self tapGestureRegognizer]) {
        // Don't interfere with taps on UIControls
        if ([[touch view] isKindOfClass:[UIControl class]]) {
            return NO;
        }
    }
    
    return YES;
}

@end
