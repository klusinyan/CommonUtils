//  Created by Karen Lusinyan on 16/07/14.

#import "CommonBookContentViewController.h"

@interface CommonBookContentViewController ()

@property (readwrite, nonatomic, strong) IBOutlet UIImageView *imageView;

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
    self.view.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1];
    self.imageView.image = self.image;
}

@end
