//  Created by Karen Lusinyan on 20/06/14.

#import "ImageDownloader.h"

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

+ (void)cancelAllDownloads
{
    for (UIImageView *downloadingImage in [self downloadingImages]) {
        [downloadingImage cancelImageRequestOperation];
    }
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
                 forIndexPath:(NSIndexPath *)indexPath
          imageRepresentation:(UIImageRepresentation)imageRepresentation
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
    if (!url) {
        url = @"placeholder_image";
        downloadIfNeeded = NO;
    }
    
    //if immage in cache the return it
    UIImage *image = [[self sharedImageCache] objectForKey:MD5Hash(url)];
    if (image) {
        if ([self logging]) DebugLog(@"Taking image [%@] from cache", url);
        return image;
    }
    
    //if image in file system then put it in cache and return it
    image = [DirectoryUtils imageExistsWithName:url moduleName:moduleName];
    if (image) {
        if ([self logging]) DebugLog(@"Taking image [%@] from fileSystem", url);
        [[self sharedImageCache] setObject:image forKey:MD5Hash(url)];
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
                                          NSString *filePath = [DirectoryUtils imagePathWithName:url moduleName:moduleName];
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
                                          //put image in cache
                                          [[self sharedImageCache] setObject:savedImage forKey:MD5Hash(url)];
                                          //remove from downalods
                                          [[self downloadingImages] removeObject:blockImageView];
                                          //return saved image to invocker
                                          if (completion)
                                              completion([[self sharedImageCache] objectForKey:MD5Hash(url)], indexPath);
                                      }
                                      //if there is no image then send completion(nil)
                                      //else if (completion) completion(nil);
                                      
                                  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                      if ([self logging]) DebugLog(@"Error %@  occured in [%@]", error, NSStringFromSelector(_cmd));
                                      //remove from downalods
                                      [[self downloadingImages] removeObject:blockImageView];
                                      if (completion) completion(placeholder, indexPath);
                                  }];
        
        [[self downloadingImages] addObject:imageView];
    }
    else {
        if (placeholder) {
            [[self sharedImageCache] setObject:placeholder forKey:MD5Hash(url)];
        }
    }
    
    return placeholder;
}

+ (UIImage *)offlineImageWithUrl:(NSString *)url
                      moduleName:(NSString *)moduleName
                     placeholder:(UIImage *)placeholder
{
    if (!url) {
        url = @"placeholder_image";
    }
    
    //if immage in cache the return it
    UIImage *image = [[self sharedImageCache] objectForKey:MD5Hash(url)];
    if (image) {
        if ([self logging]) DebugLog(@"Taking image [%@] from cache", url);
        return image;
    }
    
    //if image in file system then put it in cache and return it
    image = [DirectoryUtils imageExistsWithName:url moduleName:moduleName];
    if (image) {
        if ([self logging]) DebugLog(@"Taking image [%@] from fileSystem", url);
        [[self sharedImageCache] setObject:image forKey:MD5Hash(url)];
        return image;
    }
    
    //if there is no image then return placeholder
    if ([self logging]) DebugLog(@"No image found, taking placeholder");
    return placeholder;
}

//////////////////////////////////////////////////////

@end
