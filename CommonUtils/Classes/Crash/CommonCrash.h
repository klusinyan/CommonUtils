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

+ (void)setErrorReportPath:(NSString *)path; // defualt path is $DocumentDirectory/crash_log.txt

+ (void)setCommonCrashDelegate:(id<CommonCrashDelegate>)delegate;

+ (void)startManagingCrashes;

+ (void)stopManagingCrashes;

+ (NSString *)lastErrorReport;

@end
