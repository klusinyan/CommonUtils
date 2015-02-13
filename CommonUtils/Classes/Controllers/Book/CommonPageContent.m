//  Created by Karen Lusinyan on 13/02/15.
//  Copyright (c) 2015 Karen Lusinyan. All rights reserved.

#import "CommonPageContent.h"

@interface CommonPageContent () <UIScrollViewDelegate>

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

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view.backgroundColor = self.backgroundColor;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.autoresizingMask = [self autoresizingMaskFlexibleAll];
    
    //self.scrollView.backgroundColor = [UIColor greenColor];
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
    self.doubleTapGestureRecognizer.cancelsTouchesInView = YES;
    [self.imageView addGestureRecognizer:self.doubleTapGestureRecognizer];
    
    /*
     //-----------TODO-----------//
     self.singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showHideNavigationBar)];
     self.singleTapGestureRecognizer.numberOfTapsRequired = 1;
     self.singleTapGestureRecognizer.numberOfTouchesRequired = 1;
     [self.imageView addGestureRecognizer:self.singleTapGestureRecognizer];

     [self.singleTapGestureRecognizer requireGestureRecognizerToFail:self.doubleTapGestureRecognizer];
     //*/
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = self.backgroundColor;
    
    self.imageView.image = self.image;
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
    return self.imageView;
}

#pragma mark
#pragma mark - Private methods

- (void)handleDoubleTap:(UITapGestureRecognizer *)tapGestureRecognizer
{
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
}


//not used
//Apples's sample code
- (CGRect)zoomRectForScrollView:(UIScrollView *)scrollView withScale:(float)scale withCenter:(CGPoint)center
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
