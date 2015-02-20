//
//  Topic.h
//  healthy-moments
//
//  Created by Katz, Nevin on 9/7/13.
//  Copyright (c) 2013 Katz, Nevin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Topic : NSObject
{
    NSString *topic_title;
    
    NSInteger topicID;
    
    NSMutableArray* content;
    
    NSMutableArray* subtopics;
    
    IBOutlet UIWebView* webView;

    
}

@property NSString* topic_title;

@property NSInteger topicID;

@property NSMutableArray* content;

@property NSMutableArray* subtopics;


@property IBOutlet UIWebView* webView;





@end
