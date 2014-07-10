//  Created by Alessio on 17/12/13.
//  Copyright (c) 2013 Alessio Orlando. All rights reserved.

#import "ALEWebViewController.h"


@implementation ALEWebViewController

#pragma mark - memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - view lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)init
{
    self = [super init];
    return self;
}

-(id)initWithURLRequest:(NSURLRequest *)urlRequest
{
    self = [super init];
    if (self) {
        self.urlRequest = urlRequest;
    }
    return self;
}

- (id)initWithHtmlString:(NSString *)htmlString baseURL:(NSURL *)baseURL
{
    self = [super init];
    if (self) {
        self.htmlString = htmlString;
        self.baseURL = baseURL;
    }
    return self;
}

-(void)loadView
{
    UIView *view = [[UIView alloc]init];
    self.view = view;
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    UIWebView *webview = [[UIWebView alloc]initWithFrame:self.view.frame];
    self.webView = webview;
    
    self.webView.delegate = self;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview:self.webView];
    
    UIActivityIndicatorView *aView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicator = aView;

    self.activityIndicator.frame = CGRectMake(0, 0, 30, 30);
    self.activityIndicator.hidesWhenStopped = YES;
    self.activityIndicator.center = self.view.center;
    self.activityIndicator.autoresizingMask = UIViewAutoresizingNone;
    
    [self.view addSubview:self.activityIndicator];
    
}

-(void)viewDidLayoutSubviews
{
    self.activityIndicator.center = self.view.center;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.urlRequest) {
        [self.webView loadRequest:self.urlRequest];
    }
    else if (self.htmlString) {
        [self.webView loadHTMLString:self.htmlString baseURL:self.baseURL];
    }
}

#pragma mark - webview delegate

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.activityIndicator startAnimating];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.activityIndicator stopAnimating];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.activityIndicator stopAnimating];
}

@end
