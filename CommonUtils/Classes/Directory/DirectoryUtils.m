//  Created by Karen Lusinyan on 07/05/14.

#import "DirectoryUtils.h"
#import "UIImage+Resize.h"

#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

static inline NSString * MD5Hash(NSString *originalString)
{
    const char *cStr = [originalString UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (unsigned int)strlen(cStr), result);
    
    return [NSString stringWithFormat: @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
            ];
}

@implementation DirectoryUtils

#pragma image

+ (NSString *)MD5Hash:(NSString *)originalString
{
    return MD5Hash(originalString);
}

+ (NSString *)moduleDirectory:(NSSearchPathDirectory)searchPathDirectory moduleName:(NSString *)moduleName
{
    NSString *searchDir = [NSSearchPathForDirectoriesInDomains(searchPathDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    if (moduleName) {
        NSString *moduleDocumentDirPath = [searchDir stringByAppendingPathComponent:moduleName];
        [self createDirectoryIfNotExistsWithPath:moduleDocumentDirPath];
    }
    return (moduleName) ? [searchDir stringByAppendingPathComponent:moduleName] : searchDir;
}

+ (NSString *)moduleCacheDirectoryPath:(NSString *)moduleName
{
    return [self moduleDirectory:NSCachesDirectory moduleName:moduleName];
}

+ (NSString *)moduleDocumentDirectoryPath:(NSString *)moduleName
{
    return [self moduleDirectory:NSDocumentDirectory moduleName:moduleName];
}

+ (NSString *)moduleLibraryDirectoryPath:(NSString *)moduleName
{
    return [self moduleDirectory:NSLibraryDirectory moduleName:moduleName];
}

+ (void)createDirectoryIfNotExistsWithPath:(NSString *)path
{
    BOOL isDir = YES;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:path
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
        if (error) DebugLog(@"error %@", [error localizedDescription]);
    }
}

//only here MD5Hash(imageName) applied

+ (NSString *)imagePathWithName:(NSString *)imageName
                     moduleName:(NSString *)moduleName
             imageCachingPolicy:(ImageCachingPolicy)imageCachingPolicy
{
    if (!imageName) return nil;
    if (imageCachingPolicy == ImageCachingPolicyNone) {
        return [[self moduleDocumentDirectoryPath:moduleName] stringByAppendingPathComponent:MD5Hash(imageName)];
    }
    else if (imageCachingPolicy == ImageCachingPolicyEnabled) {
        return [[self moduleCacheDirectoryPath:moduleName] stringByAppendingPathComponent:MD5Hash(imageName)];
    }
    return nil;
}

+ (UIImage *)imageExistsWithName:(NSString *)imageName
                      moduleName:(NSString *)moduleName
              imageCachingPolicy:(ImageCachingPolicy)imageCachingPolicy
{
    if (!imageName) return nil;
    return [UIImage imageWithContentsOfFile:[self imagePathWithName:imageName moduleName:moduleName imageCachingPolicy:imageCachingPolicy]];
}

+ (NSString *)imagePathWithName:(NSString *)imageName
                     moduleName:(NSString *)moduleName
{
    if (!imageName) return nil;
    return [[self moduleCacheDirectoryPath:moduleName] stringByAppendingPathComponent:MD5Hash(imageName)];
}

+ (UIImage *)imageExistsWithName:(NSString *)imageName
                      moduleName:(NSString *)moduleName
{
    if (!imageName) return nil;
    return [UIImage imageWithContentsOfFile:[self imagePathWithName:imageName moduleName:moduleName]];
}

+ (UIImage *)saveThumbnailImage:(UIImage *)image
                       withSize:(NSUInteger)size
                     toFilePath:(NSString *)filePath
            imageRepresentation:(UIImageRepresentation)imageRepresentation
{
    if (!image) return nil;
    UIImage *thumbnail = [image thumbnailImage:size
                             transparentBorder:0
                                  cornerRadius:0
                          interpolationQuality:kCGInterpolationDefault];
    return [self saveImage:thumbnail
                toFilePath:filePath
       imageRepresentation:imageRepresentation];
}

+ (UIImage *)saveImage:(UIImage *)image
          scaledFactor:(NSUInteger)scaledFactor
            toFilePath:(NSString *)filePath
   imageRepresentation:(UIImageRepresentation)imageRepresentation
{
    if (!image) return nil;
    UIImage *resizedImage = image;
    if (scaledFactor > 0) {
        CGFloat width = image.size.width / scaledFactor;
        CGFloat height = image.size.height / scaledFactor;
        resizedImage = [image resizedImage:(CGSize){width, height} interpolationQuality:kCGInterpolationDefault];
    }
    return [self saveImage:resizedImage
                toFilePath:filePath
       imageRepresentation:imageRepresentation];
}

+ (UIImage *)saveImage:(UIImage *)image
            toFilePath:(NSString *)filePath
   imageRepresentation:(UIImageRepresentation)imageRepresentation
{
    if (!image) return nil;
    if (imageRepresentation == UIImageRepresentationPNG) {
        [self saveImageData:[NSData dataWithData:UIImagePNGRepresentation(image)] toFilePath:filePath];
    }
    else if (imageRepresentation == UIImageRepresentationJPEG) {
        [self saveImageData:[NSData dataWithData:UIImageJPEGRepresentation(image, 1.0f)] toFilePath:filePath];
    }
    return image;
}

+ (void)saveImageData:(NSData *)imageData
           toFilePath:(NSString *)filePath
{
    if (!imageData) return;
    [imageData writeToFile:filePath atomically:YES];
}

+ (BOOL)deleteFileAtPath:(NSString *)filePath
                    error:(NSError *__autoreleasing *)error
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return [[NSFileManager defaultManager] removeItemAtPath:filePath error:error];
    }
    return YES;
}

+ (UIImage *)placeholderImage
{
    return kCommonImagePNGWithName(@"placeholder");
}

#pragma bundle

#pragma public methods

+ (NSBundle *)bundleWithName:(NSString *)bundleName inBundle:(NSBundle *)bundle
{
    if (bundle == nil) {
        bundle = [NSBundle mainBundle];
    }
    if (bundleName != nil) {
        NSString *bundlePath = [[bundle resourcePath] stringByAppendingPathComponent:bundleName];
        bundle = [NSBundle bundleWithPath:bundlePath];
    }
    return bundle;
}

+ (NSBundle *)bundleWithName:(NSString *)bundleName
{
    return [self bundleWithName:bundleName inBundle:nil];
}

+ (UIImage *)imageWithName:(NSString *)imageName
                  inBundle:(NSBundle *)bundle
{
    if (bundle == nil) {
        bundle = [NSBundle mainBundle];
    }
    return [UIImage imageNamed:[[bundle bundlePath] stringByAppendingPathComponent:imageName]];
}

+ (UIImage *)imageWithName:(NSString *)imageName
                bundleName:(NSString *)bundleName
{
    NSBundle *bundle = [self bundleWithName:bundleName];
    return [UIImage imageNamed:[[bundle bundlePath] stringByAppendingPathComponent:imageName]];
}

+ (NSString *)filePathWithName:(NSString *)fileName
                      inBundle:(NSBundle *)bundle
{
    return [[bundle resourcePath] stringByAppendingPathComponent:fileName];
}

+ (NSString *)filePathWithName:(NSString *)fileName
                    bundleName:(NSString *)bundleName
{
    NSBundle *bundle = [self bundleWithName:bundleName];
    return [[bundle resourcePath] stringByAppendingPathComponent:fileName];
}

+ (NSString *)localizedStringForKey:(NSString *)key
                           inBundle:(NSBundle *)bundle
{
    if (bundle == nil) {
        bundle = [NSBundle mainBundle];
    }
    return [bundle localizedStringForKey:key value:nil table:nil];
}

+ (NSString *)localizedStringForKey:(NSString *)key
                         bundleName:(NSString *)bundleName
{
    NSBundle *bundle = [self bundleWithName:bundleName];
    return [bundle localizedStringForKey:key value:nil table:nil];
}

@end
