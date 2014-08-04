//  Created by Karen Lusinyan on 02/04/14.
//  Copyright (c) 2014 BtB Mobile. All rights reserved.

#import "MainViewController.h"
#import "NavigationControllerController.h"
#import "ModalViewController.h"
#import "TransitionManager.h"
#import "CustomCell.h"
#import "ImageDownloader.h"
#import "UIImageView+AFNetworking.h"
#import "UIColor+Utils.h"
#import "UIImage+Utils.h"

//others
#import "ZoomAnimationController.h"
#import "DropAnimationController.h"

#define USE_iOS7_UIVCTransitioningDelegate 1
#define USE_MY_TRANSITION 1

static NSString *CustomCellIdentifier = @"CustomCellIdentifier";

@interface MainViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (readwrite, nonatomic, strong) UIView *containerView;
@property (readwrite, nonatomic, strong) UICollectionView *collectionView;
@property (readwrite, nonatomic, strong) TransitionManager *transitionManager;
@property (readwrite, nonatomic, retain) NSIndexPath *selectedIndexPath;

//others
@property (nonatomic, strong) id<ADVAnimationController> animationController;

@end

@implementation MainViewController

- (void)dealloc
{
    //do something
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.dataSource = [NSMutableArray array];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.dataSource = [NSMutableArray array];
    }
    return self;
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    if (iPad) {
        layout.sectionInset = UIEdgeInsetsMake(16, 16, 16, 16);
        layout.minimumInteritemSpacing = 16;
        layout.minimumLineSpacing = 16;
        layout.itemSize = CGSizeMake(288, 130);
    }
    else {
        layout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8);
        layout.minimumInteritemSpacing = 8;
        layout.minimumLineSpacing = 8;
        layout.itemSize = CGSizeMake(288, 130);
    }
    
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.containerView = [[UIView alloc] init];
    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.containerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.containerView];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_containerView]-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_containerView)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_containerView]-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_containerView)]];

    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.containerView addSubview:self.collectionView];
    
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_collectionView]|"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:NSDictionaryOfVariableBindings(_collectionView)]];
    
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_collectionView]|"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:NSDictionaryOfVariableBindings(_collectionView)]];
    
    [self.collectionView registerClass:[CustomCell class] forCellWithReuseIdentifier:CustomCellIdentifier];   
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

//override
- (void)updateUI
{
    [self.collectionView reloadData];
}

#pragma mark  -
#pragma mark UICollectionViewDataSource delegate methods

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    //return [self.dataSource count];
    return 500;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CustomCell *cell = [cv dequeueReusableCellWithReuseIdentifier:CustomCellIdentifier forIndexPath:indexPath];
    
    cell.lblNome.text = [NSString stringWithFormat:@"Nome: [%@%@]", @(indexPath.section), @(indexPath.row)];
    cell.lblDescr.text = [NSString stringWithFormat:@"Descrizione: [%@%@]", @(indexPath.section), @(indexPath.row)];
    cell.lblPeriodo.text = [NSString stringWithFormat:@"Periodo di validita: [%@%@]", @(indexPath.section), @(indexPath.row)];
    
    /*
    UIColor *randomColor = [UIColor colorWithRed:(arc4random() % 255) / 255.0f
                                           green:(arc4random() % 255) / 255.0f
                                            blue:(arc4random() % 255) / 255.0f
                                           alpha:1];
    //*/
    //cell.imageView.image = [UIImage imageNamed:@"apple.png"];
    
    
    
    cell.imageView.clipsToBounds = YES;
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    //cell.imageView.backgroundColor = [UIColor colorWithHue:[indexPath row]/100.0f saturation:1 brightness:1 alpha:1];
    
    UIColor *color = [UIColor colorWithHue:[indexPath row]/100.0f saturation:1 brightness:1 alpha:1];
    cell.imageView.backgroundColor = color;
    NSString *hexColor = [UIColor hexStringFromColor:color];
    NSString *url = [NSString stringWithFormat:@"http://placehold.it/1024x1024/%@/&text=image%@", hexColor, @(indexPath.row)];
    
    [ImageDownloader setLogging:YES];
    cell.imageView.image = [ImageDownloader imageWithUrl:url
                                              moduleName:@"my_images"
                                           downloadImage:cell.imageView
                                            forIndexPath:(NSIndexPath *)indexPath
                                     imageRepresentation:UIImageRepresentationJPEG
                                             placeholder:[UIImage imageNamed:@"placeholder"]
                                              completion:^(UIImage *image, NSIndexPath *indexPath) {
                                                  cell.imageView.image = image;
                                                  cell.imageView.layer.transform = CATransform3DMakeScale(0, 0, 0);
                                                  [UIView animateWithDuration:0.25
                                                                        delay:0
                                                                      options:UIViewAnimationOptionCurveEaseOut
                                                                   animations:^{
                                                                       cell.imageView.layer.transform = CATransform3DMakeScale(1, 1, 1);
                                                                   } completion:^(BOOL finished) {
                                                                       //
                                                                   }];

                                              }];
    return cell;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    /*
    NSInteger batchSize = 5;
    
    NSArray *indexPaths = [self.collectionView indexPathsForVisibleItems];
    NSIndexPath *lastIndexPath = [indexPaths lastObject];
    NSInteger fromIndex = [lastIndexPath row];
    NSInteger toIndex = (fromIndex+batchSize > 500) ? 500 : fromIndex+batchSize;
    
    for (int i = [lastIndexPath row]; i < toIndex; i++) {
        UIColor *color = [UIColor colorWithHue:i/100.0f saturation:1 brightness:1 alpha:1];
        NSString *hexColor = [UIColor hexStringFromColor:color];
        NSString *url = [NSString stringWithFormat:@"http://placehold.it/1024x1024/%@/&text=image%@", hexColor, @(i)];
        if (![DirectoryUtils imageExistsWithName:url moduleName:@"my_images"]) {
            
            @autoreleasepool {
                [ImageDownloader imageWithUrl:url
                                   moduleName:@"my_images"
                                downloadImage:[UIImageView new]
                          imageRepresentation:UIImageRepresentationJPEG
                                  placeholder:nil
                                   completion:^(UIImage *image) {
                                       //do nothing
                                   }];
            }
        }
    }
    //*/
}

#pragma mark -
#pragma mark - UICollectionViewDelegate delegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //set the selecetdIndexPath
    self.selectedIndexPath = indexPath;
    
    //get the selectedCell
    CustomCell *targetCell = (CustomCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
#if !USE_iOS7_UIVCTransitioningDelegate
    CGRect rect = [self.view convertRect:targetCell.imageView.frame fromView:targetCell.imageView];
    rect.origin.x -= 8;
    rect.origin.y -= 8;
    DebugLog(@"rect before rotation %@", NSStringFromCGRect(rect));
    
    DebugLog(@"%@", NSStringFromCGRect(rect));

    // distance from center of screen from frontView
    float dx = self.view.center.x - CGRectGetMidX(rect);
    float dy = self.view.center.y - CGRectGetMidY(rect) - self.navigationController.navigationBar.bounds.size.height;

    __block float sx, sy;
    if (iPad) {
        sx = 540/rect.size.width;
        sy = 620/rect.size.height;
    }
    if (iPhone) {
        sx = 200/rect.size.width;
        sy = 300/rect.size.height;
    }
    
    //DebugLog(@"dx %f dy %f", dx, dy);
    
    UIView *firstView = [[UIView alloc] init];
    firstView.frame = rect; //targetCell.imageView.bounds;
    firstView.layer.cornerRadius = 20;
    firstView.backgroundColor = [UIColor blueColor];
    //[targetCell.imageView addSubview:firstView];
    [self.view addSubview:firstView];
    
    firstView.layer.zPosition = 200;
    
    __block CATransform3D savedTransform3D = CATransform3DIdentity;
   
    UIView *animatedView = firstView;
    DebugLog(@"targetCell.imageView.frame %@", NSStringFromCGRect(targetCell.imageView.frame));
    DebugLog(@"animatedView.frame %@", NSStringFromCGRect(animatedView.frame));
    
    self.animating = YES;
    
    // start the animation
    [UIView animateKeyframesWithDuration:1
                                   delay:0
                                 options:UIViewKeyframeAnimationOptionCalculationModeCubicPaced
                              animations:^{
                                  
                                  //change corner radius animated
                                  [self changeCornerRadius:animatedView fromValue:20 toValue:0 duration:0.5];

                                  // part 1.  Rotate and scale frontView halfWay.
                                  [UIView addKeyframeWithRelativeStartTime:0
                                                          relativeDuration:1
                                                                animations:^{
                                                                    
                                                                    CATransform3D tRotate = animatedView.layer.transform;
                                                                    tRotate.m34 = 1.0/-500;
                                                                    tRotate = CATransform3DRotate(tRotate, M_PI, 0, 1, 0);
                                                                    
                                                                    CATransform3D tTranslate = animatedView.layer.transform;
                                                                    tTranslate = CATransform3DTranslate(tTranslate, dx, dy, 0);

                                                                    CATransform3D tScale = animatedView.layer.transform;
                                                                    tScale = CATransform3DScale(tScale, sx, sy, 1);
                                                                    
                                                                    CATransform3D tRotTtans = CATransform3DConcat(tRotate, tTranslate);
                                                                    CATransform3D tScaleRotTrans = CATransform3DConcat(tScale, tRotTtans);
                                                                    firstView.layer.transform = tScaleRotTrans;
                                                                }];
                              } completion:^(BOOL finished) {
                                  [UIView animateWithDuration:1
                                                   animations:^{
                                                       //save previous transform
                                                       savedTransform3D = animatedView.layer.transform;
                                                       
                                                       //restore to identity matrix transform
                                                       animatedView.layer.transform = CATransform3DIdentity;
                                                       
                                                   } completion:^(BOOL finished) {
                                                       
                                                       [firstView removeFromSuperview];

                                                       [UIView animateWithDuration:0.3
                                                                        animations:^{
                                                                            //change corner radius animated
                                                                            targetCell.imageView.layer.cornerRadius = 0;
                                                                            [self changeCornerRadius:targetCell.imageView
                                                                                           fromValue:0
                                                                                             toValue:20
                                                                                            duration:1];
                                                                        } completion:^(BOOL finished) {
                                                                            //[firstView removeFromSuperview];
                                                                            self.animating = NO;
                                                                        }];

                                                   }];
                              }];
#else    
    //scroll to rect of the cell and make it visible (if necessary)
    [self.collectionView scrollRectToVisible:targetCell.frame animated:YES];

    if (iPad || USE_MY_TRANSITION) {
        //set the tranisionManager sourceView the view to animate
        self.transitionManager.source = targetCell.imageView;
        self.transitionManager.sourceCornerRadius = 20;
        self.transitionManager.modalStartColor = targetCell.imageView.backgroundColor;
        self.transitionManager.modalEndColor = [UIColor whiteColor];
        //self.transitionManager.modalEndColor = [UIColor colorWithWhite:0.8 alpha:1];
        
        ModalViewController *modal = [[ModalViewController alloc] initWithNibName:@"ModalViewController" bundle:nil];
        modal.title = targetCell.lblNome.text;
        //modal.view.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
        modal.view.backgroundColor = nil;
        //modal.imageView.backgroundColor = targetCell.imageView.backgroundColor;
        modal.imageView.layer.cornerRadius = targetCell.imageView.layer.cornerRadius;
        modal.imageView.image = targetCell.imageView.image;
        modal.imageView.clipsToBounds = YES;
        
        NavigationControllerController *nc = [[NavigationControllerController alloc] initWithRootViewController:modal];
        nc.navigationBar.translucent = NO;
        nc.navigationBar.tintColor = [UIColor whiteColor];
        nc.navigationBar.barTintColor = [UIColor redColor];
        nc.view.autoresizingMask = UIViewAutoresizingNone;
        UIViewController *presentViewController = nc;
        
        presentViewController.transitioningDelegate = self;
        presentViewController.modalPresentationStyle = UIModalPresentationCustom;
        [self presentViewController:presentViewController animated:YES completion:^{
            
        }];
    }
    else {
        if (arc4random_uniform(2)) {
            self.animationController = [[ZoomAnimationController alloc] init];
        }
        else {
            self.animationController = [[DropAnimationController alloc] init];
        }
        
        ModalViewController *modal = [[ModalViewController alloc] initWithNibName:@"ModalViewController" bundle:nil];
        modal.title = targetCell.lblNome.text;
        modal.view.backgroundColor = [UIColor greenColor]; //[UIColor colorWithWhite:0.8 alpha:1];
        modal.imageView.backgroundColor = targetCell.imageView.backgroundColor;
        modal.imageView.layer.cornerRadius = targetCell.imageView.layer.cornerRadius;
        
        NavigationControllerController *nc = [[NavigationControllerController alloc] initWithRootViewController:modal];
        nc.navigationBar.translucent = NO;
        nc.view.autoresizingMask = UIViewAutoresizingNone;
        UIViewController *presentViewController = nc;
        
        presentViewController.transitioningDelegate = self;
        presentViewController.modalPresentationStyle = UIModalPresentationCustom;
        [self presentViewController:presentViewController animated:YES completion:^{
            
        }];
    }
#endif
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //do something
}

//if there is no navigation controller
///*
- (BOOL)shouldAutorotate
{
    return !self.animating;
}
//*/

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    //first scroll to make the rect visibile
    CustomCell *targetCell = (CustomCell *)[self.collectionView cellForItemAtIndexPath:self.selectedIndexPath];
    [self.collectionView scrollRectToVisible:targetCell.frame animated:YES];
    
    //then scroll to top if necessary
    [self.collectionView scrollToItemAtIndexPath:self.selectedIndexPath
                                atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    //get the new cell frame and set to transitionManager
    CustomCell *targetCell = (CustomCell *)[self.collectionView cellForItemAtIndexPath:self.selectedIndexPath];
    self.transitionManager.source = targetCell.imageView;
    CGRect rect = [self.view convertRect:targetCell.imageView.frame fromView:targetCell.imageView];
    DebugLog(@"rect after rotation %@", NSStringFromCGRect(rect));
}

#pragma mark -
#pragma mark UIViewControllerTransitioningDelegate delegate methods

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                   presentingController:(UIViewController *)presenting
                                                                       sourceController:(UIViewController *)source
{
    if (iPad || USE_MY_TRANSITION) {
        self.transitionManager.presenting = YES;
        return self.transitionManager;
    }
    else {
        self.animationController.isPresenting = YES;
        return self.animationController;
    }
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    if (iPad || USE_MY_TRANSITION) {
        self.transitionManager.presenting = NO;
        return self.transitionManager;
    }
    else {
        self.animationController.isPresenting = NO;
        return self.animationController;
    }
}

#pragma mark -
#pragma mark KLSegmentedControllerDelegate delegate methods

- (void)controllerDidBecomeActive
{
    [self updateUI];
}

#pragma mark -
#pragma mark Accessors

//custommize your transition manager
- (TransitionManager *)transitionManager
{
    if (!_transitionManager) {
        _transitionManager = [[TransitionManager alloc] init];
        _transitionManager.animationDuration = 0.35;
        //_transitionManager.animatedCornerRadius = YES; //default NO
        _transitionManager.modalSize = (iPad) ? (CGSize){540.f, 620.0f} : (CGSize){280.0f, 300.0f};
    }
    return _transitionManager;
}

#if !USE_iOS7_UIVCTransitioningDelegate
//Make the corner raidus animated
- (void)changeCornerRadius:(UIView *)view fromValue:(float)fromValue toValue:(float)toValue duration:(NSTimeInterval)duration
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.fromValue = [NSNumber numberWithFloat:fromValue];
    animation.toValue = [NSNumber numberWithFloat:toValue];
    animation.duration = duration;
    [view.layer setCornerRadius:toValue];
    [view.layer addAnimation:animation forKey:@"cornerRadius"];
}
#endif

/*
// flip and scale frontView to reveal backView to the center of the screen
// uses a containerView to mark the end of the animation
// parameterizing the destination is an exercise for the reader
- (void)flipFromFront:(UIView*)frontView toBack:(UIView*)backView
{
    float duration = 0.5;
    
    // distance from center of screen from frontView
    float dx = self.view.center.x - frontView.center.x;
    float dy = self.view.center.y - frontView.center.y;
    
    // this prevents any tearing
    backView.layer.zPosition = 200.0;
    
    // hide the backView and position where frontView is
    backView.hidden = NO;
    backView.alpha = 0.0;
    backView.frame = frontView.frame;
    
    // start the animation
    [UIView animateKeyframesWithDuration:duration
                                   delay:5
                                 options:UIViewKeyframeAnimationOptionCalculationModeCubic
                              animations:^{
                                  // part 1.  Rotate and scale frontView halfWay.
                                  [UIView addKeyframeWithRelativeStartTime:0.0
                                                          relativeDuration:5
                                                                animations:^{
                                                                    // get the transform for the blue layer
                                                                    CATransform3D xform = frontView.layer.transform;
                                                                    // translate half way
                                                                    xform = CATransform3DTranslate(xform, dx/2, dy/2, 0);
                                                                    // rotate half way
                                                                    xform = CATransform3DRotate(xform, M_PI_2, 0, 1, 0);
                                                                    // scale half way
                                                                    xform = CATransform3DScale(xform, 1.5, 1.5, 1);
                                                                    // apply the transform
                                                                    frontView.layer.transform = xform;
                                                                }];
                                  
                                  // part 2. set the backView transform to frontView so they are in the same
                                  // position.
                                  [UIView addKeyframeWithRelativeStartTime:5
                                                          relativeDuration:0.0
                                                                animations:^{
                                                                    backView.layer.transform = frontView.layer.transform;
                                                                    backView.alpha = 1.0;
                                                                }];
                                  
                                  // part 3.  rotate and scale backView into center of container
                                  [UIView addKeyframeWithRelativeStartTime:5
                                                          relativeDuration:0.5
                                                                animations:^{
                                                                    // undo previous transforms with animation
                                                                    backView.layer.transform = CATransform3DIdentity;
                                                                    // animate backView into new location
                                                                    backView.frame = CGRectMake(0, 0, 540, 620); //self.containerView.frame;
                                                                }];
                              } completion:^(BOOL finished) {
                                  [backView removeFromSuperview];

                                  //self.displayingFront = !self.displayingFront;
                              }];
}

// flip from back to front
- (void) flipFromBack:(UIView*)backView toFront:(UIView*)frontView
{
    float duration = 0.5;
    
    // get distance from center of screen to destination
    float dx = self.view.center.x - frontView.center.x;
    float dy = self.view.center.y - frontView.center.y;
    
    backView.layer.zPosition = 200.0;
    frontView.hidden = YES;
    
    // this is basically the reverse of the previous animation
    [UIView animateKeyframesWithDuration:duration
                                   delay:0
                                 options:UIViewKeyframeAnimationOptionCalculationModeCubic
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0.0
                                                          relativeDuration:0.5
                                                                animations:^{
                                                                    CATransform3D xform = backView.layer.transform;
                                                                    xform = CATransform3DTranslate(xform, -dx/2, -dy/2, 0);
                                                                    xform = CATransform3DRotate(xform, M_PI_2, 0, 1, 0);
                                                                    xform = CATransform3DScale(xform, 0.75, 0.75, 1);
                                                                    backView.layer.transform = xform;
                                                                }];
                                  
                                  [UIView addKeyframeWithRelativeStartTime:0.5
                                                          relativeDuration:0.0
                                                                animations:^{
                                                                    backView.alpha = 0.0;
                                                                    frontView.hidden = NO;
                                                                }];
                                  
                                  [UIView addKeyframeWithRelativeStartTime:0.5
                                                          relativeDuration:0.5
                                                                animations:^{
                                                                    self.hiddenView.alpha = 0.0;
                                                                    frontView.layer.transform = CATransform3DIdentity;
                                                                }];
                              } completion:^(BOOL finished) {
                                  self.displayingFront = !self.displayingFront;
                              }];
}
*/
 
@end
