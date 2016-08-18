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

+ (void)cancelImageDownload:(UIImageView *)imageView;

///////////////////////////////////////////////////////
///////////////  simple image downloader //////////////
///////////////////////////////////////////////////////
+ (UIImage *)imageWithUrl:(NSString *)url
               moduleName:(NSString *)moduleName
            downloadImage:(UIImageView *)imageView
      imageRepresentation:(UIImageRepresentation)imageRepresentation
              placeholder:(UIImage *)placeholder
               completion:(void (^)(UIImage *image))completion;

///////////////////////////////////////////////////////
// simple image downloader with given thumbnail size //
///////////////////////////////////////////////////////
+ (UIImage *)imageWithUrl:(NSString *)url
               moduleName:(NSString *)moduleName
            downloadImage:(UIImageView *)imageView
      imageRepresentation:(UIImageRepresentation)imageRepresentation
            thumbnailSize:(CGFloat)thubnailSize
              placeholder:(UIImage *)placeholder
               completion:(void (^)(UIImage *image))completion;

///////////////////////////////////////////////////////
//////// image downloader with given indexPath ////////
///////////////////////////////////////////////////////
+ (UIImage *)imageWithUrl:(NSString *)url
               moduleName:(NSString *)moduleName
            downloadImage:(UIImageView *)imageView
             forIndexPath:(NSIndexPath *)indexPath
      imageRepresentation:(UIImageRepresentation)imageRepresentation
              placeholder:(UIImage *)placeholder
               completion:(void (^)(UIImage *image, NSIndexPath *indexPath))completion;

//////////////////////////////////////////////////////////////
// image downloader with given indexPath and thumbnail size //
//////////////////////////////////////////////////////////////
+ (UIImage *)imageWithUrl:(NSString *)url
               moduleName:(NSString *)moduleName
            downloadImage:(UIImageView *)imageView
             forIndexPath:(NSIndexPath *)indexPath
      imageRepresentation:(UIImageRepresentation)imageRepresentation
            thumbnailSize:(CGFloat)thubnailSize
              placeholder:(UIImage *)placeholder
               completion:(void (^)(UIImage *image, NSIndexPath *indexPath))completion;

+ (UIImage *)downloadImageWithUrl:(NSString *)url
                       moduleName:(NSString *)moduleName
              imageRepresentation:(UIImageRepresentation)imageRepresentation
                    thumbnailSize:(CGFloat)thubnailSize
                      placeholder:(UIImage *)placeholder
                       completion:(void (^)(UIImage *image))completion;

+ (void)downloadImageWithUrl:(NSString *)url
                  completion:(void (^)(UIImage *image))completion;

+ (void)startDownloads:(NSArray *)images
            moduleName:(NSString *)moduleName; // images = array[String]

+ (void)stopDownloads;

+ (UIImage *)offlineImageWithUrl:(NSString *)url
                      moduleName:(NSString *)moduleName
                     placeholder:(UIImage *)placeholder;
//////////////////////////////////////////////////////

@end
