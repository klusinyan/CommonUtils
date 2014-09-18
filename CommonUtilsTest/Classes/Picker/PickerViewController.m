//  Created by Karen Lusinyan on 18/09/14.
//  Copyright (c) 2014 Karen Lusinyan. All rights reserved.

#import "PickerViewController.h"
#import "CommonPicker.h"

@interface PickerViewController () <UIPopoverControllerDelegate>

@property (readwrite, nonatomic, strong) CommonPicker *picker;
@property (readwrite, nonatomic, strong) UIPopoverController *myPopoverController;

@end

@implementation PickerViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if ([self.picker isVisible]) {
        [self.picker dismissPickerWithCompletion:^{
            DebugLog(@"picker is hidden");
        }];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem *showPicker = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                target:self
                                                                                action:@selector(showPicker:)];
    self.navigationItem.rightBarButtonItems = @[showPicker];

    self.picker = [[CommonPicker alloc] initWithTarget:self
                                                sender:showPicker
                                             withTitle:@"My Title"
                                                 items:@[@"Item1", @"Item2", @"Item3", @"Item4"]
                                      cancelCompletion:^{
                                          DebugLog(@"cancelComepletion");
                                      } doneCompletion:^(NSString *selectedItem, NSInteger selectedIndex) {
                                          DebugLog(@"doneComepletion witb item = %@ at index %@", selectedItem, @(selectedIndex));
                                      }];
    
    self.picker.showWhenOrientationDidChange = YES;
}

- (void)showPicker:(id)sender
{
    if ([self.picker isVisible]) {
        [self.picker dismissPickerWithCompletion:^{
            DebugLog(@"picker is hidden");
        }];
    }
    else {
        [self.picker showPickerWithCompletion:^{
            DebugLog(@"picker is shown");
        }];
    }
}

@end