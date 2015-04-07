// Original code by Karl Stenerud.
// Modified by Karen Lusinyan on 19/03/15

/**
 * Manages any crashes that occur while the app is running.
 * If a crash occurs while CrashManager is managing crashes, it will write
 * a crash report to a file, allow a user-defined delegate to do some more processing,
 * then let the application finish crashing.
 */

@protocol CommonCrashDelegate <NSObject>

@optional
- (void)crashWithExceptionInfo:(NSString *)info;

@end

@interface CommonCrash : NSObject

/// If you set this to a value that doesn't start with "/", it will be expanded to a full path relative to the Documents directory; default: Documents/error_report.txt
@property(readwrite, nonatomic, retain) NSString *errorReportPath;

+ (void)setCommonCrashDelegate:(id<CommonCrashDelegate>)delegate;

+ (void)startManagingCrashes;

+ (void)stopManagingCrashes;

+ (NSString *)lastErrorReport;

@end
