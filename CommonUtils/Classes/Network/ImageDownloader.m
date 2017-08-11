//  Created by Karen Lusinyan on 20/06/14.

#import "ImageDownloader.h"
#import "AFHTTPSessionManager.h"
#import <Foundation/Foundation.h>

static BOOL IDLogging = NO;

@implementation ImageDownloader

+ (void)setLogging:(BOOL)logging
{
    IDLogging = logging;
}

+ (BOOL)logging
{
    return IDLogging;
}

//handle image caching
//uses AFNetworking for download images with given url
//////////////////////////////////////////////////////
+ (NSCache *)sharedImageCache
{
    static NSCache *sharedImageCache = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedImageCache = [[NSCache alloc] init];
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification * __unused notification) {
                                                          [sharedImageCache removeAllObjects];
                                                      }];
        
        
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    });
    
    return sharedImageCache;
}

+ (NSMutableArray *)downloadingImages
{
    static NSMutableArray *downloadingImages = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        downloadingImages = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification
                                                          object:nil queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification * __unused notification) {
                                                          [downloadingImages removeAllObjects];
                                                      }];
    });
    
    return downloadingImages;
}

+ (NSOperationQueue *)downloadQueue
{
    static NSOperationQueue *downloadQueue = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        downloadQueue = [NSOperationQueue new];
        downloadQueue.maxConcurrentOperationCount = 1;
        if ([downloadQueue respondsToSelector:@selector(qualityOfService)]) {
            downloadQueue.qualityOfService = NSQualityOfServiceBackground;
        }
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification * __unused notification) {
                                                          [downloadQueue cancelAllOperations];
                                                      }];
    });
    
    return downloadQueue;
}

+ (void)clearCache:(BOOL)forced moduleName:(NSString *)moduleName
{
    [[self sharedImageCache] removeAllObjects];
    
    if (forced) {
        [DirectoryUtils deleteFileAtPath:[DirectoryUtils moduleCacheDirectoryPath:moduleName] error:NULL];
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
+ (void)cancelAllDownloads
{
    for (UIImageView *downloadingImage in [self downloadingImages]) {
        // AFNetwroking 3.x
        SEL cancelImageDownloadTask = NSSelectorFromString(@"cancelImageDownloadTask");
        if ([downloadingImage respondsToSelector:cancelImageDownloadTask]) {
            [downloadingImage performSelector:cancelImageDownloadTask];
        }
        // AFNetwroking 2.x
        SEL cancelImageRequestOperation = NSSelectorFromString(@"cancelImageRequestOperation");
        if ([downloadingImage respondsToSelector:cancelImageRequestOperation]) {
            [downloadingImage performSelector:cancelImageRequestOperation];
        }
    }
}
#pragma clang diagnostic pop

+ (void)cancelImageDownload:(UIImageView *)imageView
{
    [[self downloadingImages] enumerateObjectsUsingBlock:^(UIImageView *downloadingImage, NSUInteger idx, BOOL * _Nonnull stop) {
        if (downloadingImage == imageView) {
            // AFNetwroking 3.x
            SEL cancelImageDownloadTask = NSSelectorFromString(@"cancelImageDownloadTask");
            if ([downloadingImage respondsToSelector:cancelImageDownloadTask]) {
                [downloadingImage performSelector:cancelImageDownloadTask withObject:nil afterDelay:0];
            }
            // AFNetwroking 2.x
            SEL cancelImageRequestOperation = NSSelectorFromString(@"cancelImageRequestOperation");
            if ([downloadingImage respondsToSelector:cancelImageRequestOperation]) {
                [downloadingImage performSelector:cancelImageRequestOperation withObject:nil afterDelay:0];
            }
            *stop = YES;
        }
    }];
}

+ (UIImage *)imageWithUrl:(NSString *)url
               moduleName:(NSString *)moduleName
            downloadImage:(UIImageView *)imageView
      imageRepresentation:(UIImageRepresentation)imageRepresentation
              placeholder:(UIImage *)placeholder
               completion:(void (^)(UIImage *))completion
{
    return [self imageWithUrl:url
                   moduleName:moduleName
                downloadImage:imageView
                 forIndexPath:nil
          imageRepresentation:imageRepresentation
                thumbnailSize:0
                  placeholder:placeholder
                   completion:^(UIImage *image, NSIndexPath *indexPath) {
                       if (completion) completion(image);
                   }];
}

+ (UIImage *)imageWithUrl:(NSString *)url
               moduleName:(NSString *)moduleName
            downloadImage:(UIImageView *)imageView
      imageRepresentation:(UIImageRepresentation)imageRepresentation
            thumbnailSize:(CGFloat)thubnailSize
              placeholder:(UIImage *)placeholder
               completion:(void (^)(UIImage *image))completion
{
    return [self imageWithUrl:url
                   moduleName:moduleName
                downloadImage:imageView
                 forIndexPath:nil
          imageRepresentation:imageRepresentation
                thumbnailSize:thubnailSize
                  placeholder:placeholder
                   completion:^(UIImage *image, NSIndexPath *indexPath) {
                       if (completion) completion(image);
                   }];
}


+ (UIImage *)imageWithUrl:(NSString *)url
               moduleName:(NSString *)moduleName
            downloadImage:(UIImageView *)imageView
             forIndexPath:(NSIndexPath *)indexPath
      imageRepresentation:(UIImageRepresentation)imageRepresentation
              placeholder:(UIImage *)placeholder
               completion:(void (^)(UIImage *image, NSIndexPath *indexPath))completion
{
    return [self imageWithUrl:url
                   moduleName:moduleName
                downloadImage:imageView
                 forIndexPath:indexPath
          imageRepresentation:imageRepresentation
                thumbnailSize:0
                  placeholder:placeholder
                   completion:completion];
}

+ (UIImage *)imageWithUrl:(NSString *)url
               moduleName:(NSString *)moduleName
            downloadImage:(UIImageView *)imageView
             forIndexPath:(NSIndexPath *)indexPath
      imageRepresentation:(UIImageRepresentation)imageRepresentation
            thumbnailSize:(CGFloat)thubnailSize
              placeholder:(UIImage *)placeholder
               completion:(void (^)(UIImage *image, NSIndexPath *indexPath))completion
{
    BOOL downloadIfNeeded = YES;
    if ([url length] == 0) {
        url = @"placeholder_image";
        downloadIfNeeded = NO;
    }
    
    //if immage in cache the return it
    UIImage *image = [[self sharedImageCache] objectForKey:[DirectoryUtils MD5Hash:url]];
    if (image) {
        if ([self logging]) DebugLog(@"Taking image [%@] from cache", url);
        return image;
    }
    
    //if image in file system then put it in cache and return it
    image = [DirectoryUtils imageExistsWithName:url moduleName:moduleName imageCachingPolicy:ImageCachingPolicyEnabled];
    if (image) {
        if ([self logging]) DebugLog(@"Taking image [%@] from fileSystem", url);
        [[self sharedImageCache] setObject:image forKey:[DirectoryUtils MD5Hash:url]];
        return image;
    }
    
    //it the url exists then download
    if (downloadIfNeeded) {
        if ([self logging]) DebugLog(@"Downloading image [%@]", url);
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        __weak UIImageView *blockImageView = imageView;
        [imageView setImageWithURLRequest:request
                         placeholderImage:placeholder
                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                      if (image) {
                                          UIImage *savedImage = nil;
                                          NSString *filePath = [DirectoryUtils imagePathWithName:url moduleName:moduleName imageCachingPolicy:ImageCachingPolicyEnabled];
                                          if ([self logging]) DebugLog(@"filePath %@", filePath);
                                          if (thubnailSize != 0) {
                                              savedImage = [DirectoryUtils saveThumbnailImage:image
                                                                                     withSize:thubnailSize
                                                                                   toFilePath:filePath
                                                                          imageRepresentation:imageRepresentation];
                                          }
                                          else {
                                              savedImage = [DirectoryUtils saveImage:image
                                                                          toFilePath:filePath
                                                                 imageRepresentation:imageRepresentation];
                                          }
                                          // put image in cache
                                          if (savedImage != nil) {
                                              [[self sharedImageCache] setObject:savedImage forKey:[DirectoryUtils MD5Hash:url]];
                                          }
                                          // remove from downalods
                                          [[self downloadingImages] removeObject:blockImageView];
                                          //return saved image to invocker
                                          if (completion) completion([[self sharedImageCache] objectForKey:[DirectoryUtils MD5Hash:url]], indexPath);
                                      }
                                      //if there is no image then send completion(nil)
                                      //else if (completion) completion(nil);
                                      
                                  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                      if ([self logging]) DebugLog(@"Error %@  occured in [%@]", error, NSStringFromSelector(_cmd));
                                      // remove from downalods
                                      [[self downloadingImages] removeObject:blockImageView];
                                      if (completion) completion(placeholder, indexPath);
                                  }];
        
        [[self downloadingImages] addObject:imageView];
    }
    else {
        if (placeholder) {
            [[self sharedImageCache] setObject:placeholder forKey:[DirectoryUtils MD5Hash:url]];
        }
    }
    
    return placeholder;
}

+ (UIImage *)downloadImageWithUrl:(NSString *)url
                       moduleName:(NSString *)moduleName
              imageRepresentation:(UIImageRepresentation)imageRepresentation
                    thumbnailSize:(CGFloat)thubnailSize
                      placeholder:(UIImage *)placeholder
                       completion:(void (^)(UIImage *image))completion
{
    if ([url length] == 0) {
        return placeholder;
    }
    
    // if immage in cache the return it
    UIImage *image = [[self sharedImageCache] objectForKey:[DirectoryUtils MD5Hash:url]];
    if (image) {
        if ([self logging]) DebugLog(@"Taking image [%@] from cache", url);
        return image;
    }
    
    // if image in file system then put it in cache and return it
    image = [DirectoryUtils imageExistsWithName:url moduleName:moduleName imageCachingPolicy:ImageCachingPolicyEnabled];
    if (image) {
        if ([self logging]) DebugLog(@"Taking image [%@] from fileSystem", url);
        [[self sharedImageCache] setObject:image forKey:[DirectoryUtils MD5Hash:url]];
        return image;
    }
    
    if ([self logging]) DebugLog(@"Downloading image [%@]", url);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFImageResponseSerializer serializer];
    [manager GET:url
      parameters:nil
        progress:^(NSProgress * _Nonnull downloadProgress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //DebugLog(@"%f", downloadProgress.fractionCompleted);
            });
        }
         success:^(NSURLSessionTask *task, id responseObject) {
             if (responseObject != nil) {
                 UIImage *savedImage = nil;
                 NSString *filePath = [DirectoryUtils imagePathWithName:url
                                                             moduleName:moduleName
                                                     imageCachingPolicy:ImageCachingPolicyEnabled];
                 if ([self logging]) DebugLog(@"filePath %@", filePath);
                 if (thubnailSize != 0) {
                     savedImage = [DirectoryUtils saveThumbnailImage:responseObject
                                                            withSize:thubnailSize
                                                          toFilePath:filePath
                                                 imageRepresentation:imageRepresentation];
                 }
                 else {
                     savedImage = [DirectoryUtils saveImage:responseObject
                                                 toFilePath:filePath
                                        imageRepresentation:imageRepresentation];
                 }
                 // put image in cache
                 if (savedImage != nil) {
                     [[self sharedImageCache] setObject:savedImage forKey:[DirectoryUtils MD5Hash:url]];
                 }
                 // run completion
                 if (completion) completion(savedImage);
             }
         } failure:^(NSURLSessionTask *operation, NSError *error) {
             if ([self logging]) DebugLog(@"Error %@  occured in [%@]", error, NSStringFromSelector(_cmd));
             // run completion
             if (completion) completion(nil);
         }];
    
    return placeholder;
}

+ (UIImage *)downloadImageWithUrl:(NSString *)url
                       moduleName:(NSString *)moduleName
              imageRepresentation:(UIImageRepresentation)imageRepresentation
                     scaledFactor:(CGFloat)scaledFactor
                      placeholder:(UIImage *)placeholder
                       completion:(void (^)(UIImage *image))completion
{
    if ([url length] == 0) {
        return placeholder;
    }
    
    // if immage in cache the return it
    UIImage *image = [[self sharedImageCache] objectForKey:[DirectoryUtils MD5Hash:url]];
    if (image) {
        if ([self logging]) DebugLog(@"Taking image [%@] from cache", url);
        return image;
    }
    
    // if image in file system then put it in cache and return it
    image = [DirectoryUtils imageExistsWithName:url moduleName:moduleName imageCachingPolicy:ImageCachingPolicyEnabled];
    if (image) {
        if ([self logging]) DebugLog(@"Taking image [%@] from fileSystem", url);
        [[self sharedImageCache] setObject:image forKey:[DirectoryUtils MD5Hash:url]];
        return image;
    }
    
    if ([self logging]) DebugLog(@"Downloading image [%@]", url);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFImageResponseSerializer serializer];
    [manager GET:url
      parameters:nil
        progress:^(NSProgress * _Nonnull downloadProgress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //DebugLog(@"%f", downloadProgress.fractionCompleted);
            });
        }
         success:^(NSURLSessionTask *task, id responseObject) {
             if (responseObject != nil) {
                 UIImage *savedImage = nil;
                 NSString *filePath = [DirectoryUtils imagePathWithName:url
                                                             moduleName:moduleName
                                                     imageCachingPolicy:ImageCachingPolicyEnabled];
                 if ([self logging]) DebugLog(@"filePath %@", filePath);
                 if (scaledFactor != 0) {
                     savedImage = [DirectoryUtils saveImage:responseObject
                                               scaledFactor:scaledFactor
                                                 toFilePath:filePath
                                        imageRepresentation:imageRepresentation];
                 }
                 else {
                     savedImage = [DirectoryUtils saveImage:responseObject
                                                 toFilePath:filePath
                                        imageRepresentation:imageRepresentation];
                 }
                 // put image in cache
                 if (savedImage != nil) {
                     [[self sharedImageCache] setObject:savedImage forKey:[DirectoryUtils MD5Hash:url]];
                 }
                 // run completion
                 if (completion) completion(savedImage);
             }
         } failure:^(NSURLSessionTask *operation, NSError *error) {
             if ([self logging]) DebugLog(@"Error %@  occured in [%@]", error, NSStringFromSelector(_cmd));
             // run completion
             if (completion) completion(nil);
         }];
    
    return placeholder;
}

+ (UIImage *)downloadImageWithUrl:(NSString *)url
                       moduleName:(NSString *)moduleName
              imageRepresentation:(UIImageRepresentation)imageRepresentation
                      placeholder:(UIImage *)placeholder
                       completion:(void (^)(UIImage *image))completion
{
    return [self downloadImageWithUrl:url
                           moduleName:moduleName
                  imageRepresentation:imageRepresentation
                        thumbnailSize:0
                          placeholder:placeholder
                           completion:completion];
}

+ (void)downloadImageWithUrl:(NSString *)url
                  moduleName:(NSString *)moduleName
         imageRepresentation:(UIImageRepresentation)imageRepresentation
                  completion:(void (^)(UIImage *image))completion
{
    // if immage in cache the return it
    UIImage *image = [[self sharedImageCache] objectForKey:[DirectoryUtils MD5Hash:url]];
    if (image) {
        if ([self logging]) DebugLog(@"Taking image [%@] from cache", url);
        if (completion) completion(image);
        return;
    }
    
    // if image in file system then put it in cache and return it
    image = [DirectoryUtils imageExistsWithName:url moduleName:moduleName imageCachingPolicy:ImageCachingPolicyEnabled];
    if (image) {
        if ([self logging]) DebugLog(@"Taking image [%@] from fileSystem", url);
        [[self sharedImageCache] setObject:image forKey:[DirectoryUtils MD5Hash:url]];
        if (completion) completion(image);
        return;
    }
    
    if ([self logging]) DebugLog(@"Downloading image [%@]", url);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFImageResponseSerializer serializer];
    [manager GET:url
      parameters:nil
        progress:nil
         success:^(NSURLSessionTask *task, id responseObject) {
             if (responseObject != nil) {
                 UIImage *savedImage = nil;
                 NSString *filePath = [DirectoryUtils imagePathWithName:url
                                                             moduleName:moduleName
                                                     imageCachingPolicy:ImageCachingPolicyEnabled];
                 if ([self logging]) DebugLog(@"filePath %@", filePath);
                 savedImage = [DirectoryUtils saveImage:responseObject
                                             toFilePath:filePath
                                    imageRepresentation:imageRepresentation];
                 // put image in cache
                 if (savedImage != nil) {
                     [[self sharedImageCache] setObject:savedImage forKey:[DirectoryUtils MD5Hash:url]];
                 }
                 // run completion
                 if (completion) completion(savedImage);
             }
         } failure:^(NSURLSessionTask *operation, NSError *error) {
             if ([self logging]) DebugLog(@"Error %@  occured in [%@]", error, NSStringFromSelector(_cmd));
             // run completion
             if (completion) completion(nil);
         }];
}

+ (void)downloadImageWithUrl:(NSString *)url
                  completion:(void (^)(UIImage *image))completion
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFImageResponseSerializer serializer];
    [manager GET:url
      parameters:nil
        progress:nil
         success:^(NSURLSessionTask *task, id responseObject) {
             if (completion) completion(responseObject);
         } failure:^(NSURLSessionTask *operation, NSError *error) {
             if ([self logging]) DebugLog(@"Error %@  occured in [%@]", error, NSStringFromSelector(_cmd));
             // run completion
             if (completion) completion(nil);
         }];
}

#pragma mark - public

+ (void)startDownloads:(NSArray *)images
            moduleName:(NSString *)moduleName
            completion:(void(^)(void))completion
{
    if (images == nil || [images count] == 0) {
        if (completion) completion();
        return;
    }
    
    __block NSInteger count = 0;
    for (int i = 0; i < [images count]; i++) {
        [self downloadImageWithUrl:images[i]
                        moduleName:moduleName
               imageRepresentation:UIImageRepresentationPNG
                        completion:^(UIImage *image) {
                            count++;
                            if ([self logging]) {
                                DebugLog(@"count %@", @(count));
                            }
                            if (count == [images count]) {
                                if ([self logging]) {
                                    DebugLog(@"download queue did finish operations");
                                }
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    if (completion) completion();
                                });
                            }
                        }];
    }
}

+ (void)startDownloads:(NSArray *)images
            moduleName:(NSString *)moduleName
{
    for (int i = 0; i < [images count]; i++) {
        [[self downloadQueue] addOperation:[self operationWithImageUrl:images[i] moduleName:moduleName]];
    }
}

+ (void)stopDownloads
{
    [[self downloadQueue] cancelAllOperations];
}

+ (UIImage *)offlineImageWithUrl:(NSString *)url
                      moduleName:(NSString *)moduleName
                     placeholder:(UIImage *)placeholder
{
    if ([url length] == 0) {
        url = @"placeholder_image";
    }
    
    //if immage in cache the return it
    UIImage *image = [[self sharedImageCache] objectForKey:[DirectoryUtils MD5Hash:url]];
    if (image) {
        if ([self logging]) DebugLog(@"Taking image [%@] from cache", url);
        return image;
    }
    
    //if image in file system then put it in cache and return it
    image = [DirectoryUtils imageExistsWithName:url moduleName:moduleName imageCachingPolicy:ImageCachingPolicyEnabled];
    if (image) {
        if ([self logging]) DebugLog(@"Taking image [%@] from fileSystem", url);
        [[self sharedImageCache] setObject:image forKey:[DirectoryUtils MD5Hash:url]];
        return image;
    }
    
    //if there is no image then return placeholder
    if ([self logging]) DebugLog(@"No image found, taking placeholder");
    return placeholder;
}

#pragma mark - private

+ (NSBlockOperation *)operationWithImageUrl:(NSString *)imageUrl
                                 moduleName:(NSString *)moduleName
{
    return [NSBlockOperation blockOperationWithBlock:^{
        [self downloadImageWithUrl:imageUrl
                        moduleName:moduleName
               imageRepresentation:UIImageRepresentationPNG
                        completion:nil];
    }];
}
//////////////////////////////////////////////////////

@end
