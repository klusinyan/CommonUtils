//  Created by Karen Lusinyan on 15/04/14.
//  Copyright (c) 2014 Parrocchia. All rights reserved.

#import "TestViewController.h"
#import "CommonSegmentedViewController.h"
#import "HostViewController.h"
#import "FirstViewController.h"
#import "NavigationControllerController.h"
#import "MainViewController.h"
#import "GDOBarcodeReader.h"
#import "ProgressViewController.h"
#import "CustomSplitController.h"
#import "CommonBookViewController.h"
#import "CommonPickerViewController.h"
#import "CommonKeyboardViewController.h"
#import "CommonProgressViewController.h"
#import "CommonSystem.h"
#import "NetworkUtils.h"

typedef NS_ENUM(NSInteger, RowType) {
    RowTypeSegementController,
    RowTypeBarcodeReader,
    RowTypeProgressView,
    RowTypeSplitController,
    RowTypeCommonBook,
    RowTypeCommonPicker,
    RowTypeCommonKeyboard,
    RowTypeCommonProgress,
    RowCount,
};

@interface TestViewController () <GDOBarcodeReaderDeleate>

@end

@implementation TestViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Common Test";
    self.navigationController.navigationBar.translucent = NO;

    self.tableView.rowHeight = 60;
    
    [CommonSystem networkInfoWithCompletion:^(NSDictionary *networkInfo) {
        DebugLog(@"networkInfo %@", networkInfo);
    }];
    
    [CommonSystem networkInfoWithCompletion:^(NSDictionary *networkInfo) {
        DebugLog(@"networkInfo %@", networkInfo);
    }];
    
    [NetworkUtils setNetworkActivityIndicatorVisible:YES];
    [NetworkUtils setNetworkActivityIndicatorVisible:YES];
    [NetworkUtils setNetworkActivityIndicatorVisible:YES];
    [NetworkUtils setNetworkActivityIndicatorVisible:YES];

    [NetworkUtils setNetworkActivityIndicatorVisible:NO];
    //[NetworkUtils setNetworkActivityIndicatorVisible:NO];
    //[NetworkUtils setNetworkActivityIndicatorVisible:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return RowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = nil;//[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    switch (indexPath.row) {
        case RowTypeSegementController:
            cell.textLabel.text = @"SegmentedController";
            break;
        case RowTypeBarcodeReader:
            cell.textLabel.text = @"BarcodeReader";
            break;
        case RowTypeProgressView:
            cell.textLabel.text = @"ProgressView";
            break;
        case RowTypeSplitController:
            cell.textLabel.text = @"SplitController";
            break;
        case RowTypeCommonBook:
            cell.textLabel.text = @"CommonBook";
            break;
        case RowTypeCommonPicker:
            cell.textLabel.text = @"CommonPicker";
            break;
        case RowTypeCommonKeyboard:
            cell.textLabel.text = @"CommonKeyboard";
            break;
        case RowTypeCommonProgress:
            cell.textLabel.text = @"CommonProgress";
            break;
        default:
            break;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case RowTypeSegementController: {
            
            FirstViewController *firstVC =
            [[FirstViewController alloc] init];
            firstVC.title = @"First";
            
            HostViewController *secondVC =
            [[HostViewController alloc] init];
            secondVC.navigationBarHidden = YES;
            
            /*
            NavigationControllerController *secondVC =
            [[NavigationControllerController alloc] initWithRootViewController:vc];
            secondVC.title = @"CustomTransition";
            //*/
            
            CommonSegmentedViewController *segmentController =
            [[CommonSegmentedViewController alloc] initWithViewControllers:@[firstVC, secondVC]];
            
            [[UISegmentedControl appearance] setBackgroundImage:[UIImage imageNamed:@"stepper_and_segment_background_normal"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
            
            [[UISegmentedControl appearance] setBackgroundImage:[UIImage imageNamed:@"stepper_and_segment_background_selected"] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
            
            [[UISegmentedControl appearance] setBackgroundImage:[UIImage imageNamed:@"stepper_and_segment_background_highlighted"] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
            
            [[UISegmentedControl appearance] setDividerImage:[UIImage imageNamed:@"stepper_and_segment_segment_divider"] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
            
            UIFontDescriptor *captionFontDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleCaption1];
            UIFont *font = [UIFont fontWithDescriptor:captionFontDescriptor size:0];
            
            NSDictionary *normalTextAttributes = @{NSForegroundColorAttributeName:[UIColor redColor], NSFontAttributeName:font};
            [[UISegmentedControl appearance] setTitleTextAttributes:normalTextAttributes forState:UIControlStateNormal];
            
            NSDictionary *selectedTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:font};
            [[UISegmentedControl appearance] setTitleTextAttributes:selectedTextAttributes forState:UIControlStateSelected];
            
            NSDictionary *highlightedTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:font};
            [[UISegmentedControl appearance] setTitleTextAttributes:highlightedTextAttributes forState:UIControlStateHighlighted];
                        
            /*
            UIView *view = [[UIView alloc] init];
            view.translatesAutoresizingMaskIntoConstraints = NO;
            view.backgroundColor = [UIColor greenColor];
            segmentController.headerView = view;
            segmentController.headerHeight = 44;
            
            UILabel *label = [[UILabel alloc] init];
            label.translatesAutoresizingMaskIntoConstraints = NO;
            label.textColor = [UIColor grayColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = @"My Label";
            label.font = [UIFont systemFontOfSize:15.0f];
            [view addSubview:label];
            
            [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-2-[label]->=2-|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:NSDictionaryOfVariableBindings(label)]];
            
            [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[label]|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:NSDictionaryOfVariableBindings(label)]];
            //*/
            
            [self.navigationController pushViewController:segmentController animated:YES];
            
            break;
        }
        case RowTypeBarcodeReader: {
            GDOBarcodeReader *barcodeReader = [[GDOBarcodeReader alloc] init];
            //barcodeReader.supportedBarcodes = @[AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeQRCode];
            barcodeReader.themeColor = [UIColor redColor];
            barcodeReader.soundOn = YES;
            barcodeReader.delegate = self;
            //barcodeReader.flashEnabled = YES;
            [self.navigationController pushViewController:barcodeReader animated:YES];
            break;
        }
        case RowTypeProgressView: {
            ProgressViewController *vc = [[ProgressViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case RowTypeSplitController: {
            CustomSplitController *vc = [[CustomSplitController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            
            break;
        }
        case RowTypeCommonBook: {
            CommonBookViewController *vc = [[CommonBookViewController alloc] initWithNibName:NSStringFromClass([CommonBookViewController class]) bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
            
            break;
        }
        case RowTypeCommonPicker: {
            CommonPickerViewController *vc =
            [[CommonPickerViewController alloc] initWithNibName:NSStringFromClass([CommonPickerViewController class]) bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
            
            break;
        }
        case RowTypeCommonKeyboard: {
            CommonKeyboardViewController *vc =
            [[CommonKeyboardViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            
            break;
        }
        case RowTypeCommonProgress: {
            CommonProgressViewController *vc =
            [[CommonProgressViewController alloc] initWithNibName:NSStringFromClass([CommonProgressViewController class]) bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
            
            break;
        }
    default:
            break;
    }
}

- (void)selectedBarcodeCode:(NSString *)code
{
    
}

- (void)capturedCode:(NSString *)code
{
    DebugLog(@"capturedCode %@", code);
}

@end
