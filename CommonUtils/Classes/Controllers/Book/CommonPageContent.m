//  Created by Karen Lusinyan on 27/02/15.
//  Copyright (c) 2015 Karen Lusinyan. All rights reserved.

#import "CommonPageContent.h"
#import "DirectoryUtils.h"

#define ZOOM_VIEW_TAG 100
#define ZOOM_STEP 1.5
#define IMAGE_DISTANCE 5

@interface CommonPageContent () <UIScrollViewDelegate>

@property (nonatomic, strong) IBOutlet CSAnimationView *animationView;
@property (nonatomic, strong) IBOutlet UIView *container;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *leadingSpace;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *topSpace;

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center;

@end

@implementation CommonPageContent

- (void)dealloc
{
    self.scrollView.delegate = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.leadingSpaceWhenPortrait = IMAGE_DISTANCE;
        self.leadingSpaceWhenLandscape = 0;
        self.topSpaceWhenPortrait = 0;
        self.topSpaceWhenLandscape = 0;
        self.backgroundColor = [UIColor clearColor];
        self.zoomEnabled = NO;
        
        //defualt is nil for memory
        //self.image = [UIImage imageNamed:@"CommonUtils.bundle/CommonProgress.bundle/WeCanDoIt"];
    }
    return self;
}

+ (instancetype)pageContent
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

/****************SEQ[1]****************/
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = self.backgroundColor;

    self.imageView.image = self.image;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(pageContentDidLoad:)]) {
        [self.delegate pageContentDidLoad:self];
    }
}
/****************SEQ[1]****************/

/****************SEQ[2]****************/
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    for (int i = 0; i < [self.animations count]; i++) {
        CommonAnimation *anim = [self.animations objectAtIndex:i];
        if (self.animationRule == CommonAnimationRuleNone) {
            continue;
        }
        if (self.animationRule == CommonAnimationRuleShowOnce) {
            if (self.animated) {
                continue;
            }
            if (i == [self.animations count] - 1) {
                self.animated = YES;
            }
        }
        self.animationView.type = anim.type;
        self.animationView.delay = anim.delay;
        self.animationView.duration = anim.duration;
        [self.animationView startCanvasAnimation];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(pageContentWillAppear:)]) {
        [self.delegate pageContentWillAppear:self];
    }
}
/****************SEQ[2]****************/

/****************SEQ[3]****************/
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(pageContentDidAppear:)]) {
        [self.delegate pageContentDidAppear:self];
    }
}
/****************SEQ[3]****************/

/****************SEQ[4]****************/
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        self.leadingSpace.constant = self.leadingSpaceWhenPortrait;
        self.topSpace.constant = self.topSpaceWhenPortrait;
    }
    else {
        self.leadingSpace.constant = self.leadingSpaceWhenLandscape;
        self.topSpace.constant = self.topSpaceWhenLandscape;
    }
}
/****************SEQ[4]****************/

/****************SEQ[5]****************/
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}
/****************SEQ[5]****************/

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(pageContentWillDisappear:)]) {
        [self.delegate pageContentWillDisappear:self];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    if (self.delegate && [self.delegate respondsToSelector:@selector(pageContentDidDisappear:)]) {
        [self.delegate pageContentDidDisappear:self];
    }
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
