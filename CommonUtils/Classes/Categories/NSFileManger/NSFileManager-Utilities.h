/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

// Path utilities
NSString *NSDocumentsFolder();
NSString *NSLibraryFolder();
NSString *NSCachesFolder();
NSString *NSTmpFolder();
NSString *NSBundleFolder();

@interface NSFileManager (Utilities)
+ (NSString *) pathForItemNamed: (NSString *) fname inFolder: (NSString *) path;
+ (NSString *) pathForDocumentNamed: (NSString *) fname;
+ (NSString *) pathForBundleDocumentNamed: (NSString *) fname;

+ (NSArray *) pathsForItemsMatchingExtension: (NSString *) ext inFolder: (NSString *) path;
+ (NSArray *) pathsForDocumentsMatchingExtension: (NSString *) ext;
+ (NSArray *) pathsForBundleDocumentsMatchingExtension: (NSString *) ext;

+ (NSArray *) filesInFolder: (NSString *) path;

//+ (UIImage *) imageNamed: (NSString *) aName;
//+ (UIImage *) imageFromURLString: (NSString *) urlstring;
@end

