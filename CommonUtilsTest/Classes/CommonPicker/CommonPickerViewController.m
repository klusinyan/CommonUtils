//  Created by Karen Lusinyan on 18/09/14.
//  Copyright (c) 2014 Karen Lusinyan. All rights reserved.

#import "CommonPickerViewController.h"
#import "CommonPicker.h"

@interface CommonPickerViewController ()
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

@property (readwrite, nonatomic, strong) id sender;

- (IBAction)showPicker:(id)sender;

@end

@implementation CommonPickerViewController

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
                                           relativeSuperview:nil];
    
    //setup delegate, datasource
    self.commonPicker.dataSource = self;
    self.commonPicker.delegate = self;
    //self.commonPicker.toolbarHidden = YES;
    
    //setup appearance
    //self.commonPicker.toolbarBarTintColor = [UIColor whiteColor];
    //self.commonPicker.toolbarTintColor = [UIColor colorWithRed:14/255.0 green:121/255.0 blue:255/255.0 alpha:1];
    
    if (iPhone) {
        self.commonPicker.needsOverlay = YES;
        self.commonPicker.showAfterOrientationDidChange = YES;
        //self.commonPicker.pickerHeight = self.view.bounds.size.height;
        //self.commonPicker.pickerCornerradius = 10.0f;
    }
    
    [self.commonPicker showPickerWithCompletion:^{
        DebugLog(@"picker is shown");
    }];
}

#pragma mark -
#pragma mark CommonPickerDataSource protocol

- (id)pickerContent
{
    return self.pickerview;
}

/*
- (id)pickerToolbar
{
    UIView *toolbar = [[UIView alloc] init];
    toolbar.translatesAutoresizingMaskIntoConstraints = NO;
    toolbar.backgroundColor = [UIColor yellowColor];
    
    return toolbar;
}

- (CGFloat)pickerToolbarHeight
{
    return 20.0f;
}
//*/
 
- (CGFloat)pickerWidth
{
    return self.view.bounds.size.width;
}

- (CGFloat)pickerHeight
{
    BOOL prob = arc4random_uniform(2);
    if (prob) {
        return 150.0f;
    }
    else {
        return 260.0f;
    }
}

- (UIPopoverArrowDirection)pickerArrowDirection
{
    return UIPopoverArrowDirectionDown;
}

#pragma mark -
#pragma mark CommonPickerDelegate protocol

- (void)cancelActionCallback:(id)sender
{
    DebugLog(@"cancelActionCallback");
}

- (void)doneActionCallback:(id)sender
{
    DebugLog(@"doneActionCallback");
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
