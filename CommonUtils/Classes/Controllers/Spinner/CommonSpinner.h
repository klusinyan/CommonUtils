//  Created by Lukas Lipka 05/04/14.
//  Modified by Karen Lusinyan on 30/01/15.

typedef void(^CommonSpinnerShowCompletionHandler)(void);
typedef void(^CommonSpinnerHideCompletionHandler)(void);

@interface CommonSpinner : UIView

// Default tintColor = [UIColor grayColor]
// To change tintColor use: [CommonSpinner sharedSpinner].tintColor = [UIColor redColor]

@property (nonatomic) BOOL hidesWhenStopped;                            //defualt NO
@property (nonatomic, strong) CAMediaTimingFunction *timingFunction;    //default kCAMediaTimingFunctionLinear
@property (nonatomic) CGSize size;                                      //default {40, 40}
@property (nonatomic) CGFloat lineWidth;                                //default 1.5
@property (nonatomic, readonly) BOOL isAnimating;

+ (instancetype)sharedSpinner;

+ (void)showWithTaregt:(id)target completion:(CommonSpinnerShowCompletionHandler)completion;

+ (void)hideWithCompletion:(CommonSpinnerHideCompletionHandler)completion;

- (void)startAnimating;

- (void)stopAnimating;

@end
