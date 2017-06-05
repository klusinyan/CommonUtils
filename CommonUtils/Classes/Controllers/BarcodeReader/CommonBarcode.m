//  Created by Karen Lusinyan on 12/05/14.

#import "CommonBarcode.h"
#import "CommonSpinner.h"
#import "DirectoryUtils.h"

#define kBundleName @"CommonUtils.bundle/CommonBarcode.bundle"

NSString * const CBErrorDomain = @"commonutils.commonbarcode.domain.error";

//value are corresponding to localized strings's keys
NSString * const CBLocalizedStringInitializingMsg = @"CBLocalizedStringInitializingMsg";
NSString * const CBErrorUnknwon             = @"CBLocalizedStringUnknownError";
NSString * const CBErrorTargetSimulator     = @"CBLocalizedStringTargetSimulator";
NSString * const CBErrorPermissionDenied    = @"CBLocalizedStringPermissionDenied";

@interface CommonBarcode () <AVCaptureMetadataOutputObjectsDelegate, UIAlertViewDelegate>

//avcapture
@property (readwrite, nonatomic, strong) AVCaptureDevice *captureDevice;
@property (readwrite, nonatomic, strong) AVCaptureSession *captureSession;
@property (readwrite, nonatomic, strong) AVCaptureDeviceInput *deviceInput;
@property (readwrite, nonatomic, strong) AVCaptureMetadataOutput *captureMetadataOutput;

//preview layer
@property (readwrite, nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (readwrite, nonatomic, strong) CALayer *line;
@property (readwrite, nonatomic, strong) CALayer *cropLayer;

@property (readwrite, nonatomic, assign) BOOL alreadyScanned;
@property (readwrite, nonatomic, getter=isSessionStarted) BOOL sessionStarted;
@property (readwrite, nonatomic, getter=isRunning) BOOL running;
@property (readwrite, nonatomic, strong) CommonSpinner *commonSpinner;

@end

@implementation CommonBarcode

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self stopCapturingWithCompletion:nil];
    self.delegate = nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        
        //setup defaults
        self.themeColor = nil;
        self.cropFactorX = 0.7;
        self.cropFactorY = 0.5;
        self.cornerRadius = 0.0f;
        self.soundOn = YES;
        self.sound = 1109;
        self.EAN13ZeroPadding = NO;
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        
        //setup defaults
        self.themeColor = nil;
        self.cropFactorX = 0.7;
        self.cropFactorY = 0.5;
        self.cornerRadius = 0.0f;
        self.soundOn = YES;
        self.sound = 1109;
        self.EAN13ZeroPadding = NO;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupDevice];
}

- (void)viewDidLayoutSubviews
{
    [self adjustFrames];
    [self adjustOrientationWithInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stopSession)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(startSession)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    if (!self.manualStart) {
        self.previewContainer.backgroundColor = [UIColor blackColor];
        
        if (self.commonSpinner != nil) {
            [self.commonSpinner hideWithCompletion:nil];
        }
        
        self.commonSpinner = [CommonSpinner instance];
        [self.commonSpinner setTintColor:[UIColor grayColor]];
        [self.commonSpinner setHidesWhenStopped:YES];
        [self.commonSpinner setNetworkActivityIndicatorVisible:NO];
        [self.commonSpinner setTitle:[DirectoryUtils localizedStringForKey:CBLocalizedStringInitializingMsg bundleName:kBundleName]];
        
        [self.commonSpinner showInView:self.view completion:^{
            [self startCapturingWithCompletion:^(NSError *error) {
                if (error) {
                    NSString *errMessage = nil;
                    switch (error.code) {
                        case CBErrorCodeTargetSimulator:
                            errMessage = CBErrorTargetSimulator;
                            break;
                        case CBErrorCodePermissionDenied:
                            errMessage = CBErrorPermissionDenied;
                            break;
                        default:
                            errMessage = CBErrorUnknwon;
                            break;
                    }
                    NSString *localizedString = [DirectoryUtils localizedStringForKey:errMessage bundleName:kBundleName];
                    [self.commonSpinner setTitleOnly:localizedString activityIndicatorVisible:NO];
                    if (self.delegate && [self.delegate respondsToSelector:@selector(barcode:didFailCapturingWithError:)]) {
                        [self.delegate barcode:self didFailCapturingWithError:error];
                    }
                }
                else {
                    [self.commonSpinner hideWithCompletion:nil];
                }
            }];
        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
    
    //switch-off torch if it's on
    if (self.captureDevice.isTorchAvailable) {
        [self switchOffTorch:YES];
    }
    
    self.delegate = nil;
}

//handle flash
- (void)flash:(id)sender
{
    [self switchOffTorch:self.captureDevice.isTorchActive];
}

- (void)switchOffTorch:(BOOL)off
{
    [self.captureDevice lockForConfiguration:nil];
    if (off)
        [self.captureDevice setTorchMode:AVCaptureTorchModeOff];
    else
        [self.captureDevice setTorchMode:AVCaptureTorchModeOn];
    [self.captureDevice unlockForConfiguration];
}

//frame utilities
- (void)adjustFrames
{
    //preview
    self.previewLayer.frame = self.previewContainer.layer.bounds;
    
    //cropLayer
    CGFloat factorWidth = _previewLayer.bounds.size.width*self.cropFactorX;
    self.cropLayer.frame = CGRectMake(0, 0, factorWidth, factorWidth*self.cropFactorY);
    self.cropLayer.position = _previewLayer.position;
    
    //line
    self.line.frame = CGRectMake(0, 0, factorWidth+20, 2);
    self.line.position = _previewLayer.position;
    
    //set rect of interest to cropRect
    self.captureMetadataOutput.rectOfInterest = self.cropLayer.bounds;
}

- (void)adjustOrientationWithInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([self.previewLayer.connection isVideoOrientationSupported]) {
        switch (interfaceOrientation) {
            case UIInterfaceOrientationPortrait:
                self.previewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
                self.previewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
                break;
            case UIInterfaceOrientationLandscapeLeft:
                self.previewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
                break;
            case UIInterfaceOrientationLandscapeRight:
                self.previewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
                break;
            default:
                break;
        }
    }
}

- (void)checkCameraPermissionsWithCompletion:(void (^)(BOOL granted))completion
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusAuthorized) {
        if (completion) completion(YES);
    } else if(authStatus == AVAuthorizationStatusDenied) {
        if (completion) completion(NO);
    } else if(authStatus == AVAuthorizationStatusRestricted) {
        if (completion) completion(NO);
    } else if(authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(granted);
            });
        }];
    }
    else {
        if (completion) completion(NO);
    }
}

- (BOOL)hasFlash
{
    return ([self.captureDevice hasFlash] && [self.captureDevice hasTorch]);
}

- (void)setFlashOn:(BOOL)on
{
    if ([self.captureDevice hasFlash] && [self.captureDevice hasTorch]) {
        [self.captureDevice lockForConfiguration:NULL];
        if (on) {
            self.captureDevice.flashMode = AVCaptureFlashModeOn;
            self.captureDevice.torchMode = AVCaptureTorchModeOn;
        }
        else {
            self.captureDevice.flashMode = AVCaptureFlashModeOff;
            self.captureDevice.torchMode = AVCaptureTorchModeOff;
        }
        [self.captureDevice unlockForConfiguration];
    }
}

- (void)startCapturing
{
    [self startCapturingWithCompletion:nil];
}

- (void)startCapturingWithCompletion:(void (^)(NSError *error))completion
{
    [self addAnimations];

    __block NSError *error = nil;
    if (TARGET_IPHONE_SIMULATOR) {
        error = [[NSError alloc] initWithDomain:CBErrorDomain
                                           code:CBErrorCodeTargetSimulator
                                       userInfo:@{NSLocalizedDescriptionKey :
                                                      [DirectoryUtils localizedStringForKey:CBErrorTargetSimulator
                                                                                 bundleName:kBundleName]}];
        if (completion) completion(error);
    }
    else {
        [self checkCameraPermissionsWithCompletion:^(BOOL granted) {
            if (granted) {
                [self startSession];
            }
            else {
                error = [[NSError alloc] initWithDomain:CBErrorDomain
                                                   code:CBErrorCodePermissionDenied
                                               userInfo:@{NSLocalizedDescriptionKey :
                                                              [DirectoryUtils localizedStringForKey:CBErrorPermissionDenied bundleName:kBundleName]}];
            }
            if (completion) completion(error);
        }];
    }
}

- (void)stopCapturing
{
    [self stopCapturingWithCompletion:nil];
}

- (void)stopCapturingWithCompletion:(void (^)(NSError *error))completion
{
    [self removeAnimations];

    __block NSError *error = nil;
    if (TARGET_IPHONE_SIMULATOR) {
        error = [[NSError alloc] initWithDomain:CBErrorDomain
                                           code:CBErrorCodeTargetSimulator
                                       userInfo:@{NSLocalizedDescriptionKey : [DirectoryUtils localizedStringForKey:CBErrorTargetSimulator bundleName:kBundleName]}];
        
        if (completion) completion(error);
    }
    else {
        [self checkCameraPermissionsWithCompletion:^(BOOL granted) {
            if (granted) {
                [self stopSession];
            }
            else {
                error = [[NSError alloc] initWithDomain:CBErrorDomain
                                                   code:CBErrorCodePermissionDenied
                                               userInfo:@{NSLocalizedDescriptionKey : [DirectoryUtils localizedStringForKey:CBErrorPermissionDenied bundleName:kBundleName]}];
            }
            if (completion) completion(error);
        }];
    }
}

- (void)setupDevice
{
    self.captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
}

- (void)setupDeviceInput
{
    self.deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDevice error:NULL];
}

- (void)setupMetadataOutput
{
    self.captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
}

- (void)setupSession
{
    self.captureSession = [[AVCaptureSession alloc] init];
    
    [self.captureSession addInput:self.deviceInput];
    [self.captureSession addOutput:self.captureMetadataOutput];
    
    [self.captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [self.captureMetadataOutput setMetadataObjectTypes:self.supportedBarcodes];
}

- (void)setupLayer
{
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    //_previewLayer.cornerRadius = self.cornerRadius;
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    self.cropLayer = [CALayer layer];
    self.cropLayer.backgroundColor = [UIColor whiteColor].CGColor;
    self.cropLayer.opacity = 0.2;
    self.cropLayer.cornerRadius = self.cornerRadius;
    [self.previewLayer addSublayer:self.cropLayer];
    
    self.line = [CALayer layer];
    self.line.backgroundColor = self.themeColor.CGColor;
    [self.previewLayer addSublayer:self.line];
    
    //add sublayer to prviewContainer
    [self.previewContainer.layer addSublayer:self.previewLayer];
    
    [self adjustFrames];
    [self adjustOrientationWithInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    [self addAnimations];
}

- (void)addAnimations
{
    CABasicAnimation *cropScaleX = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
    cropScaleX.fromValue = @(1);
    cropScaleX.toValue = @(1.2);
    cropScaleX.duration = 2;
    cropScaleX.beginTime = 0.0;
    
    CABasicAnimation *cropScaleY = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
    cropScaleY.fromValue = @(1);
    cropScaleY.toValue = @(1.3);
    cropScaleY.duration = 2;
    cropScaleY.beginTime = 1.0;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = 2;
    group.autoreverses = YES;
    group.repeatCount = INFINITY;
    [group setAnimations:@[cropScaleX, cropScaleY]];
    [self.cropLayer addAnimation:group forKey:@"cropScaleXY"];
    
    CABasicAnimation *lineScaleX = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
    lineScaleX.fromValue = @(1);
    lineScaleX.toValue = @(1.2);
    lineScaleX.duration = 2;
    lineScaleX.beginTime = 0.0;
    lineScaleX.autoreverses = YES;
    lineScaleX.repeatCount = INFINITY;
    [self.line addAnimation:lineScaleX forKey:@"lineScaleX"];
}

- (void)removeAnimations
{
    [self.cropLayer removeAllAnimations];
    [self.line removeAllAnimations];
}

//exact execution order
- (void)startSession
{
    @synchronized(self) {
        if (!self.isSessionStarted) {
            
            //configure
            [self setupDevice];
            [self setupDeviceInput];
            [self setupMetadataOutput];
            [self setupSession];
            [self setupLayer];
            
            //start session
            self.sessionStarted = YES;
            if (![self.captureSession isRunning]) {
                [self.captureSession startRunning];
            }
        }
        else DebugLog(@"Session is already started");
    }
}

- (void)stopSession
{
    @synchronized(self) {
        if (self.isSessionStarted) {
            
            //stop session
            self.sessionStarted = NO;
            if ([self.captureSession isRunning]) {
                [self.captureSession stopRunning];
            }
            
            //reset
            self.captureDevice = nil;
            self.deviceInput = nil;
            self.captureMetadataOutput = nil;
            self.captureSession = nil;
            self.previewLayer = nil;
        }
        else DebugLog(@"Session is already stopped");
    }
}


#pragma mark -
#pragma mark getter/setter

- (void)setSessionStarted:(BOOL)sessionStarted
{
    _sessionStarted = sessionStarted;
    if (_sessionStarted) {
        self.alreadyScanned = NO;
    }
}

- (NSArray *)supportedBarcodes
{
    if (!_supportedBarcodes) {
        _supportedBarcodes = @[AVMetadataObjectTypeUPCECode,
                               AVMetadataObjectTypeCode39Code,
                               AVMetadataObjectTypeCode39Mod43Code,
                               AVMetadataObjectTypeEAN13Code,
                               AVMetadataObjectTypeEAN8Code,
                               AVMetadataObjectTypeCode93Code,
                               AVMetadataObjectTypeCode128Code,
                               AVMetadataObjectTypePDF417Code,
                               AVMetadataObjectTypeQRCode,
                               AVMetadataObjectTypeAztecCode];
    }
    return _supportedBarcodes;
}

- (UIView *)previewContainer
{
    if (!_previewContainer) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ Failed to call previewContainer getter. Subclasses should initialize _previewContainer", NSStringFromClass([self class])] userInfo:nil];
    }
    return _previewContainer;
}

#pragma mark -
#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    @synchronized (self) {
        for (AVMetadataObject *metadata in metadataObjects) {
            for (NSString *type in self.supportedBarcodes) {
                if ([metadata.type isEqualToString:type]) {
                    
                    if (!self.alreadyScanned) {
                        self.alreadyScanned = YES;
                        
                        // stop running scanner
                        [self stopCapturingWithCompletion:nil];
                        
                        // sound if needed
                        if (self.soundOn) {
                            AudioServicesPlaySystemSound(self.sound);
                        }
                        
                        AVMetadataMachineReadableCodeObject *readableObject = (AVMetadataMachineReadableCodeObject *)metadata;
                        NSString *object = readableObject.stringValue;
                        if (self.EAN13ZeroPadding &&
                            [metadata.type isEqualToString:AVMetadataObjectTypeEAN13Code] &&
                            [readableObject.stringValue length] == 12) {
                            object = @"0";
                            object = [object stringByAppendingFormat:@"%@", readableObject.stringValue];
                        }
                        if (self.delegate && [self.delegate respondsToSelector:@selector(barcode:didFinishCapturingWithCode:)]) {
                            [self.delegate barcode:self didFinishCapturingWithCode:object];
                        }
                    }
                }
            }
        }
    }
}

@end
