//  Created by Karen Lusinyan on 07/05/14.

typedef NS_ENUM(NSInteger, ImageCachingPolicy) {
    ImageCachingPolicyNone,
    ImageCachingPolicyEnabled,
};

typedef NS_ENUM(NSInteger, UIImageRepresentation) {
    UIImageRepresentationPNG,
    UIImageRepresentationJPEG,
};

@interface DirectoryUtils : NSObject

#pragma image

+ (NSString *)MD5Hash:(NSString *)originalString;

+ (NSString *)moduleCacheDirectoryPath:(NSString *)moduleName;

+ (NSString *)moduleDocumentDirectoryPath:(NSString *)moduleName;

+ (NSString *)moduleLibraryDirectoryPath:(NSString *)moduleName;

+ (void)createDirectoryIfNotExistsWithPath:(NSString *)path;

+ (NSString *)imagePathWithName:(NSString *)imageName
                     moduleName:(NSString *)moduleName
             imageCachingPolicy:(ImageCachingPolicy)imageCachingPolicy;

+ (UIImage *)imageExistsWithName:(NSString *)imageName
                      moduleName:(NSString *)moduleName
              imageCachingPolicy:(ImageCachingPolicy)imageCachingPolicy;

+ (NSString *)imagePathWithName:(NSString *)imageName
                     moduleName:(NSString *)moduleName __deprecated_msg("use: imagePathWithName:moduleName:imageCachingPolicy:");

+ (UIImage *)imageExistsWithName:(NSString *)imageName
                      moduleName:(NSString *)moduleName __deprecated_msg("use: imageExistsWithName:moduleName:imageCachingPolicy:");

+ (UIImage *)saveThumbnailImage:(UIImage *)image
                       withSize:(NSUInteger)size
                     toFilePath:(NSString *)filePath
            imageRepresentation:(UIImageRepresentation)imageRepresentation;

+ (UIImage *)saveImage:(UIImage *)image
          scaledFactor:(NSUInteger)scaledFactor
            toFilePath:(NSString *)filePath
   imageRepresentation:(UIImageRepresentation)imageRepresentation;

+ (UIImage *)saveImage:(UIImage *)image
            toFilePath:(NSString *)filePath
   imageRepresentation:(UIImageRepresentation)imageRepresentation;

+ (void)saveImageData:(NSData *)imageData
           toFilePath:(NSString *)filePath;

+ (BOOL)deleteFileAtPath:(NSString *)filePath
                   error:(NSError *__autoreleasing *)error;

+ (UIImage *)placeholderImage;


#pragma bundle

+ (NSBundle *)bundleWithName:(NSString *)bundleName
                    inBundle:(NSBundle *)bundle;

+ (NSBundle *)bundleWithName:(NSString *)bundleName;

+ (UIImage *)imageWithName:(NSString *)imageName
                  inBundle:(NSBundle *)bundle;

+ (UIImage *)imageWithName:(NSString *)imageName
                bundleName:(NSString *)bundleName;

+ (NSString *)filePathWithName:(NSString *)fileName
                      inBundle:(NSBundle *)bundle;

+ (NSString *)filePathWithName:(NSString *)fileName
                    bundleName:(NSString *)bundleName;

+ (NSString *)localizedStringForKey:(NSString *)key
                           inBundle:(NSBundle *)bundle;

+ (NSString *)localizedStringForKey:(NSString *)key
                         bundleName:(NSString *)bundleName;

@end
