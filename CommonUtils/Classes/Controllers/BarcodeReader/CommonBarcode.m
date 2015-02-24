//  Created by Karen Lusinyan on 12/05/14.

#import "CommonBarcode.h"

NSString * const CommonBarcodeErrorDomain = @"commonutils.domain.error";

typedef NS_ENUM(NSInteger, CBErrorCode) {
    CommonBarcodeErrorCodeCustom = 0,
    CommonBarcodeErrorCodePermissionDenied,
    CommonBarcodeErrorCodeSimulator,
};

@interface CommonBarcode () <AVCaptureMetadataOutputObjectsDelegate, UIAlertViewDelegate>

//avcapture...
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

@end

@implementation CommonBarcode

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self stopCapturing];
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
        self.flashEnabled = NO;
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
        self.flashEnabled = NO;
        self.sound = 1109;
        self.EAN13ZeroPadding = NO;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.captureDevice.isTorchActive && self.flashEnabled) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Flash"
                                                                                  style:UIBarButtonItemStyleBordered
                                                                                 target:self
                                                                                 action:@selector(flash:)];
    }

    //TODO
    /*
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidChangeStatusBarOrientationNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * __unused notification) {
                                                      [self adjustFrames];
                                                      [self adjustOrientationWithInterfaceOrientation:self.interfaceOrientation];
                                                  }];
    //*/
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * __unused notification) {
                                                      DebugLog(@"applicationWillEnterForeground");
                                                  }];
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * __unused notification) {
                                                      DebugLog(@"applicationDidEnterBackground");
                                                  }];
}

//handle flash
- (void)flash:(id)sender
{
    [self swithOffTorch:self.captureDevice.isTorchActive];
}

- (void)swithOffTorch:(BOOL)off
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
        if (completion) completion(-1);
    }
}

- (void)startCapturing
{
    [self startCapturingWithCompletion:nil];
}

- (void)startCapturingWithCompletion:(void (^)(NSError *error))completion
{
    __block NSError *error = nil;
    if (TARGET_IPHONE_SIMULATOR) {
        error = [[NSError alloc] initWithDomain:CommonBarcodeErrorDomain
                                           code:CommonBarcodeErrorCodeSimulator
                                       userInfo:@{NSLocalizedDescriptionKey : NSLocalizedString(@"CommonBarcode_simulator_not_working", nil)}];
        if (completion) completion(error);
    }
    else {
        [self checkCameraPermissionsWithCompletion:^(BOOL granted) {
            if (granted) {
                [self startSession];
            }
            else {
                error = [[NSError alloc] initWithDomain:CommonBarcodeErrorDomain
                                                   code:CommonBarcodeErrorCodePermissionDenied
                                               userInfo:@{NSLocalizedDescriptionKey : NSLocalizedString(@"CommonBarcode_simulator_permission_denied", nil)}];
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
    __block NSError *error = nil;
    if (TARGET_IPHONE_SIMULATOR) {
        error = [[NSError alloc] initWithDomain:CommonBarcodeErrorDomain
                                           code:CommonBarcodeErrorCodeSimulator
                                       userInfo:@{NSLocalizedDescriptionKey : NSLocalizedString(@"CommonBarcode_simulator_not_working", nil)}];
        
        if (completion) completion(error);
    }
    else {
        [self checkCameraPermissionsWithCompletion:^(BOOL granted) {
            if (granted) {
                [self stopSession];
            }
            else {
                error = [[NSError alloc] initWithDomain:CommonBarcodeErrorDomain
                                                   code:CommonBarcodeErrorCodePermissionDenied
                                               userInfo:@{NSLocalizedDescriptionKey : NSLocalizedString(@"CommonBarcode_simulator_permission_denied", nil)}];
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
    [self adjustOrientationWithInterfaceOrientation:self.interfaceOrientation];
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
    for (AVMetadataObject *metadata in metadataObjects) {
        for (NSString *type in self.supportedBarcodes) {
            if ([metadata.type isEqualToString:type]) {
                
                if (!self.alreadyScanned) {
                    self.alreadyScanned = YES;
                    
                    //stop running scanner
                    [self stopCapturing];
                    
                    //sound if needed
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
                    if ([self respondsToSelector:@selector(capturedCode:)]) {
                        [self capturedCode:object];
                    }
                }
            }
        }
    }
}

///*
#pragma mark
#pragma mark - Handle orientation changes

- (BOOL)shouldAutorotate
{
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self adjustFrames];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self adjustOrientationWithInterfaceOrientation:self.interfaceOrientation];
}
//*/

#pragma mark
#pragma mark - BarcodeReaderDelegate protocol

- (void)capturedCode:(NSString *)code
{
    //override
}

/*
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"running"]) {
        if (!object) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}
//*/

/*
- (void)runInBackground
{
    UIApplication *application = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        //Clean up any task
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    // Start the long-running task and return immediately.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.captureSession addObserver:self
                              forKeyPath:@"running"
                                 options:NSKeyValueObservingOptionNew
                                 context:nil];
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    });
}
//*/

@end
