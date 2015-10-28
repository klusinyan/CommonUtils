//  Created by Karen Lusinyan on 20/06/14.

#import "DirectoryUtils.h"

//AFNetworking
#import "AFNetworkActivityIndicatorManager.h"
#import "UIImageView+AFNetworking.h"

@interface ImageDownloader : NSObject

+ (void)setLogging:(BOOL)logging;

//handle image caching
//uses AFNetworking for download images with given url
//////////////////////////////////////////////////////
+ (NSCache *)sharedImageCache;

+ (void)cancelAllDownloads;

+ (UIImage *)imageWithUrl:(NSString *)url
               moduleName:(NSString *)moduleName
            downloadImage:(UIImageView *)imageView
             forIndexPath:(NSIndexPath *)indexPath
      imageRepresentation:(UIImageRepresentation)imageRepresentation
              placeholder:(UIImage *)placeholder
               completion:(void (^)(UIImage *image, NSIndexPath *indexPath))completion;

+ (UIImage *)imageWithUrl:(NSString *)url
               moduleName:(NSString *)moduleName
            downloadImage:(UIImageView *)imageView
             forIndexPath:(NSIndexPath *)indexPath
      imageRepresentation:(UIImageRepresentation)imageRepresentation
            thumbnailSize:(CGFloat)thubnailSize
              placeholder:(UIImage *)placeholder
               completion:(void (^)(UIImage *image, NSIndexPath *indexPath))completion;

+ (UIImage *)offlineImageWithUrl:(NSString *)url
                      moduleName:(NSString *)moduleName
                     placeholder:(UIImage *)placeholder;
//////////////////////////////////////////////////////

@end
