//  Created by Karen Lusinyan on 07/05/14.

#import "DirectoryUtils.h"
#import "UIImage+Resize.h"

@implementation DirectoryUtils

#pragma image

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

+ (BOOL)deleteImageAtPath:(NSString *)filePath
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

+ (UIImage *)imageWithName:(NSString *)imageName
                bundleName:(NSString *)bundleName
{
    return [UIImage imageNamed:[bundleName stringByAppendingPathComponent:imageName]];
}

+ (NSBundle *)bundleWithName:(NSString *)bundleName
{
    NSBundle *bundle = [NSBundle mainBundle];
    
    if (bundleName != nil) {
        NSString *bundlePath = [[bundle resourcePath] stringByAppendingPathComponent:bundleName];
        bundle = [NSBundle bundleWithPath:bundlePath];
    }
    
    return bundle;
}

+ (NSString *)filePathWithName:(NSString *)fileName
                    bundleName:(NSString *)bundleName
{
    NSBundle *bundle = [self bundleWithName:bundleName];
    return [[bundle resourcePath] stringByAppendingPathComponent:fileName];
}

+ (NSString *)localizedStringForKey:(NSString *)key
                         bundleName:(NSString *)bundleName
{
    NSBundle *bundle = [self bundleWithName:bundleName];
    return [bundle localizedStringForKey:key value:nil table:nil];
}

@end
