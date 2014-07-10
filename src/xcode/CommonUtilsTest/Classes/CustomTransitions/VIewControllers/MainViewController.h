//  Created by Karen Lusinyan on 16/04/14.

#import "BaseViewController.h"

//not used
@protocol MainViewControllerDelegate <NSObject>

@required
@property(readwrite, nonatomic, getter = isAnimating) BOOL animating;

@end

@interface MainViewController : BaseViewController <UIViewControllerTransitioningDelegate, MainViewControllerDelegate>

@property(readwrite, nonatomic, strong) NSArray *dataSource;

//not used
@property(readwrite, nonatomic, getter = isAnimating) BOOL animating;

@end
