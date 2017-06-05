//  Created by Karen Lusinyan on 16/07/14.

#import "CommonBookContentViewController.h"
#import <CommonAnimationView.h>

@interface CommonBookContentViewController ()

@property (readwrite, nonatomic, strong)  IBOutlet CommonAnimationView *animationView;
@property (readwrite, nonatomic, strong) IBOutlet UIImageView *imageView;
@property (readwrite, nonatomic, getter=isAnimated) BOOL animated;

@end

@implementation CommonBookContentViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

+ (instancetype)instance
{
    return [[self alloc] initWithNibName:NSStringFromClass([CommonBookContentViewController class]) bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //custom init
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIColor *bgColor = [UIColor colorWithRed:245.0/255.0
                                       green:245.0/255.0
                                        blue:245.0/255.0
                                       alpha:1];
    self.view.backgroundColor = bgColor;
    self.imageView.backgroundColor = bgColor;
    
    self.imageView.image = self.image;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.isAnimated) {
        self.animated = YES;
        [self animate];
    }
}

- (void)animate
{
    self.animationView.type = CommonAnimationTypeZoomOut;
    self.animationView.delay = 0.4;
    self.animationView.duration = 0.4;
    [self.animationView startCommonAnimationCompletion:nil];
    
    /*
    self.animationView.type = CSAnimationTypeSlideDown;
    self.animationView.delay = 0.4;
    self.animationView.duration = 0.1;
    [self.animationView startCanvasAnimation];
    //*/
}

@end
