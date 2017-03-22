//  Created by Karen Lusinyan on 09/05/14.

#import "CommonBarcode.h"

typedef NS_ENUM(NSInteger, UIInterfaceType) {
    UIInterfaceTypeSimple,
    UIInterfaceTypeFull,
};

@interface CommonBarcodeController : CommonBarcode

@property (readwrite, nonatomic, assign) id <CommonBarcodeDelegate> myDelegate;

@property (readwrite, nonatomic, assign) UIInterfaceType UIInterfaceType;   //defualt UIInterfaceTypeSimple

@property (readwrite, nonatomic, retain) NSString *buttonDoneTitle;

@property (readwrite, nonatomic, retain) NSString *buttonRetryTitle;

+ (CommonBarcodeController *)barcodeReader;

@end
