// Original code by Karl Stenerud.
// Modified by Karen Lusinyan on 19/03/15

#import "CommonCrash.h"
#import "DirectoryUtils.h"

/** The exception name to use for raised signals. */
#define kSignalRaisedExceptionName @"SignalRaisedException"

@interface CommonCrash ()

@property (nonatomic, assign) id <CommonCrashDelegate> delegate;

@property (nonatomic, copy) NSString *errorReportPath;

- (void)handleException:(NSException *)exception;

+ (CommonCrash *)sharedInstance;

@end

/**
 * Exception handler.
 * Sets up an appropriate environment and then calls CrashManager to
 * deal with the exception.
 *
 * @param exception The exception that was raised.
 */
static void handleException(NSException *exception);

/**
 * Signal handler.
 * Sets up an appropriate environment and then calls CrashManager to
 * deal with the signal.
 *
 * @param signal The exception that was raised.
 */
static void handleSignal(int signal);

/**
 * Install the exception and signal handlers.
 */
static void installHandlers()
{
    NSSetUncaughtExceptionHandler(&handleException);
    signal(SIGILL, handleSignal);
    signal(SIGABRT, handleSignal);
    signal(SIGFPE, handleSignal);
    signal(SIGBUS, handleSignal);
    signal(SIGSEGV, handleSignal);
    signal(SIGSYS, handleSignal);
    signal(SIGPIPE, handleSignal);
}

/**
 * Remove the exception and signal handlers.
 */
static void removeHandlers()
{
    NSSetUncaughtExceptionHandler(NULL);
    signal(SIGILL, SIG_DFL);
    signal(SIGABRT, SIG_DFL);
    signal(SIGFPE, SIG_DFL);
    signal(SIGBUS, SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGSYS, SIG_DFL);
    signal(SIGPIPE, SIG_DFL);
}

static void internal_handleException(NSException *exception, BOOL raise)
{
    removeHandlers();
    
    [[CommonCrash sharedInstance] handleException:exception];
    
    if (raise) [exception raise];
}

static void handleException(NSException *exception)
{
    internal_handleException(exception, YES);
}

NSString *signal_name(int signal)
{
    switch(signal) {
        case SIGABRT:
            return @"Abort";
        case SIGILL:
            return @"Illegal Instruction";
        case SIGSEGV:
            return @"Segmentation Fault";
        case SIGFPE:
            return @"Floating Point Error";
        case SIGBUS:
            return @"Bus Error";
        case SIGPIPE:
            return @"Broken Pipe";
        default:
            return [NSString stringWithFormat:@"Unknown Signal (%d)", signal];
    }
}

static void handleSignal(int signal)
{
    NSException* exception = [NSException exceptionWithName:kSignalRaisedExceptionName
                                                     reason:signal_name(signal)
                                                   userInfo:nil];
    internal_handleException(exception, NO);
}


@implementation CommonCrash

+ (CommonCrash *)sharedInstance
{
    static CommonCrash *instance = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

+ (void)setCommonCrashDelegate:(id<CommonCrashDelegate>)delegate
{
    [[self sharedInstance] setDelegate:delegate];
}

+ (void)startManagingCrashes
{
    //DebugLog(@"start managing crashes");
    installHandlers();
}

+ (void)stopManagingCrashes
{
    //DebugLog(@"stop managing crashes");
    removeHandlers();
}

- (NSString *)defaultPath
{
    return [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] path];
}

#pragma mark - getter/setter

- (NSString *)errorReportPath
{
    if (_errorReportPath == nil) {
        _errorReportPath = [[self defaultPath] stringByAppendingPathComponent:@"crash_log.txt"];
    }
    return _errorReportPath;
}

+ (NSString *)lastErrorReport
{
    NSString *path = [[self sharedInstance] errorReportPath];
    if (path == nil) return nil;
    
    NSError *error = nil;
    NSString *errorReport = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (errorReport != nil) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
        if(nil != error) {
            DebugLog(@"Warning: could not delete %@: %@", path, error);
        }
    }
    
    return errorReport;
}

+ (void)setErrorReportPath:(NSString *)path
{
    [[self sharedInstance] setErrorReportPath:path];
}

- (void)handleException:(NSException *)exception
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *timestamp = [df stringFromDate:[NSDate date]];
    NSString *crashInfo = [NSString stringWithFormat:@"Date: %@\nApp: %@\nVersion: %@\n%@: %@\%@",
                           timestamp,
                           [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"],
                           [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],
                           [exception name],
                           [exception reason],
                           [exception callStackSymbols]];
    
    if (![crashInfo writeToFile:self.errorReportPath atomically:YES encoding:NSUTF8StringEncoding error:nil]) {
        NSLog(@"error writing to file=[%@]", self.errorReportPath);
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(crashWithExceptionInfo:)]) {
        [self.delegate crashWithExceptionInfo:crashInfo];
    }
    
    // log crash info always
    NSLog(@"%@", crashInfo);
}

@end
