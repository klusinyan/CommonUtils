//  Copyright (c) 2013 Path, Inc.
//  See LICENSE for full license agreement.

#import "FICEntity.h"

extern NSString *const CUPhotoImageFormatFamily;
extern NSString *const CUPhotoSquareImage32BitBGRAFormatName;
extern NSString *const CUPhotoPixelImageFormatName;

extern CGSize const CUPhotoThumnailSize;
extern CGSize const CUPhotoPixelSize;

@interface CUImage : NSObject <FICEntity>

@property (nonatomic, copy) NSURL *sourceImageURL;
@property (nonatomic, strong, readonly) UIImage *sourceImage;
@property (nonatomic, strong, readonly) UIImage *thumbnailImage;
@property (nonatomic, assign, readonly) BOOL thumbnailImageExists;

// not used
// Methods for demonstrating more conventional caching techniques
- (void)generateThumbnail;
- (void)deleteThumbnail;

@end
