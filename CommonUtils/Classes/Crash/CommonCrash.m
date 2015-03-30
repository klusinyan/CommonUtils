// Original code by Karl Stenerud.
// Modified by Karen Lusinyan on 19/03/15

#import "CommonCrash.h"
#import "DirectoryUtils.h"

/** The default file to store error reports to. */
#define kDefaultReportFilename @"error_report.txt"

/** The exception name to use for raised signals. */
#define kSignalRaisedExceptionName @"SignalRaisedException"

@interface CommonCrash ()

@property(readwrite, nonatomic, assign) id <CommonCrashDelegate> delegate;

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
 * @param exception The exception that was raised.
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

NSString *signalName(int signal)
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
                                                     reason:signalName(signal)
                                                   userInfo:nil];
    internal_handleException(exception, NO);
}


@implementation CommonCrash {
    NSString *errorReportPath;
}

- (id)init
{
    if(nil != (self = [super init])) {
        self.errorReportPath = kDefaultReportFilename;
    }
    
    return self;
}

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
    DebugLog(@"start managing crashes");
    installHandlers();
}

+ (void)stopManagingCrashes
{
    DebugLog(@"stop managing crashes");
    removeHandlers();
}

- (NSString *)errorReportPath
{
    return errorReportPath;
}

- (void)setErrorReportPath:(NSString *)path
{
    errorReportPath = nil;
    
    if (path != nil) {
        if (![path hasPrefix:@"/"]) {
            errorReportPath = [DirectoryUtils moduleDocumentDirectoryPath:path];
            if ([errorReportPath hasSuffix:@"/"]) errorReportPath = [errorReportPath substringToIndex:[errorReportPath length] - 1];
        }
        else {
            errorReportPath = path;
        }
    }
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

- (void)handleException:(NSException *)exception
{
    NSString *info = [NSString stringWithFormat:@"Date:%@\nApp: %@\nVersion: %@\n%@: %@\%@",
                      [NSDate date],
                      [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"],
                      [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],
                      [exception name],
                      [exception reason],
                      [exception callStackSymbols]];
    
    if (errorReportPath != nil) {
        [info writeToFile:errorReportPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    
    [self.delegate crashWithExceptionInfo:info];
}

@end
