//  Created by Karen Lusinyan on 09/05/14.

#import "CommonBarcodeController.h"
#import "DirectoryUtils.h"

//static dispatch_once_t * once_token;

@interface CommonBarcodeController ()

//IBOutlets
@property (readwrite, nonatomic, strong) IBOutlet UIView *previewContainer;
@property (readwrite, nonatomic, strong) IBOutlet UIView *buttonContainer;
@property (readwrite, nonatomic, strong) IBOutlet UIButton *btnDone;
@property (readwrite, nonatomic, strong) IBOutlet UIButton *btnRetry;
@property (readwrite, nonatomic, copy) NSString *code;

- (IBAction)actionDone:(id)sender;
- (IBAction)actionRetry:(id)sender;

@end

@implementation CommonBarcodeController

- (void)dealloc
{
    self.delegate = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //set defaults
        self.UIInterfaceType = UIInterfaceTypeSimple;
        self.buttonDoneTitle = @"Proceed";
        self.buttonRetryTitle = @"Retry";
    }
    return self;
}

+ (CommonBarcodeController *)barcodeReader
{    
    return [[self alloc] initWithNibName:NSStringFromClass([CommonBarcodeController class]) bundle:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.UIInterfaceType == UIInterfaceTypeSimple) {
        self.buttonContainer.hidden = YES;
        self.btnDone.hidden = YES;
        self.btnRetry.hidden = YES;
    }
    
    self.btnDone.enabled = NO;
    self.btnRetry.enabled = NO;
    
    [self.btnDone setTitle:self.buttonDoneTitle forState:UIControlStateNormal];
    [self.btnRetry setTitle:self.buttonRetryTitle forState:UIControlStateNormal];
    
    [self.btnDone setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnDone setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];

    [self.btnRetry setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnRetry setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    
    self.btnDone.layer.cornerRadius = 5.0f;
    self.btnRetry.layer.cornerRadius = 5.0f;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    /*
    static dispatch_once_t pred = 0;
    once_token = &pred;
    dispatch_once(&pred, ^{
        [self startCapturingWithCompletion:^(NSError *error) {
            DebugLog(@"error %@", error);
        }];
    });
    //*/
}

#pragma mark -
#pragma mark getter/setter

- (NSString *)code
{
    if (!_code) {
        self.btnDone.enabled = YES;
        self.btnRetry.enabled = YES;
    }
    return _code;
}

#pragma mark -
#pragma mark - BarcodeReaderDelegate Protocol

//override
- (void)capturedCode:(NSString *)code
{
    //save code
    self.code = code;

    if (self.UIInterfaceType == UIInterfaceTypeSimple) {
        [self actionDone:nil];
    }
    else if (self.UIInterfaceType == UIInterfaceTypeFull) {
        
        //enable buttons
        self.btnDone.enabled = YES;
        self.btnRetry.enabled = YES;
    }
}

- (IBAction)actionDone:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectedBarcodeCode:withTarget:)]) {
        [self.delegate selectedBarcodeCode:self.code withTarget:self];
    }
}

- (IBAction)actionRetry:(id)sender
{
    [self startCapturingWithCompletion:^(NSError *error) {
        DebugLog(@"error %@", error);\
    }];
}

@end
