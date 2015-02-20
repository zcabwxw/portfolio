//
//  WebSlinger.m
//  healthy-moments
//
//  Created by Katz, Nevin on 9/9/13.
//  Copyright (c) 2013 Katz, Nevin. All rights reserved.
//

#import "SimBrowser.h"

@interface SimBrowser ()

@end

@implementation SimBrowser

@synthesize webView;



@synthesize section, topic, subtopic;

@synthesize path;

@synthesize req;

@synthesize screenWidth, screenHeight;

/*browser*/

@synthesize toolbar = mToolbar;
@synthesize back = mBack;
@synthesize forward = mForward;
@synthesize refresh = mRefresh;
@synthesize stop = mStop;
@synthesize ViewInSafari = mViewInSafari;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // declare main view!
    
    NSAssert(self.back, @"Unconnected IBOutlet 'back'");
    NSAssert(self.forward, @"Unconnected IBOutlet 'forward'");
    NSAssert(self.refresh, @"Unconnected IBOutlet 'refresh'");
    NSAssert(self.stop, @"Unconnected IBOutlet 'stop'");
    NSAssert(self.webView, @"Unconnected IBOutlet 'webView'");
    
    self.webView.delegate = self;

    [self.webView loadRequest:req];
    [self updateButtons];
    
    self.webView.scalesPageToFit = YES;
    
    screenWidth = 320;

    screenHeight = 480;
       
 
       
    // assign main view to self view
    [self.view addSubview:webView];
    
    
    
 
    
    
}
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}
- (BOOL)shouldAutoRotate {
    return YES;
}







- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self updateButtons];
}
- (void)webViewDidFinishLoad:(UIWebView *)mywebView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    NSString* title = [mywebView stringByEvaluatingJavaScriptFromString: @"document.title"];
    self.title = title;
    
    [self updateButtons];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self updateButtons];
}

- (void)updateButtons
{
    self.forward.enabled = self.webView.canGoForward;
    self.back.enabled = self.webView.canGoBack;
    self.stop.enabled = self.webView.loading;
}
- (void)viewDidUnload
{
    self.webView = nil;
    self.toolbar = nil;
    self.back = nil;
    self.forward = nil;
    self.refresh = nil;
    self.stop = nil;
    self.ViewInSafari = nil;
    [super viewDidUnload];
}

- (IBAction)ViewInSafariBrowser:(id)sender {
    
    NSString *currentURL = webView.request.URL.absoluteString;
    

    NSURL *url = [NSURL URLWithString:currentURL];

     [[UIApplication sharedApplication] openURL:url];
}
@end
