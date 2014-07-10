//  Created by Karen Lusinyan on 18/04/14.

#import "ModalViewController.h"

@interface ModalViewController ()

@property(readwrite, nonatomic, strong) IBOutlet UIImageView *imageView;

@end

@implementation ModalViewController

-(void)styleFriendProfileImage:(UIImageView*)imageView
                withImageNamed:(NSString*)imageName
                      andColor:(UIColor*)color{
    
    imageView.image = [UIImage imageNamed:imageName];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    imageView.layer.borderWidth = 5.0f;
    imageView.layer.borderColor = color.CGColor;
    imageView.layer.cornerRadius = imageView.bounds.size.width/2;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

    ///*
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                          target:self
                                                                                          action:@selector(dismissController)];
    //*/
     
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissController)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    //[self.view addGestureRecognizer:tapGesture];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    DebugLog(@"%s",__FUNCTION__);
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    [super willMoveToParentViewController:parent];
    DebugLog(@"%s",__FUNCTION__);
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    [super didMoveToParentViewController:parent];
    DebugLog(@"%s",__FUNCTION__);
}

- (void)dismissController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
