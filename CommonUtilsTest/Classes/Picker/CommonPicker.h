//  Created by Karen Lusinyan on 18/09/14.
//  Copyright (c) 2014 Karen Lusinyan. All rights reserved.

typedef void(^CancelCompletionHandler)(void);
typedef void(^DoneCompletionHandler)(NSString *selectedItem, NSInteger selectedIndex);

@interface CommonPicker : NSObject

- (instancetype)initWithTarget:(id)target
                        sender:(id)sender
                     withTitle:(NSString *)title
                         items:(NSArray *)items
              cancelCompletion:(CancelCompletionHandler)cancelCompletion
                doneCompletion:(DoneCompletionHandler)doneCompletion;

@property (readonly, nonatomic, getter=isVisible) BOOL visible;

@property (readwrite, nonatomic, assign) BOOL showWhenOrientationDidChange;

- (void)showPickerWithCompletion:(void (^)(void))completion;

- (void)dismissPickerWithCompletion:(void (^)(void))completion;

@end
