//  Created by Karen Lusinyan on 07/05/14.

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

typedef NS_ENUM(NSInteger, UIImageRepresentation) {
    UIImageRepresentationPNG,
    UIImageRepresentationJPEG,
};

@interface DirectoryUtils : NSObject

#pragma image

+ (NSString *)moduleCacheDirectoryPath:(NSString *)moduleName;

+ (NSString *)moduleDocumentDirectoryPath:(NSString *)moduleName;

+ (void)createDirectoryIfNotExistsWithPath:(NSString *)path;

+ (NSString *)imagePathWithName:(NSString *)imageName
                     moduleName:(NSString *)moduleName;

+ (UIImage *)imageExistsWithName:(NSString *)imageName
                      moduleName:(NSString *)moduleName;

+ (UIImage *)saveThumbnailImage:(UIImage *)image
                       withSize:(NSUInteger)size
                     toFilePath:(NSString *)filePath
            imageRepresentation:(UIImageRepresentation)imageRepresentation;

+ (UIImage *)saveImage:(UIImage *)image
            toFilePath:(NSString *)filePath
   imageRepresentation:(UIImageRepresentation)imageRepresentation;

+ (void)saveImageData:(NSData *)imageData
           toFilePath:(NSString *)filePath;

+ (BOOL)deleteImageAtPath:(NSString *)filePath
                    error:(NSError *__autoreleasing *)error;

+ (UIImage *)placeholderImage;


#pragma bundle

// image from given bundle
// ex: with    bundle: [UIImage imageNamed:@"CommonUtils.bundle/subbundle_name.bundle/image_name"]
// ex: without bundle: [UIImage imageNamed:@"CommonUtils.bundle/image_name"]
// important: the resources from subbundle work only with images not xibs or localized string
+ (UIImage *)imageWithName:(NSString *)imageName
                bundleName:(NSString *)bundleName;

// bundle with given bundle
+ (NSBundle *)bundleWithName:(NSString *)bundleName;

// file path with from given bundle
+ (NSString *)filePathWithName:(NSString *)fileName
                    bundleName:(NSString *)bundleName;

// localizable string from given bundle
+ (NSString *)localizedStringForKey:(NSString *)key
                         bundleName:(NSString *)bundleName;

@end
