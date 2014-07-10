//  Created by Alessio on 17/12/13.
//  Copyright (c) 2013 Alessio Orlando. All rights reserved.

//  Generic autosized webview controller with activityView while page loads.
//  Subclass to customize or use as is.
//  Use one of the two provided initializers
//  For use without a nib

#import <UIKit/UIKit.h>

@interface ALEWebViewController : UIViewController<UIWebViewDelegate>
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) NSURLRequest *urlRequest;
@property (nonatomic, strong) NSString *htmlString;
@property (nonatomic, strong) NSURL *baseURL;

- (id)initWithURLRequest:(NSURLRequest *)urlRequest;

- (id)initWithHtmlString:(NSString *)htmlString baseURL:(NSURL *)baseURL;

@end
