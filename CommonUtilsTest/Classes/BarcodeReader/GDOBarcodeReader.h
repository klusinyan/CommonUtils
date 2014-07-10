//  Created by Karen Lusinyan on 09/05/14.

@protocol GDOBarcodeReaderDeleate <NSObject>

@required
- (void)selectedBarcodeCode:(NSString *)code;

@end

#import "BarcodeReader.h"

@interface GDOBarcodeReader : BarcodeReader

@property (readwrite, nonatomic, assign) id<GDOBarcodeReaderDeleate> delegate;

@end
