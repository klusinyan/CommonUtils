//  Created by Karen Lusinyan on 09/05/14.

#import "GDOBarcodeReader.h"
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import "GDOLayoutUtils.h"

@interface GDOBarcodeReader ()

//IBOutlets
@property (readwrite, nonatomic, strong) UIView *barcodeContainer;
@property (readwrite, nonatomic, strong) UIView *buttonContainer;
@property (readwrite, nonatomic, strong) UIImageView *barcodeImageView;
@property (readwrite, nonatomic, strong) UILabel *barcodeLabel;
@property (readwrite, nonatomic, strong) UIButton *btnDone;
@property (readwrite, nonatomic, strong) UIButton *btnRetry;
@property (readwrite, nonatomic, copy) NSString *code;

@end

@implementation GDOBarcodeReader

- (void)dealloc
{
    self.delegate = nil;
    [self stopCapturing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (id)init
{
    self = [super init];
    if (self) {
        //custom init
    }
    
    return self;
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.previewContainer = [[UIView alloc] init];
    self.previewContainer.translatesAutoresizingMaskIntoConstraints = NO;
    //self.previewContainer.layer.borderColor = self.themeColor.CGColor;
    //self.previewContainer.layer.borderWidth = 1.50f;
    self.previewContainer.layer.cornerRadius = 20.0f;
    [self.view addSubview:self.previewContainer];
    
    self.barcodeContainer = [[UIView alloc] init];
    //self.barcodeContainer.backgroundColor = [UIColor greenColor];
    self.barcodeContainer.translatesAutoresizingMaskIntoConstraints = NO;
    //[self.view addSubview:self.barcodeContainer];

    self.barcodeImageView = [[UIImageView alloc] init];
    self.barcodeImageView.backgroundColor = nil;
    self.barcodeImageView.translatesAutoresizingMaskIntoConstraints = NO;
    //[self.barcodeContainer addSubview:self.barcodeImageView];

    self.barcodeLabel = [[UILabel alloc] init];
    //self.barcodeLabel.backgroundColor = [UIColor lightGrayColor];
    self.barcodeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.barcodeLabel.textAlignment = NSTextAlignmentCenter;
    self.barcodeLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:22];
    self.barcodeLabel.adjustsFontSizeToFitWidth = YES;
    //[self.barcodeContainer addSubview:self.barcodeLabel];

    self.buttonContainer = [[UIView alloc] init];
    //self.buttonContainer.backgroundColor = [UIColor blueColor];
    self.buttonContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.buttonContainer];

    self.btnDone = [GDOLayoutUtils buttonWithTitle:@"Procedi" target:self action:@selector(actionDone:)];
    self.btnDone.translatesAutoresizingMaskIntoConstraints = NO;
    self.btnDone.enabled = NO;
    [self.buttonContainer addSubview:self.btnDone];
    
    self.btnRetry = [GDOLayoutUtils buttonWithTitle:@"Riprova" target:self action:@selector(actionRetry:)];
    self.btnRetry.translatesAutoresizingMaskIntoConstraints = NO;
    self.btnRetry.enabled = NO;
    [self.buttonContainer addSubview:self.btnRetry];
    
    //if (iPhone) {
 
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_previewContainer]-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_previewContainer)]];
    
    /*
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_barcodeContainer]-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_barcodeContainer)]];
    //*/
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_buttonContainer]-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_buttonContainer)]];

    /*
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_previewContainer(>=100)]->=10-[_barcodeContainer(>=100)]-[_buttonContainer(==100)]-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_previewContainer, _barcodeContainer, _buttonContainer)]];
     //*/
     
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_previewContainer(>=100)]->=10-[_buttonContainer(==100)]-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_previewContainer, _buttonContainer)]];

    /*
    [self.barcodeContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|->=0-[_barcodeImageView(==200)]->=0-|"
                                                                                  options:0
                                                                                  metrics:nil
                                                                                    views:NSDictionaryOfVariableBindings(_barcodeImageView)]];

    [self.barcodeContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|->=0-[_barcodeLabel(==200)]->=0-|"
                                                                                  options:0
                                                                                  metrics:nil
                                                                                    views:NSDictionaryOfVariableBindings(_barcodeLabel)]];
    //*/
     
    [self.buttonContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|->=0-[_btnRetry(==250)]->=0-|"
                                                                                  options:NSLayoutFormatAlignAllCenterX
                                                                                  metrics:nil
                                                                                    views:NSDictionaryOfVariableBindings(_btnRetry)]];
    
    [self.buttonContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|->=0-[_btnDone(==250)]->=0-|"
                                                                                  options:NSLayoutFormatAlignAllCenterX
                                                                                  metrics:nil
                                                                                    views:NSDictionaryOfVariableBindings(_btnDone)]];
    
    /*
    [self.barcodeContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_barcodeImageView(==100)]-(-8)-[_barcodeLabel(==40)]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_barcodeImageView, _barcodeLabel)]];
    //*/
     
    [self.buttonContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|->=10-[_btnRetry(==40)]-10-[_btnDone(==40)]|"
                                                                                  options:0
                                                                                  metrics:nil
                                                                                    views:NSDictionaryOfVariableBindings(_btnRetry, _btnDone)]];

    /*
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.barcodeImageView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.barcodeContainer
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.barcodeLabel
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.barcodeContainer
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:0]];
    //*/
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.btnRetry
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.buttonContainer
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.btnDone
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.buttonContainer
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:0]];


    //}
    /*
    if (iPad) {
        //set width
        NSLayoutConstraint *c1 = [NSLayoutConstraint constraintWithItem:self.barcodeContainer
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1
                                                               constant:300];
        //set height
        NSLayoutConstraint *c2 = [NSLayoutConstraint constraintWithItem:self.barcodeContainer
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1
                                                               constant:480];
        //set center X
        NSLayoutConstraint *c3 = [NSLayoutConstraint constraintWithItem:self.barcodeContainer
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1
                                                               constant:0];
        //set 10 poiint from top
        NSLayoutConstraint *c4 = [NSLayoutConstraint constraintWithItem:self.barcodeContainer
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1
                                                               constant:10];
        [self.view addConstraints:@[c1, c2, c3, c4]];
    }
    //*/
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        [self startCapturing];
    });
}

#pragma mark -
#pragma mark getter/setter

- (NSString *)code
{
    if (!_code) {
        _code = @"0000000000000";   //default
    }
    return _code;
}

- (void)capturedCode:(NSString *)code
{
    //save code
    self.code = code;
    
    //enable buttons
    self.btnDone.enabled = YES;
    self.btnRetry.enabled = YES;
}

- (void)actionDone:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectedBarcodeCode:)]) {
        [self.delegate selectedBarcodeCode:self.code];
    }
    if (iPad) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:^{
            //do something
        }];
    }
}

- (void)actionRetry:(id)sender
{
    [self startCapturing];
}

@end
