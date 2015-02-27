//  Created by Karen Lusinyan on 27/02/15.
//  Copyright (c) 2015 Karen Lusinyan. All rights reserved.

#import "CommonPageContent.h"
#import "DirectoryUtils.h"

#define ZOOM_VIEW_TAG 100
#define ZOOM_STEP 1.5
#define IMAGE_DISTANCE 2

@interface CommonPageContent () <UIScrollViewDelegate>

@property (nonatomic, strong) IBOutlet UIView *container;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *leadingInset;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *topInset;

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center;

@end

@implementation CommonPageContent

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.imageDistance = IMAGE_DISTANCE;
        self.backgroundColor = [UIColor clearColor];
        self.zoomEnabled = NO;
    }
    return self;
}

+ (instancetype)instance
{
    return [[self alloc] initWithNibName:NSStringFromClass([self class]) bundle:[DirectoryUtils commonUtilsBundle]];
}

- (void)loadView
{
    [super loadView];
    
    // set the tag for the image view
    [self.imageView setTag:ZOOM_VIEW_TAG];
    
    // add gesture recognizers to the image view
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    UITapGestureRecognizer *twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerTap:)];
    
    [doubleTap setNumberOfTapsRequired:2];
    [twoFingerTap setNumberOfTouchesRequired:2];
    
    [self.imageView addGestureRecognizer:singleTap];
    [self.imageView addGestureRecognizer:doubleTap];
    [self.imageView addGestureRecognizer:twoFingerTap];

    // calculate minimum scale to perfectly fit image width, and begin at that scale
    float minimumScale = [self.scrollView frame].size.width  / [self.imageView frame].size.width;
    [self.scrollView setMinimumZoomScale:minimumScale];
    [self.scrollView setZoomScale:minimumScale];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = self.backgroundColor;

    self.imageView.image = self.image;
    
    self.leadingInset.constant = self.imageDistance;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
}

#pragma mark UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if (self.zoomEnabled) {
        return [self.scrollView viewWithTag:ZOOM_VIEW_TAG];
    }
    return nil;
}

#pragma mark TapDetectingImageViewDelegate methods

- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer
{
    // single tap does nothing for now
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer
{
    // double tap zooms in
    float newScale = [self.scrollView zoomScale] * ZOOM_STEP;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
    [self.scrollView zoomToRect:zoomRect animated:YES];
}

- (void)handleTwoFingerTap:(UIGestureRecognizer *)gestureRecognizer
{
    // two-finger tap zooms out
    float newScale = [self.scrollView zoomScale] / ZOOM_STEP;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
    [self.scrollView zoomToRect:zoomRect animated:YES];
}

#pragma mark Utility methods

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates.
    // At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    // As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [self.scrollView frame].size.height / scale;
    zoomRect.size.width  = [self.scrollView frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}
@end
