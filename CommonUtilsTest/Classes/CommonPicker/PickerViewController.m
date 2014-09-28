//  Created by Karen Lusinyan on 18/09/14.
//  Copyright (c) 2014 Karen Lusinyan. All rights reserved.

#import "PickerViewController.h"
#import "CommonPicker.h"

@interface PickerViewController ()
<UIPickerViewDelegate,
UIPickerViewDataSource,
CommonPickerDelegate,
CommonPickerDataSource
>
@property (readwrite, nonatomic, strong) UIPopoverController *myPopoverController;
@property (readwrite, nonatomic, strong) IBOutlet UIButton *button;
@property (readwrite, nonatomic, strong) IBOutlet UIImageView *imageView;

@property (readwrite, nonatomic, strong) UIPickerView *pickerview;
@property (readwrite, nonatomic, strong) UIDatePicker *datePicker;
@property (readwrite, nonatomic, strong) NSArray *items;
@property (readwrite, nonatomic, strong) NSString *selectedItem;
@property (readwrite, nonatomic, strong) IBOutlet CommonPicker *commonPicker;

- (IBAction)showPicker:(id)sender;

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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([self.commonPicker isVisible]) {
        [self.commonPicker dismissPickerWithCompletion:^{
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
    
    self.items = @[@"Item1", @"Item2", @"Item3"];
    
    self.pickerview = [[UIPickerView alloc] init];
    self.pickerview.delegate = self;
    self.pickerview.dataSource = self;
    
    //for test
    self.datePicker = [[UIDatePicker alloc] init];
    self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
}

- (IBAction)showPicker:(id)sender
{
    if ([self.commonPicker isVisible]) {
        return;
    }
    self.commonPicker = [[CommonPicker alloc] initWithTarget:self
                                                      sender:sender
                                           relativeSuperview:self.imageView];
    
    //setup delegate, datasource
    self.commonPicker.dataSource = self;
    self.commonPicker.delegate = self;
    
    //setup appearance
    //self.commonPicker.toolbarBarTintColor = [UIColor whiteColor];
    //self.commonPicker.toolbarTintColor = [UIColor colorWithRed:14/255.0 green:121/255.0 blue:255/255.0 alpha:1];
    
    if (iPhone) {
        self.commonPicker.needsOverlay = YES;
        //self.commonPicker.pickerHeight = self.view.bounds.size.height;
        //self.commonPicker.pickerCornerradius = 10.0f;
    }
    else {
        //self.commonPicker.pickerWidth = self.box_argomento.frame.size.width;
        self.commonPicker.popoverArrowDirection = UIPopoverArrowDirectionUp; //default any
    }
    
    [self.commonPicker showPickerWithCompletion:^{
        DebugLog(@"picker is shown");
    }];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if ([self.commonPicker isVisible]) {
        [self.commonPicker dismissPickerWithCompletion:^{
            DebugLog(@"picker is hidden");
        }];
    }
}

#pragma mark -
#pragma mark CommonPickerDataSource protocol

- (id)pickerContent
{
    return self.pickerview;
}

#pragma mark -
#pragma mark CommonPickerDelegate protocol

- (void)pickerDidCancelShowing
{
    DebugLog(@"pickerDidCancelShowing");
}

- (void)pickerDidFinishShowing
{
    DebugLog(@"pickerDidFinishShowing");
}

#pragma mark -
#pragma mark UIPickerViewDataSource protocol

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.items count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.items objectAtIndex:row];
}

#pragma mark -
#pragma mark UIPickerViewDelegate protocol

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.selectedItem = [self.items objectAtIndex:row];
}

@end
