//  LGViewHUD.m
//  Created by y0n3l on 4/13/11.
//  Modified by Karen Lusinyan

#import "ProgressView.h"
#import <QuartzCore/QuartzCore.h>

static ProgressView* defaultHUD = nil;

@interface GradientView : UIView

@end

@implementation GradientView

- (void)drawRect:(CGRect)rect
{
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    CGGradientRef glossGradient;
    CGColorSpaceRef rgbColorspace;
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = { 1.0, 1.0, 1.0, 0.35,  // Start color
        1.0, 1.0, 1.0, 0.06 }; // End color
    
    rgbColorspace = CGColorSpaceCreateDeviceRGB();
    glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
    
    CGRect currentBounds = self.bounds;
    CGPoint topCenter = CGPointMake(CGRectGetMidX(currentBounds), 0.0f);
    CGPoint midCenter = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMidY(currentBounds));
    CGContextDrawLinearGradient(currentContext, glossGradient, topCenter, midCenter, 0);

    CGGradientRelease(glossGradient);
    CGColorSpaceRelease(rgbColorspace);
}

@end

@interface ProgressView ()

@property (readwrite, nonatomic, strong) UIView *backgroundView;
@property (readwrite, nonatomic, strong) UIView *viewRef;

//- (void) startTimerForAutoHide;
//- (void) hideAfterDelay:(NSTimeInterval)delayInSecs withAnimation:(HUDAnimation)animation;

@end

@implementation ProgressView
@synthesize backgroundView;
@synthesize displayDuration;
@synthesize topLabel;
@synthesize bottomLabel;

#define kHUDDefaultAlphaValue 0.65
#define kHUDDefaultDisplayDuration 2

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		
        //setup defualts
        self.cornerRadius = 20.0f;
        self.borderColor = nil;
        self.borderWidth = 2;
        self.opacity = kHUDDefaultAlphaValue;
        
		self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | 
								UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        // Initialization code.
		double offset = frame.size.height/4.0;
		topLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, offset/3.0, frame.size.width, offset/2)];
		topLabel.backgroundColor=[UIColor clearColor];
		topLabel.textColor=[UIColor whiteColor];
		topLabel.font=[UIFont boldSystemFontOfSize:17];
		topLabel.shadowColor=[UIColor blackColor];
		topLabel.shadowOffset=CGSizeMake(1, 1);
		topLabel.textAlignment=NSTextAlignmentCenter;
		
		bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height-2*offset/3.0, frame.size.width, offset/2)];
		bottomLabel.backgroundColor=[UIColor clearColor];
		bottomLabel.textColor=[UIColor whiteColor];
		bottomLabel.font=[UIFont boldSystemFontOfSize:17];
		bottomLabel.shadowColor=[UIColor blackColor];
		bottomLabel.shadowOffset=CGSizeMake(1, 1);
		
		bottomLabel.textAlignment=NSTextAlignmentCenter;
		image=nil;
		
		self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		backgroundView.layer.cornerRadius = self.cornerRadius;//frame.size.height/2;
        backgroundView.layer.borderWidth = self.borderWidth;
        backgroundView.layer.borderColor = self.borderColor.CGColor;
		backgroundView.backgroundColor = [UIColor blackColor];
		backgroundView.alpha = self.opacity;
		
		//offset=frame.size.width/3.0;
		imageView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width/4.0, frame.size.height/4.0, 
																  frame.size.width/2.0, frame.size.height/2.0)];
		imageView.contentMode=UIViewContentModeCenter;
		if ([imageView.layer respondsToSelector:@selector(setShadowColor:)]) {
		imageView.layer.shadowColor=[[UIColor blackColor] CGColor];
			imageView.layer.shadowOffset = CGSizeMake(0, 1);
			imageView.layer.shadowOpacity = 1.0;
			imageView.layer.shadowRadius = 0.0;
		}
		activityIndicator=nil;
		[self addSubview:backgroundView];
		[self addSubview:imageView];
		[self addSubview:topLabel];
		[self addSubview:bottomLabel];
		self.userInteractionEnabled=NO;
		displayDuration=kHUDDefaultDisplayDuration;
		
    }
    return self;
}

- (void)dealloc
{
    //do something
}

+(ProgressView*) defaultHUDWithSize:(CGSize)size
{
	if (defaultHUD==nil)
		defaultHUD=[[ProgressView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
	return defaultHUD;
}

-(void) setTopText:(NSString *)t
{
	topLabel.text=t;
}

-(NSString*) topText
{
	return topLabel.text;
}

-(void) setBottomText:(NSString *)t
{
	bottomLabel.text=t;
}

-(NSString*) bottomText
{
	return bottomLabel.text;
}

/** this disables the activity indicator on if any. */
-(void) setImage:(UIImage*)img
{
	imageView.image=img;
	if (activityIndicatorOn)
		self.activityIndicatorOn=NO;
}

-(UIImage*) image
{
	return imageView.image;
}

-(BOOL) activityIndicatorOn
{
	return activityIndicatorOn;
}

-(void) setActivityIndicatorOn:(BOOL)isOn
{
	if (activityIndicatorOn!=isOn) {
		activityIndicatorOn=isOn;
		if (activityIndicatorOn) {
			activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
			[activityIndicator startAnimating];
			activityIndicator.center=CGPointMake(self.bounds.size.width/2.0, self.bounds.size.height/2.0);
			imageView.hidden=YES;
			[self addSubview:activityIndicator];
		} else {
			//when applying an image, this will auto hide the HUD.
			[activityIndicator removeFromSuperview];
			imageView.hidden=NO;
			activityIndicator=nil;
		}
	}
}

-(void) layoutSubviews
{
	[super layoutSubviews];
}

-(void) showInView:(UIView*)view {
    self.isVisible = YES;
	[self showInView:view withAnimation:HUDAnimationNone];
}

-(void) showInView:(UIView *)view withAnimation:(HUDAnimation)animation
{
	//NSLog(@"HUD showing in view %@ | %@", view, NSStringFromCGRect(view.bounds));
    self.viewRef = view;
    self.viewRef.userInteractionEnabled = NO;
	switch (animation) {
		case HUDAnimationNone:
			self.alpha=1.0;
			self.transform=CGAffineTransformMakeScale(1, 1);
			self.center=CGPointMake(view.bounds.size.width/2.0, view.bounds.size.height/2.0);
			[view addSubview:self];
			break;
		case HUDAnimationShowZoom:
			self.center=CGPointMake(view.bounds.size.width/2.0, view.bounds.size.height/2.0);
			self.alpha=0;
			self.transform=CGAffineTransformMakeScale(1.7, 1.7);
			[view addSubview:self];
			[UIView beginAnimations:@"HUDShowZoom" context:nil];
			[UIView setAnimationDuration:0.3];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
			self.transform=CGAffineTransformMakeScale(1, 1);
			self.alpha=1.0;
			[UIView commitAnimations];
		default:
			break;
	}
	if (!activityIndicatorOn) {
		HUDAnimation disappearAnimation = HUDAnimationHideFadeOut;
		switch (animation) {
			case HUDAnimationShowZoom:
				disappearAnimation = HUDAnimationHideZoom;
				break;
			default:
				disappearAnimation = HUDAnimationHideFadeOut;
				break;
		}
		[self hideAfterDelay:displayDuration withAnimation:disappearAnimation ];
	} else {
		//invalidate current timer for hide if any.
		[displayTimer invalidate];
		displayTimer=nil;
	}
}

-(void) hideAfterDelay:(NSTimeInterval)delayDuration withAnimation:(HUDAnimation) animation
{
	[displayTimer invalidate];
	displayTimer = [NSTimer timerWithTimeInterval:delayDuration target:self selector:@selector(displayTimeOut:)
										  userInfo:[NSNumber numberWithInt:animation] repeats:NO];
	[[NSRunLoop mainRunLoop] addTimer:displayTimer forMode:NSRunLoopCommonModes];
	//displayTimer = [[NSTimer scheduledTimerWithTimeInterval:delayDuration target:self 
//												   selector:@selector(displayTimeOut:) 
//												   userInfo:[NSNumber numberWithInt:animation] repeats:NO] retain];	
}

-(void) displayTimeOut:(NSTimer*)timer
{
	displayTimer=nil;
	[self hideWithAnimation:(HUDAnimation)[[timer userInfo] intValue]];
}

-(void) hideWithAnimation:(HUDAnimation)animation
{
    self.isVisible = NO;
	switch (animation) {
		case HUDAnimationHideZoom:
			[UIView beginAnimations:@"HUDHideZoom" context:nil];
			[UIView setAnimationDuration:0.4];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
			self.transform=CGAffineTransformMakeScale(0.1, 0.1);
			self.alpha=0;
			[UIView commitAnimations];
			break;
		case HUDAnimationHideFadeOut:
			[UIView beginAnimations:@"HUDHideFade" context:nil];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDuration:1.0];
			self.alpha=0.0;
			[UIView commitAnimations];
			break;
		case HUDAnimationNone:
		default:
            self.viewRef.userInteractionEnabled = YES;
			[self removeFromSuperview];
			break;
	}
}

-(void) animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	if (self.alpha==0.0) {
        self.viewRef.userInteractionEnabled = YES;
		[self removeFromSuperview];
	}
}

#pragma mark -
#pragma mark - getter/setter

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    if (_cornerRadius != cornerRadius) {
        _cornerRadius = cornerRadius;
        backgroundView.layer.cornerRadius = cornerRadius;
    }
}

- (void)setBorderColor:(UIColor *)borderColor
{
    if (_borderColor != borderColor) {
        _borderColor = borderColor;
        backgroundView.layer.borderColor = borderColor.CGColor;
    }
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
    if (_borderWidth != borderWidth) {
        _borderWidth = borderWidth;
        backgroundView.layer.borderWidth = borderWidth;
    }
}

- (void)setOpacity:(CGFloat)opacity
{
    if (_opacity != opacity) {
        _opacity = opacity;
        backgroundView.alpha = opacity;
    }
}

@end
