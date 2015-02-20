//
//  SubTopic.h
//  healthy-moments
//
//  Created by Katz, Nevin on 9/8/13.
//  Copyright (c) 2013 Katz, Nevin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VideoNode;
@interface SubTopic : NSObject
{
    int type; // 0 = webslinger, 1 = videos, 2 = textpage
    NSString* subtopic_title;
    
    NSString* page;
    
    NSMutableArray* subtopic_content;
    
    NSURL* url;
    
    NSURLRequest* req;
    
    IBOutlet UIWebView* webView;
   
    NSMutableArray* videos;
    
    
    
    
}

@property  NSString* subtopic_title;

@property NSString* page;

@property NSMutableArray* subtopic_content;

@property NSURL* url;

@property NSURLRequest* req;

@property IBOutlet UIWebView* webView;

@property NSMutableArray* videos;

@property int type;

@end
