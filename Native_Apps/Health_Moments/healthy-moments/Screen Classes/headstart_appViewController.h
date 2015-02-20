//
//  headstart_appViewController.h
//  healthy-moments
//
//  Created by Katz, Nevin on 9/4/13.
//  Copyright (c) 2013 Katz, Nevin. All rights reserved.
//

#import <UIKit/UIKit.h>


@class headstart_appAppDelegate;

@interface headstart_appViewController : UIViewController
{
    // portrait & landscape views
    
    UIView* portraitView;
    
    UIView* landscapeView;
    
    // screen dimensions
    
    int screenWidth;
    
    int screenHeight;
    
    // index of next screen
    
    int destination;
    
    NSMutableArray* nextListArray;
    
    headstart_appAppDelegate *appDelegate;
    
    IBOutlet UIWebView* webview;
    
    // button dimensions
    
    int dim;
    
    // arrays that store button positions
    
    int portrait_vertPos[6];
    
    int portrait_horizPos[6];
    
    int landscape_vertPos[6];
    
    int landscape_horizPos[6];
    
    // button images & labels
    
    NSString* images[6];
    
    NSString* labels[5];
}

@property int screenHeight;

@property int screenWidth;

@property UIView* portraitView;

@property UIView* landscapeView;

@property int destination;

@property headstart_appAppDelegate *appDelgate;

@property NSMutableArray* nextListArray;

@property IBOutlet UIWebView* webview;

@property int dim;
@end
