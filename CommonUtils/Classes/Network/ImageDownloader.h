//  Created by Karen Lusinyan on 20/06/14.

#import "DirectoryUtils.h"

@interface ImageDownloader : NSObject

+ (void)setLogging:(BOOL)logging;

//handle image caching
//uses AFNetworking for download images with given url
//////////////////////////////////////////////////////
+ (NSCache *)sharedImageCache;

//handle cancelling all image request operaitons
//uses AFNetworking cancelImageRequestOperations method
+ (void)cancelAllImageRequestOperations;

+ (UIImage *)imageWithUrl:(NSString *)url
               moduleName:(NSString *)moduleName
            downloadImage:(UIImageView *)imageView
      imageRepresentation:(UIImageRepresentation)imageRepresentation
              placeholder:(UIImage *)placeholder
               completion:(void (^)(UIImage *image))completion;

+ (UIImage *)imageWithUrl:(NSString *)url
               moduleName:(NSString *)moduleName
            downloadImage:(UIImageView *)imageView
      imageRepresentation:(UIImageRepresentation)imageRepresentation
            thumbnailSize:(CGFloat)thubnailSize
              placeholder:(UIImage *)placeholder
               completion:(void (^)(UIImage *image))completion;
//////////////////////////////////////////////////////

@end
