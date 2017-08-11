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

// image from given bundleName: it looks up in main bundle
// ex: with    bundle: [UIImage imageNamed:@"CommonUtils.bundle/subbundle_name.bundle/image_name"]
// ex: without bundle: [UIImage imageNamed:@"CommonUtils.bundle/image_name"]
// important: the resources from subbundle work only with images not xibs or localized string
+ (UIImage *)imageWithName:(NSString *)imageName
                bundleName:(NSString *)bundleName
                  inBundle:(NSBundle *)bundle;

// image from given bundleName: it looks up in givec bundle
// ex: with    bundle: [UIImage imageNamed:@"CommonUtils.bundle/subbundle_name.bundle/image_name"]
// ex: without bundle: [UIImage imageNamed:@"CommonUtils.bundle/image_name"]
// important: the resources from subbundle work only with images not xibs or localized string
+ (UIImage *)imageWithName:(NSString *)imageName
                bundleName:(NSString *)bundleName;

// bundle witth give bundle: it looks up in given bundle
+ (NSBundle *)bundleWithName:(NSString *)bundleName inBundle:(NSBundle *)bundle;

// bundle with given bundleName: it looks up in main bundle
+ (NSBundle *)bundleWithName:(NSString *)bundleName;

// file path with from given bundle
+ (NSString *)filePathWithName:(NSString *)fileName
                    bundleName:(NSString *)bundleName;

// localizable string from given bundle
+ (NSString *)localizedStringForKey:(NSString *)key
                         bundleName:(NSString *)bundleName;

@end
