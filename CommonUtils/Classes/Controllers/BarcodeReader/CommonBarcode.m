//  Created by Karen Lusinyan on 12/05/14.

#import "CommonBarcode.h"

NSString * const CommonBarcodeErrorDomain = @"commonutils.domain.error";

typedef NS_ENUM(NSInteger, CBErrorCode)
{
    commonBarcodeErrorCodeCustom = 0,
    commonBarcodeErrorCodePermissionDenied,
    commonBarcodeErrorCodeSimulator,
};

@interface CommonBarcode () <AVCaptureMetadataOutputObjectsDelegate, UIAlertViewDelegate>

//avcapture...
@property (readwrite, nonatomic, strong) AVCaptureDevice *captureDevice;
@property (readwrite, nonatomic, strong) AVCaptureSession *captureSession;
@property (readwrite, nonatomic, strong) AVCaptureDeviceInput *videoInput;
@property (readwrite, nonatomic, strong) AVCaptureMetadataOutput *metadataOutput;

//preview layer
@property (readwrite, nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (readwrite, nonatomic, strong) CALayer *line;
@property (readwrite, nonatomic, strong) CALayer *cropLayer;

@property (readwrite, nonatomic, assign) BOOL alreadyScanned;

@end

@implementation CommonBarcode

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
    
    if (self.flashEnabled) {
        if (self.captureDevice.hasFlash) {
            
            //switch off on-start
            [self.captureDevice lockForConfiguration:nil];
            [self.captureDevice setFlashMode:AVCaptureFlashModeOff];
            [self.captureDevice unlockForConfiguration];
            
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Flash"
                                                                                      style:UIBarButtonItemStyleBordered
                                                                                     target:self
                                                                                     action:@selector(flash:)];
        }
    }
}

//handle flash
- (void)flash:(id)sender
{
    if (self.captureDevice.isFlashActive) {
        [self.captureDevice lockForConfiguration:nil];
        [self.captureDevice setFlashMode:AVCaptureFlashModeOff];
        [self.captureDevice unlockForConfiguration];
    }
    else {
        [self.captureDevice lockForConfiguration:nil];
        [self.captureDevice setFlashMode:AVCaptureFlashModeOn];
        [self.captureDevice unlockForConfiguration];
    }
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
    self.metadataOutput.rectOfInterest = self.cropLayer.bounds;
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

- (void)startCapturing
{
    [self startCapturingWithCompletion:nil];
}

- (void)startCapturingWithCompletion:(void (^)(NSError *error))completion
{
    if (TARGET_IPHONE_SIMULATOR){
        
        NSError *error = [[NSError alloc] initWithDomain:CommonBarcodeErrorDomain
                                                    code:commonBarcodeErrorCodeSimulator
                                                userInfo:@{
                                                           NSLocalizedDescriptionKey:NSLocalizedString(@"CommonBarcode_simulator_not_working", nil)
                                                           }];
        
        if (completion) {
            completion(error);
        }
        return;
    }
    
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        // Will get here on both iOS 7 & 8 even though camera permissions weren't required
        // until iOS 8. So for iOS 7 permission will always be granted.
        if (granted) {
            // Permission has been granted. Use dispatch_async for any UI updating
            // code because this block may be executed in a thread.
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //[self doStuff];
                DebugLog(@"GRANTED");
                if (![self.captureSession isRunning]) {
                    [self.captureSession startRunning];
                    [self adjustOrientationWithInterfaceOrientation:self.interfaceOrientation];
                    self.alreadyScanned = NO;
                    if (self.captureDevice.isFlashAvailable || self.captureDevice.isTorchAvailable) {
                        [self.captureDevice lockForConfiguration:nil];
                        [self.captureDevice setFlashMode:AVCaptureFlashModeAuto];
                        [self.captureDevice setTorchMode:AVCaptureTorchModeAuto];
                        [self.captureDevice unlockForConfiguration];
                    }
                }
                
                if (completion) {
                    completion(nil);
                }
                
            });
        } else {
            // Permission has been denied.
            DebugLog(@"PERMISSION DENIED");
            NSError *error = [[NSError alloc] initWithDomain:CommonBarcodeErrorDomain
                                                        code:commonBarcodeErrorCodePermissionDenied
                                                    userInfo:@{
                                                               NSLocalizedDescriptionKey:NSLocalizedString(@"CommonBarcode_simulator_permission_denied", nil)
                                                               }];
            
            if (completion) {
                completion(error);
            }
        }
    }];
    
    
}

- (void)stopCapturing
{
    if (TARGET_IPHONE_SIMULATOR) return;
    
    if ([self.captureSession isRunning]) {
        [self.captureSession stopRunning];
        if (self.captureDevice.isFlashAvailable || self.captureDevice.isFlashAvailable) {
            [self.captureDevice lockForConfiguration:nil];
            [self.captureDevice setTorchMode:AVCaptureTorchModeOff];
            [self.captureDevice setFlashMode:AVCaptureFlashModeOff];
            [self.captureDevice unlockForConfiguration];
        }
    }
}

#pragma mark -
#pragma mark getter/setter

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

- (AVCaptureDevice *)captureDevice
{
    if (!_captureDevice) {
        _captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    return _captureDevice;
}

- (AVCaptureDeviceInput *)videoInput
{
    if (!_videoInput) {
        _videoInput = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDevice error:NULL];
    }
    return _videoInput;
}

- (AVCaptureMetadataOutput *)metadataOutput
{
    if (!_metadataOutput) {
        _metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    }
    return _metadataOutput;
}

- (AVCaptureSession *)captureSession
{
    if (!_captureSession) {
        _captureSession = [[AVCaptureSession alloc] init];
        
        [_captureSession addInput:self.videoInput];
        [_captureSession addOutput:self.metadataOutput];
        
        //set supported bar code
        [self.metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        [self.metadataOutput setMetadataObjectTypes:self.supportedBarcodes];
        
        //add sublayer to prviewContainer
        [self.previewContainer.layer addSublayer:self.previewLayer];
    }
    
    return _captureSession;
}

- (AVCaptureVideoPreviewLayer *)previewLayer
{
    if (!_previewLayer && self.captureSession) {
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
        //_previewLayer.cornerRadius = self.cornerRadius;
        [_previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        
        self.cropLayer = [CALayer layer];
        self.cropLayer.backgroundColor = [UIColor whiteColor].CGColor;
        self.cropLayer.opacity = 0.2;
        self.cropLayer.cornerRadius = self.cornerRadius;
        [_previewLayer addSublayer:self.cropLayer];
        
        self.line = [CALayer layer];
        self.line.backgroundColor = self.themeColor.CGColor;
        [_previewLayer addSublayer:self.line];
        
        [self adjustFrames];
        
        /*
         CGFloat margin = 40.0f;
         CGFloat factorX = 2;
         CGFloat factorY = 0.5;
         
         CGMutablePathRef path = CGPathCreateMutable();
         CGPathMoveToPoint(path, NULL, margin/factorX, margin/factorY);
         CGPathAddLineToPoint(path, NULL, _previewLayer.bounds.size.width-margin/factorX, margin/factorY);
         CGPathAddLineToPoint(path, NULL, _previewLayer.bounds.size.width-margin/factorX, _previewLayer.bounds.size.height-margin/factorY);
         CGPathAddLineToPoint(path, NULL, margin/factorX, _previewLayer.bounds.size.height-margin/factorY);
         CGPathCloseSubpath(path);
         
         CAShapeLayer *cropShapeLayer = [CAShapeLayer layer];
         cropShapeLayer.fillColor = [UIColor whiteColor].CGColor;
         cropShapeLayer.opacity = 0.1;
         cropShapeLayer.path = path;
         [_previewLayer addSublayer:cropShapeLayer];
         //*/
    }
    return _previewLayer;
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

#pragma mark
#pragma mark - Handle orientation changes

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self adjustFrames];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (self.captureSession.isRunning) {
        [self adjustOrientationWithInterfaceOrientation:self.interfaceOrientation];
    }
}

#pragma mark
#pragma mark - BarcodeReaderDelegate protocol

- (void)capturedCode:(NSString *)code
{
    //override
}

#pragma mark - Alert View
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
}

@end
