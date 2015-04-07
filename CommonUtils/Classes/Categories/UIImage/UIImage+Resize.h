// UIImage+Resize.h
// Created by Trevor Harmon on 8/5/09.
// Free for personal or commercial use, with or without modification.
// No warranty is expressed or implied.
#pragma mark version - 1.0.0

// Extends the UIImage class to support resizing/cropping
@interface UIImage (Resize)

- (UIImage *)croppedImage:(CGRect)bounds;

- (UIImage *)thumbnailImage:(CGFloat)thumbnailSize
          transparentBorder:(CGFloat)borderSize
               cornerRadius:(CGFloat)cornerRadius
       interpolationQuality:(CGInterpolationQuality)quality;

- (UIImage *)resizedImage:(CGSize)newSize
     interpolationQuality:(CGInterpolationQuality)quality;

- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds
                    interpolationQuality:(CGInterpolationQuality)quality;
@end
