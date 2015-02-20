//
//  WebSlinger.m
//  healthy-moments
//
//  Created by Katz, Nevin on 9/9/13.
//  Copyright (c) 2013 Katz, Nevin. All rights reserved.
//

#import "WebSlinger.h"

#import "SimBrowser.h"

#import "ContactScreen.h"

@interface WebSlinger ()

@end

@implementation WebSlinger

@synthesize webView;

@synthesize mainView;

@synthesize section, topic, subtopic, type;

@synthesize path;

@synthesize req;

@synthesize screenWidth, screenHeight;

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
    
    type = 0;
    screenWidth = 320;
    
    screenHeight = 480;
    
    webView.delegate = self;
    
    // for external links
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Links"
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:nil
                                                                            action:nil];
    
                                                
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:)name:@"UIDeviceOrientationDidChangeNotification" object:nil];

    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
       
        webView.frame=CGRectMake(0,0,screenHeight,screenWidth);
    }
    else
    {
       webView.frame=CGRectMake(0,0,screenWidth,screenHeight);
    }
    
    // assign main view to self view
    self.view = webView;
    
    [self goBack];
   
  
}
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}
- (BOOL)shouldAutoRotate {
    return YES;
}

- (void)orientationChanged:(NSNotification*)object
{
    UIDeviceOrientation deviceOrientation = [[object object] orientation];
    
    if (deviceOrientation == UIInterfaceOrientationLandscapeLeft || deviceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        webView.frame=CGRectMake(0,0,screenHeight,screenWidth);
    }
    else if (deviceOrientation == UIInterfaceOrientationPortrait || deviceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        webView.frame=CGRectMake(0,0,screenWidth,screenHeight);
        
    }
    
}

- (void)goBack
{
    if ([webView canGoBack]) {
        
            [webView goBack];
      //  [webView loadHTMLString:_htmlString baseURL:nil];

    }

}
-(void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    
    if (type == 1) // link out to browser from a links page
    {
        SimBrowser* controller = (SimBrowser*)segue.destinationViewController;
    
        NSURL* url = [NSURL URLWithString:path];
    
        NSURLRequest* myReq = [NSURLRequest requestWithURL:url];
    
        controller.req = myReq;
    }
    else if (type == 2) // crosslink from a regular page
    {
        WebSlinger* controller = (WebSlinger*)segue.destinationViewController;
        
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:path ofType:@"html"]];
        
        NSURLRequest* myReq = [NSURLRequest requestWithURL:url];
        
        UIWebView* nextWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0,0,320,480)];
        
        // not sure if I need this...
        nextWebView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        
        [nextWebView loadRequest:myReq];

        
        controller.webView = nextWebView;
        
        
    }
 
    
}
-(BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
  
    NSString* myString = [[request URL] absoluteString];
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        if ([myString hasPrefix:@"btn://"])
        {
            if ([myString hasSuffix:@"contactform"])
            {
                [self performSegueWithIdentifier:@"InfoToContact" sender:self];
                
                self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Info"
                                                                                         style:UIBarButtonItemStyleBordered
                                                                                        target:nil
                                                                                        action:nil];
            }
            return NO;
        }
        else if ([myString hasPrefix:@"int://"]) // crosslink
        {
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                                     style:UIBarButtonItemStyleBordered
                                                                                    target:nil
                                                                                    action:nil];
            
            type = 2;
            
            path = [[NSString alloc] init];
            
            path = ([myString lastPathComponent]);
            
             [self performSegueWithIdentifier:@"InfoToInfo" sender:self];
            
            return NO;
        }
        else
        {
            if ([self.title isEqual: @"Acknowledgements"])
            {
                self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Acknowledgements"
                                                                                         style:UIBarButtonItemStyleBordered
                                                                                        target:nil
                                                                                        action:nil];

            }
            type = 1; // this denotes a list of links so that a segue is performed.
            
            path = [[NSString alloc] init];
            path =[myString stringByReplacingOccurrencesOfString:@"ext" withString:@"http"];
           
            [self performSegueWithIdentifier:@"LinksToBrowser" sender:self];
            
            return NO;
            
          
        }
       
        
    }
    return YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
