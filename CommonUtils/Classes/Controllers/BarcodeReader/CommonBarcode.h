//  Created by Karen Lusinyan on 12/05/14.

#import <AVFoundation/AVFoundation.h>

UIKIT_EXTERN NSString * const CBErrorDomain;

typedef NS_ENUM(NSInteger, CBErrorCode) {
    CBErrorCodeUnknown          = -1001,
    CBErrorCodeTargetSimulator  = -1002,
    CBErrorCodePermissionDenied = -1003,
};

@class CommonBarcode;

@protocol CommonBarcodeDelegate <NSObject>

@required
- (void)barcode:(CommonBarcode *)barcode didFinishCapturingWithCode:(NSString *)code;
- (void)barcode:(CommonBarcode *)barcode didFailCapturingWithError:(NSError *)error;

@end

@protocol CommonBarcodeDelegate;

@interface CommonBarcode : UIViewController {
    UIView *_previewContainer;
}

@property (readwrite, nonatomic, strong) NSArray *supportedBarcodes;    //default all types AVMetadataObjectType...
@property (readwrite, nonatomic, strong) UIColor *themeColor;           //default [UIColor redColor]
@property (readwrite, nonatomic, assign) CGFloat cropFactorX;           //default 0.7 respect to previewLayer's width
@property (readwrite, nonatomic, assign) CGFloat cropFactorY;           //defautl 0.5 respect to cropLayer's width
@property (readwrite, nonatomic, assign) CGFloat cornerRadius;          //default 0.0f
@property (readwrite, nonatomic, assign) BOOL soundOn;                  //default YES
@property (readwrite, nonatomic, assign) BOOL manualStart;              //defualt NO
@property (readwrite, nonatomic, assign) unsigned int sound;            //default 1109
@property (readonly,  nonatomic, strong) NSString *capturedCode;        //defualt nil
@property (readwrite, nonatomic, assign) BOOL EAN13ZeroPadding;         //default NO

@property (readwrite, nonatomic, assign) id<CommonBarcodeDelegate> delegate;

//add more configurations...
@property (readonly, nonatomic, strong) AVCaptureDevice *captureDevice;
@property (readonly, nonatomic, strong) AVCaptureSession *captureSession;
@property (readonly, nonatomic, strong) AVCaptureDeviceInput *deviceInput;
@property (readonly, nonatomic, strong) AVCaptureMetadataOutput *captureMetadataOutput;

//preview container
//should be set in subclasses
@property (readwrite, nonatomic, strong) IBOutlet UIView *previewContainer; //deault nil (if not overriden will throw an exception)

//without xib
- (id)init;

//with xib
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;

- (BOOL)hasFlash;

- (void)setFlashOn:(BOOL)on;

- (void)startCapturing __deprecated_msg("use: startCapturingWithCompletion:");

- (void)startCapturingWithCompletion:(void (^)(NSError *error))completion;

- (void)stopCapturing __deprecated_msg("use: stopCapturingWithCompletion:");;

- (void)stopCapturingWithCompletion:(void (^)(NSError *error))completion;

@end
