//
//  XMLParser.h
//  XML
//
//  Created by Chakra on 05/04/2011.


#import <UIKit/UIKit.h>


@class headstart_appAppDelegate, Section, Topic, SubTopic, VideoNode;

@interface XMLParser : NSObject <NSXMLParserDelegate> {

	NSMutableString *currentElementValue;
	
	headstart_appAppDelegate *appDelegate;
	
    Section *aSection;
    
    Topic *aTopic;
    
    SubTopic *aSubTopic;
    
    VideoNode *aVideo;
    
    NSString *currentElement;
    
    NSMutableArray* currentTopics;
    
    NSMutableArray* currentSubTopics;
    
    NSString* currentTitle;
}

- (XMLParser *) initXMLParser;

@property NSMutableString *currentElementValue;

@property headstart_appAppDelegate *appDelegate;

@property Section* aSection;

@property Topic* aTopic;

@property SubTopic *aSubTopic;

@property NSString *currentElement;

@property NSString* currentTitle;

@property NSMutableArray* currentTopics;

@property NSMutableArray* currentSubTopics;



@end
