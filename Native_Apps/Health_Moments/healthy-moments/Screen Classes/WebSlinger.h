//
//  WebSlinger.h
//  healthy-moments
//
//  Created by Katz, Nevin on 9/9/13.
//  Copyright (c) 2013 Katz, Nevin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebSlinger : UIViewController <UIWebViewDelegate>
{
    UIView* mainView;
    
    IBOutlet UIWebView* webView;
    
    
    int section;
    
    int topic;
    
    int subtopic;
    
    int type;
    NSString* path;
    
    NSURLRequest* req;
    
    int screenWidth, screenHeight;
    
}

@property (nonatomic, retain) UIWebView *webView;

@property int section, topic, subtopic, type;

@property (nonatomic, retain) UIView* mainView;

@property (nonatomic, retain) NSString* path;

@property (nonatomic, retain) NSURLRequest* req;

@property int screenWidth, screenHeight;

@end
