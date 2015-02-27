//  Created by Karen Lusinyan on 13/02/15.
//  Copyright (c) 2015 Karen Lusinyan. All rights reserved.

#import "CommonPageContent.h"

#define ZOOM_STEP 1.5

@interface CommonPageContent () <UIScrollViewDelegate>

@property (readwrite, nonatomic, strong) UIView *contentView;
@property (readwrite, nonatomic, strong) UIScrollView *scrollView;
@property (readwrite, nonatomic, strong) UIImageView *imageView;

@property (readwrite, nonatomic, strong) UITapGestureRecognizer *singleTapGestureRecognizer;
@property (readwrite, nonatomic, strong) UITapGestureRecognizer *doubleTapGestureRecognizer;

@end

@implementation CommonPageContent

- (void)dealloc
{
    self.scrollView.delegate = nil;
    self.scrollView = nil;
    
    self.imageView = nil;
    self.singleTapGestureRecognizer = nil;
    self.doubleTapGestureRecognizer = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (id)init
{
    self = [super init];
    if (self) {
        [self setupDefaults];
        //[self addObservers];
    }
    return self;
}

- (void)addObservers
{
    /*
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationDidChange:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
    //*/

}

- (void)removeObservers
{
    /*
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //*/
}

- (UIViewAutoresizing)autoresizingMaskFlexibleAll
{
    return
    UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleHeight |
    UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleBottomMargin;
}

- (void)setupDefaults
{
    self.backgroundColor = [UIColor clearColor];
    self.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
}

- (void)setContentInset:(UIEdgeInsets)contentInset toView:(UIView *)view
{
    CGRect rect = view.bounds;
    rect.origin.x += self.contentInset.left;
    rect.origin.y += self.contentInset.top;
    rect.size.width -= 2*self.contentInset.right;
    rect.size.height -= 2*self.contentInset.bottom;
    view.frame = rect;
}

- (void)loadView
{
    self.view= [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view.backgroundColor = self.backgroundColor;
    
    /*
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view.backgroundColor = self.backgroundColor;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.autoresizingMask = [self autoresizingMaskFlexibleAll];
    
    self.scrollView.backgroundColor = [UIColor greenColor];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.minimumZoomScale = 1.0f;
    self.scrollView.maximumZoomScale = (self.isZoomEnabled) ? 2.0f : 1.0f;
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
    
    CGRect rect = self.scrollView.bounds;
    rect.origin.x += self.contentInset.left;
    rect.origin.y += self.contentInset.top;
    rect.size.width -= 2*self.contentInset.right;
    rect.size.height -= 2*self.contentInset.bottom;
    
    self.imageView = [[UIImageView alloc] initWithFrame:rect];
    self.imageView.autoresizingMask = [self autoresizingMaskFlexibleAll];
    
    //self.imageView.backgroundColor = [UIColor redColor];
    self.imageView.userInteractionEnabled = YES;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.scrollView addSubview:self.imageView];
    
    self.doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    self.doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    self.doubleTapGestureRecognizer.numberOfTouchesRequired = 1;
    [self.scrollView addGestureRecognizer:self.doubleTapGestureRecognizer];
    //*/
    
    /*
     //-----------TODO-----------//
     self.singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showHideNavigationBar)];
     self.singleTapGestureRecognizer.numberOfTapsRequired = 1;
     self.singleTapGestureRecognizer.numberOfTouchesRequired = 1;
     [self.imageView addGestureRecognizer:self.singleTapGestureRecognizer];

     [self.singleTapGestureRecognizer requireGestureRecognizerToFail:self.doubleTapGestureRecognizer];
     //*/
}

- (NSDictionary *)bindings
{
    return @{@"contentView" : self.contentView,
             @"scrollView" : self.scrollView,
             @"imageView" : self.imageView};
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = self.backgroundColor;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.scrollView = [[UIScrollView alloc] init];
    //self.scrollView.backgroundColor = [UIColor greenColor];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.minimumZoomScale = 1.0f;
    self.scrollView.maximumZoomScale = (self.isZoomEnabled) ? 2.0f : 1.0f;
    self.scrollView.delegate = self;
    self.scrollView.multipleTouchEnabled = YES;
    self.scrollView.delaysContentTouches = YES;
    self.scrollView.canCancelContentTouches = YES;
    [self.view addSubview:self.scrollView];
    
    self.contentView = [[UIView alloc] init];
    self.contentView.backgroundColor = [UIColor blueColor];
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentView.userInteractionEnabled = YES;
    [self.scrollView addSubview:self.contentView];
    
    self.imageView = [[UIImageView alloc] init];
    self.imageView.backgroundColor = [UIColor redColor];
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.image = self.image;
    self.imageView.userInteractionEnabled = YES;
    [self.contentView addSubview:self.imageView];

    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    UITapGestureRecognizer *twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerTap:)];
    
    [doubleTap setNumberOfTapsRequired:2];
    [twoFingerTap setNumberOfTouchesRequired:2];
    
    [self.imageView addGestureRecognizer:singleTap];
    [self.imageView addGestureRecognizer:doubleTap];
    [self.imageView addGestureRecognizer:twoFingerTap];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:[self bindings]]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:[self bindings]]];
    
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|"
                                                                            options:0
                                                                            metrics:0
                                                                              views:[self bindings]]];
    
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|"
                                                                            options:0
                                                                            metrics:0
                                                                              views:[self bindings]]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:[self bindings]]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:[self bindings]]];
    
    NSLayoutConstraint *c1 = [NSLayoutConstraint constraintWithItem:self.contentView
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1
                                                           constant:0];
    
    NSLayoutConstraint *c2 = [NSLayoutConstraint constraintWithItem:self.contentView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:1
                                                           constant:0];
    
    [self.view addConstraints:@[c1, c2]];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    //---------------ZOOM OUT---------------//
    [self.scrollView setZoomScale:1 animated:YES];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];

    //---------------ZOOM OUT---------------//
    [self.scrollView setZoomScale:1 animated:YES];
}

#pragma mark
#pragma mark - UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.contentView;
}

#pragma mark
#pragma mark - Private methods

- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer
{
    // single tap does nothing for now
}


//- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer
//{
//    // double tap zooms in
//    //float newScale = [self.scrollView zoomScale] * ZOOM_STEP;
//    
//    ///*
//    CGFloat newScale = (self.scrollView.zoomScale == self.scrollView.minimumZoomScale) ?
//    self.scrollView.maximumZoomScale :
//    self.scrollView.minimumZoomScale;
//    //*/
//
//    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
//    [self.scrollView zoomToRect:zoomRect animated:YES];
//}
//
//- (void)handleTwoFingerTap:(UIGestureRecognizer *)gestureRecognizer
//{
//    // two-finger tap zooms out
//    //float newScale = [self.scrollView zoomScale] / ZOOM_STEP;
//    
//    ///*
//    CGFloat newScale = (self.scrollView.zoomScale == self.scrollView.minimumZoomScale) ?
//    self.scrollView.maximumZoomScale :
//    self.scrollView.minimumZoomScale;
//    //*/
//    
//    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
//    [self.scrollView zoomToRect:zoomRect animated:YES];
//}

- (void)handleDoubleTap:(UITapGestureRecognizer *)tapGestureRecognizer
{
    ///*
    CGPoint center = [tapGestureRecognizer locationInView:[tapGestureRecognizer view]];
    
    CGFloat scale = (self.scrollView.zoomScale == self.scrollView.minimumZoomScale) ?
    self.scrollView.maximumZoomScale :
    self.scrollView.minimumZoomScale;
    
    CGRect rect = [self zoomRectForScrollView:self.scrollView
                                    withScale:scale
                                   withCenter:center];
    
    [self.scrollView zoomToRect:rect animated:YES];
    //*/
     
    /*
    if (self.scrollView.zoomScale == self.scrollView.minimumZoomScale) {
        
        //---------------ZOOM IN---------------//
        CGPoint center = [tapGestureRecognizer locationInView:self.scrollView];
        
        CGSize size = CGSizeMake(self.scrollView.bounds.size.width / self.scrollView.maximumZoomScale,
                                 self.scrollView.bounds.size.height / self.scrollView.maximumZoomScale);
        
        CGRect rect = CGRectMake(center.x - (size.width / 2.0),
                                 center.y - (size.height / 2.0),
                                 size.width,
                                 size.height);
        
        [self.scrollView zoomToRect:rect animated:YES];
    }
    else {
        
        //---------------ZOOM OUT---------------//
        [self.scrollView zoomToRect:self.scrollView.bounds animated:YES];
    }
    //*/
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates.
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [self.scrollView frame].size.height / scale;
    zoomRect.size.width  = [self.scrollView frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

//Apples's sample code
- (CGRect)zoomRectForScrollView:(UIScrollView *)scrollView
                      withScale:(float)scale
                     withCenter:(CGPoint)center
{
    CGRect zoomRect;
    
    // The zoom rect is in the content view's coordinates.
    // At a zoom scale of 1.0, it would be the size of the
    // imageScrollView's bounds.
    // As the zoom scale decreases, so more content is visible,
    // the size of the rect grows.
    zoomRect.size.height = scrollView.frame.size.height / scale;
    zoomRect.size.width  = scrollView.frame.size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

@end
