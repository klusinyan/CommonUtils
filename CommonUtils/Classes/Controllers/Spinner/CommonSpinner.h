//  Created by Lukas Lipka 05/04/14.
//  Modified by Karen Lusinyan on 30/01/15.

//UIKIT_EXTERN NSString * const kCommonSpinnerKeyTintColor;   //default nil
//UIKIT_EXTERN NSString * const kCommonSpinnerKeySize;        //default {40, 40}
//UIKIT_EXTERN NSString * const kCommonSpinnerKeyLineWidth;   //default 1.5

typedef void(^CommonSpinnerShowCompletionHandler)(void);
typedef void(^CommonSpinnerHideCompletionHandler)(void);

@interface CommonSpinner : UIView

// Default tintColor = [UIColor grayColor]
// To change tintColor use: [CommonSpinner sharedSpinner].tintColor = [UIColor redColor]

/********************************************/
/*************SINGLETON INSTANCE*************/
/********************************************/
+ (instancetype)sharedSpinner;

+ (void)setTintColor:(UIColor *)tintColor;

+ (void)setTitle:(NSString *)title;

+ (void)setImage:(UIImage *)image;

+ (void)setTitleOnly:(NSString *)title activityIndicatorVisible:(BOOL)activityIndicatorVisible;

+ (void)setHidesWhenStopped:(BOOL)hidesWhenStopped;

+ (void)setRunInBackground:(BOOL)runInBackgroud;

+ (void)setNetworkActivityIndicatorVisible:(BOOL)networkActivityIndicatorVisible;

+ (void)setTimingFunction:(CAMediaTimingFunction *)timingFunction;

+ (void)setSpinnerSize:(CGSize)size;

+ (void)setLineWidth:(CGFloat)lineWidth;

+ (BOOL)isAnimating;

+ (void)showInView:(UIView *)view completion:(CommonSpinnerShowCompletionHandler)completion;

+ (void)hideWithCompletion:(CommonSpinnerHideCompletionHandler)completion;

@property (nonatomic, copy) NSString *title;                            // default nil
@property (nonatomic, strong) UIImage *image;                           // default nil
@property (nonatomic) BOOL hidesWhenStopped;                            // defualt NO
@property (nonatomic) BOOL runInBackgroud;                              // defualt NO
@property (nonatomic) BOOL networkActivityIndicatorVisible;             // default YES
@property (nonatomic, strong) CAMediaTimingFunction *timingFunction;    // default kCAMediaTimingFunctionLinear
@property (nonatomic) CGSize spinnerSize;                               // default {20, 20}
@property (nonatomic) CGSize imageSize;                                 // default {40, 40}
@property (nonatomic) CGFloat lineWidth;                                // default 1.5
@property (nonatomic, readonly) BOOL isAnimating;

+ (instancetype)instance;

- (void)setTitle:(NSString *)title;

- (void)setImage:(UIImage *)image;

- (void)setTitleOnly:(NSString *)title activityIndicatorVisible:(BOOL)activityIndicatorVisible;

- (void)showInView:(UIView *)view completion:(CommonSpinnerShowCompletionHandler)completion;

- (void)hideWithCompletion:(CommonSpinnerHideCompletionHandler)completion;

- (void)startAnimating;

- (void)stopAnimating;

@end
