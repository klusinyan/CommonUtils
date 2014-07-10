//  Created by Karen Lusinyan on 12/05/14.

@protocol BarcodeReaderDelegate <NSObject>

@required
- (void)capturedCode:(NSString *)code;

@end

#import <AVFoundation/AVFoundation.h>

@interface BarcodeReader : UIViewController <BarcodeReaderDelegate> {
    UIView *_previewContainer;
}

@property (readwrite, nonatomic, strong) NSArray *supportedBarcodes;    //default all
@property (readwrite, nonatomic, strong) UIColor *themeColor;           //default [UIColor redColor]
@property (readwrite, nonatomic, assign) CGFloat cropFactorX;           //default 0.7 respect to previewLayer's width
@property (readwrite, nonatomic, assign) CGFloat cropFactorY;           //defautl 0.5 respect to cropLayer's width
@property (readwrite, nonatomic, assign) CGFloat cornerRadius;          //default 0.0f
@property (readwrite, nonatomic, assign) BOOL soundOn;                  //default YES
@property (readwrite, nonatomic, assign) BOOL flashEnabled;             //defualt NO
@property (readwrite, nonatomic, assign) unsigned int sound;            //default 1109
@property (readonly,  nonatomic, strong) NSString *capturedCode;        //defualt nil
@property (readwrite, nonatomic, assign) BOOL EAN13ZeroPadding;         //default NO

//add more configurations...
@property (readonly, nonatomic, strong) AVCaptureDevice *captureDevice;
@property (readonly, nonatomic, strong) AVCaptureSession *captureSession;
@property (readonly, nonatomic, strong) AVCaptureDeviceInput *videoInput;
@property (readonly, nonatomic, strong) AVCaptureMetadataOutput *metadataOutput;

//preview container
//should be set in subclasses
@property (readwrite, nonatomic, strong) UIView *previewContainer;      //deault nil (if not overriden will throw an exception)

//without xib
- (id)init;

//with xib
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;

- (void)startCapturing;

- (void)stopCapturing;

@end
