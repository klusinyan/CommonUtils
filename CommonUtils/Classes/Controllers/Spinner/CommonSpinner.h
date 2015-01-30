//  Created by Lukas Lipka 05/04/14.
//  Modified by Karen Lusinyan on 30/01/15.

typedef void(^CommonSpinnerShowCompletionHandler)(void);
typedef void(^CommonSpinnerHideCompletionHandler)(void);

@interface CommonSpinner : UIView

@property (nonatomic) BOOL hidesWhenStopped;
@property (nonatomic, strong) CAMediaTimingFunction *timingFunction;
@property (nonatomic) CGSize size;
@property (nonatomic) CGFloat lineWidth;
@property (nonatomic, readonly) BOOL isAnimating;

+ (instancetype)sharedSpinner;

+ (void)showWithTaregt:(id)target completion:(CommonSpinnerShowCompletionHandler)completion;

+ (void)hideWithCompletion:(CommonSpinnerHideCompletionHandler)completion;

- (void)startAnimating;

- (void)stopAnimating;

@end
