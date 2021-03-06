//  Copyright (c) 2013 Path, Inc.
//  See LICENSE for full license agreement.

#import "CUImage.h"
#import "FICUtilities.h"

#pragma mark External Definitions

NSString * const CUPhotoImageFormatFamily                   = @"com.commonutils.CUPhotoImageFormatFamily";
NSString * const CUPhotoSquareImage32BitBGRAFormatName      = @"com.commonutils.CUPhotoSquareImage32BitBGRAFormatName";
NSString * const CUPhotoPixelImageFormatName                = @"com.commonutils.CUPhotoPixelImageFormatName";

CGSize const CUPhotoThumnailSize = {200, 200};
CGSize const CUPhotoPixelSize = {1, 1};

#pragma mark - Class Extension

@interface CUImage () {
    NSURL *_sourceImageURL;
    NSString *_UUID;
    NSString *_thumbnailFilePath;
    BOOL _thumbnailFileExists;
    BOOL _didCheckForThumbnailFile;
}

@end

#pragma mark

@implementation CUImage

@synthesize sourceImageURL = _sourceImageURL;

#pragma mark - Property Accessors

- (UIImage *)sourceImage
{
    UIImage *sourceImage = [UIImage imageWithContentsOfFile:[_sourceImageURL path]];
    return sourceImage;
}

- (UIImage *)thumbnailImage
{
    UIImage *thumbnailImage = [UIImage imageWithContentsOfFile:[self _thumbnailFilePath]];
    return thumbnailImage;
}

- (BOOL)thumbnailImageExists
{
    BOOL thumbnailImageExists = [[NSFileManager defaultManager] fileExistsAtPath:[self _thumbnailFilePath]];
    return thumbnailImageExists;
}

#pragma mark - Image Helper Functions

static CGMutablePathRef _FICDCreateRoundedRectPath(CGRect rect, CGFloat cornerRadius)
{
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGFloat minX = CGRectGetMinX(rect);
    CGFloat midX = CGRectGetMidX(rect);
    CGFloat maxX = CGRectGetMaxX(rect);
    CGFloat minY = CGRectGetMinY(rect);
    CGFloat midY = CGRectGetMidY(rect);
    CGFloat maxY = CGRectGetMaxY(rect);
    
    CGPathMoveToPoint(path, NULL, minX, midY);
    CGPathAddArcToPoint(path, NULL, minX, maxY, midX, maxY, cornerRadius);
    CGPathAddArcToPoint(path, NULL, maxX, maxY, maxX, midY, cornerRadius);
    CGPathAddArcToPoint(path, NULL, maxX, minY, midX, minY, cornerRadius);
    CGPathAddArcToPoint(path, NULL, minX, minY, minX, midY, cornerRadius);
    
    return path;
}

static UIImage * _FICDSquareImageFromImage(UIImage *image)
{
    UIImage *squareImage = nil;
    CGSize imageSize = [image size];
    
    if (imageSize.width == imageSize.height) {
        squareImage = image;
    } else {
        // Compute square crop rect
        CGFloat smallerDimension = MIN(imageSize.width, imageSize.height);
        CGRect cropRect = CGRectMake(0, 0, smallerDimension, smallerDimension);
        
        // Center the crop rect either vertically or horizontally, depending on which dimension is smaller
        if (imageSize.width <= imageSize.height) {
            cropRect.origin = CGPointMake(0, rintf((imageSize.height - smallerDimension) / 2.0));
        } else {
            cropRect.origin = CGPointMake(rintf((imageSize.width - smallerDimension) / 2.0), 0);
        }
        
        CGImageRef croppedImageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
        squareImage = [UIImage imageWithCGImage:croppedImageRef];
        CGImageRelease(croppedImageRef);
    }
    
    return squareImage;
}

// not used
/*
static UIImage * _FICDStatusBarImageFromImage(UIImage *image)
{
    CGSize imageSize = [image size];
    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    CGRect cropRect = CGRectMake(0, 0, imageSize.width, statusBarSize.height);
    
    CGImageRef croppedImageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    UIImage *statusBarImage = [UIImage imageWithCGImage:croppedImageRef];
    CGImageRelease(croppedImageRef);
    
    return statusBarImage;
}
//*/
 
#pragma mark - Conventional Image Caching Techniques

- (NSString *)_thumbnailFilePath
{
    if (!_thumbnailFilePath) {
        NSURL *photoURL = [self sourceImageURL];
        _thumbnailFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[[photoURL absoluteString] lastPathComponent]];
    }
    
    return _thumbnailFilePath;
}

// not used
- (void)generateThumbnail
{
    NSString *thumbnailFilePath = [self _thumbnailFilePath];
    if (!_didCheckForThumbnailFile) {
        _didCheckForThumbnailFile = YES;
        _thumbnailFileExists = [[NSFileManager defaultManager] fileExistsAtPath:thumbnailFilePath];
    }
    
    if (_thumbnailFileExists == NO) {
        CGFloat screenScale = [[UIScreen mainScreen] scale];
        CGRect contextBounds = CGRectZero;
        contextBounds.size = CGSizeMake(CUPhotoThumnailSize.width * screenScale, CUPhotoThumnailSize.height * screenScale);
        
        UIImage *sourceImage = [self sourceImage];
        UIImage *squareImage = _FICDSquareImageFromImage(sourceImage);

        UIGraphicsBeginImageContext(contextBounds.size);
        
        [squareImage drawInRect:contextBounds];
        UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        NSData *scaledImageJPEGRepresentation = UIImageJPEGRepresentation(scaledImage, 0.8);
        
        [scaledImageJPEGRepresentation writeToFile:thumbnailFilePath atomically:NO];
        
        UIGraphicsEndImageContext();
        _thumbnailFileExists = YES;
    }
}

// not used
- (void)deleteThumbnail
{
    [[NSFileManager defaultManager] removeItemAtPath:[self _thumbnailFilePath] error:NULL];
    _thumbnailFileExists = NO;
}

#pragma mark - Protocol Implementations

#pragma mark - FICImageCacheEntity

- (NSString *)UUID
{
    if (_UUID == nil) {
        // MD5 hashing is expensive enough that we only want to do it once
        NSString *imageName = [_sourceImageURL lastPathComponent];
        CFUUIDBytes UUIDBytes = FICUUIDBytesFromMD5HashOfString(imageName);
        _UUID = FICStringWithUUIDBytes(UUIDBytes);
    }
    
    return _UUID;
}

- (NSString *)sourceImageUUID
{
    return [self UUID];
}

- (NSURL *)sourceImageURLWithFormatName:(NSString *)formatName
{
    return _sourceImageURL;
}

- (FICEntityImageDrawingBlock)drawingBlockForImage:(UIImage *)image withFormatName:(NSString *)formatName
{
    FICEntityImageDrawingBlock drawingBlock = ^(CGContextRef contextRef, CGSize contextSize) {
        
        // context
        CGRect contextBounds = CGRectZero;
        contextBounds.size = contextSize;
        CGContextClearRect(contextRef, contextBounds);
        
        // squared image
        UIImage *squareImage = _FICDSquareImageFromImage(image);
        
        // rounded image
        CGPathRef path = _FICDCreateRoundedRectPath(contextBounds, 20);
        CGContextAddPath(contextRef, path);
        CFRelease(path);
        CGContextEOClip(contextRef);

        // draw
        UIGraphicsPushContext(contextRef);
        [squareImage drawInRect:contextBounds];
        UIGraphicsPopContext();
    };
    
    return drawingBlock;
}

@end
