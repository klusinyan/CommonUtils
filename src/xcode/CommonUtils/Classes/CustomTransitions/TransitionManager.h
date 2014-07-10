//  Created by Karen Lusinyan on 21/04/14.

@interface TransitionManager : NSObject <UIViewControllerAnimatedTransitioning>

//aimation properties
@property (readwrite, nonatomic, assign) NSTimeInterval animationDuration;
@property (readwrite, nonatomic, assign) BOOL presenting;
@property (readwrite, nonatomic, assign) CGSize modalSize;

//sourceView (UICollectionViewCell)
@property (readwrite, nonatomic, retain) UIView *source;
@property (readwrite, nonatomic, assign) CGFloat sourceCornerRadius;
@property (readwrite, nonatomic, assign) BOOL animatedCornerRadius;

//animatedView optional proeprties
@property (readwrite, nonatomic, strong) UIColor *modalStartColor;
@property (readwrite, nonatomic, strong) UIColor *modalEndColor;

@end
