//
//  Section.h
//  healthy-moments
//
//  Created by Katz, Nevin on 9/6/13.
//  Copyright (c) 2013 Katz, Nevin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Topic.h"

#import "SubTopic.h"



@interface Section : NSObject
{
    NSInteger sectionID;
    
    /*titles*/
    
    NSString *title;
    
    NSString* back_title;
    
    NSString* screen_title;
 
    /* sub nodes */
    
    NSMutableArray* topics;
    
 
    Topic* topic;
    
    NSString* topic_title;
    
    NSString* content;
    
    NSString* subtopic_title;
    
    SubTopic* subtopic;
    
    NSString* li;
    
    NSString* page;
    
    UIWebView* webView;
    
    /*video*/
    
    NSString* video;
    
    NSString* videos;
    
    NSString* video_title;
    
    NSString* video_path;
    
    NSString* thumbnail;
    
    NSString* description;
    
    NSString* info;
    
    NSString* mylinks;
    
    NSString* section_content;

}

@property (nonatomic, retain) UIWebView* webView;
@property (nonatomic, readwrite) NSInteger sectionID;

@property (nonatomic, retain) NSString *title;

@property (nonatomic, retain) NSString *back_title;

@property (nonatomic, retain) NSString *screen_title;

@property (nonatomic, retain) NSString *topic_title;

@property (nonatomic, retain) NSMutableArray* topics;

@property (nonatomic, retain) Topic* topic;

@property (nonatomic, retain) NSString* content;

@property (nonatomic, retain) NSString* subtopic_title;

@property (nonatomic, retain) SubTopic* subtopic;

@property (nonatomic, retain) NSString* li;

@property (nonatomic, retain) NSString* page;

@property (nonatomic, retain) NSString* info;

@property NSString* mylinks;

/*video*/

@property NSString* video;

@property NSString* videos;

@property NSString* video_title;

@property NSString* video_path;

@property NSString* thumbnail;

@property NSString* description;

@property NSString* section_content;


@end
