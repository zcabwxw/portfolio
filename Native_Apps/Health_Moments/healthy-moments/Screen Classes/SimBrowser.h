//
//  WebSlinger.h
//  healthy-moments
//
//  Created by Katz, Nevin on 9/9/13.
//  Copyright (c) 2013 Katz, Nevin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SimBrowser : UIViewController <UIWebViewDelegate>
{
   
    
    IBOutlet UIWebView* webView;
    
    int section;
    
    int topic;
    
    int subtopic;
    
    NSString* path;
    
    NSURLRequest* req;
    
    int screenWidth, screenHeight;
    
    /*browser*/
    
    UIToolbar* mToolbar;
    UIBarButtonItem* mBack;
    UIBarButtonItem* mForward;
    UIBarButtonItem* mRefresh;
    UIBarButtonItem* mStop;
    UIBarButtonItem* mViewInSafari;
    
}
- (IBAction)ViewInSafariBrowser:(id)sender;



@property (nonatomic, retain) UIWebView *webView;

@property int section, topic, subtopic;

@property (nonatomic, retain) NSString* path;

@property (nonatomic, retain) NSURLRequest* req;

@property int screenWidth, screenHeight;

/*browser*/
 

@property (nonatomic, retain) IBOutlet UIToolbar* toolbar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* back;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* forward;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* refresh;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* stop;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* ViewInSafari;

@end
