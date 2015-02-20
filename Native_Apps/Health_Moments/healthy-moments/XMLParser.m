//
//  XMLParser.m
//  XML
//
//  Created by Chakra on 05/04/2011.


#import "XMLParser.h"
#import "headstart_appAppDelegate.h"

#import "Section.h"
#import "Topic.h"

#import "SubTopic.h"

#import "VideoNode.h"

@implementation XMLParser
@synthesize aSection;
@synthesize aTopic;
@synthesize aSubTopic;
@synthesize currentElementValue;
@synthesize appDelegate;
@synthesize currentTitle;

@synthesize currentElement;

@synthesize currentTopics;

@synthesize currentSubTopics;

- (XMLParser *) initXMLParser {
	
	
	
	appDelegate = (headstart_appAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qualifiedName
	attributes:(NSDictionary *)attributeDict
{
	
	if([elementName isEqualToString:@"sections"]) {
        
		//Initialize the array.
        
    
        
		appDelegate.sections = [[NSMutableArray alloc] init];
        
  
        
	}
	else if([elementName isEqualToString:@"section"]) {
		
            currentTopics = [[NSMutableArray alloc] init];
        
        currentElement = @"section";
    
		//Initialize the book.
		aSection = [[Section alloc] init];
		
        // initialize the topics array...
        aSection.topics = [[NSMutableArray alloc]init];
        
		//Extract the attribute here.
		aSection.sectionID = [[attributeDict objectForKey:@"id"] integerValue];
        
        
		
		
	}
    else if ([elementName isEqualToString:@"topic"])
    {
        currentElement = @"topic";
        
        aTopic = [[Topic alloc] init];
        
        aTopic.subtopics = [[NSMutableArray alloc] init];
    }
    else if ([elementName isEqualToString:@"subtopic"])
    {
        currentElement=@"subtopic";
        
        aSubTopic = [[SubTopic alloc] init];
        
        aSubTopic.subtopic_content = [[NSMutableArray alloc] init];
        
        aSubTopic.req = [[NSURLRequest alloc] init];
        
        aSubTopic.url = [[NSURL alloc] init];
        
        aSubTopic.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    }
    else if ([elementName isEqualToString:@"title"])
    {
        currentElement = @"title";
    }
    else if ([elementName isEqualToString:@"topic_title"])
    {
        currentElement=@"topic_title";
    
    }
    else if ([elementName isEqualToString:@"subtopic_title"])
    {
        currentElement=@"subtopic_title";
    }
   
    else if ([elementName isEqualToString:@"content"])
    {
        currentElement=@"content";
        
        aTopic.content = [[NSMutableArray alloc] init];
    }
    else if ([elementName isEqualToString:@"videos"])
    {
        aSubTopic.videos = [[NSMutableArray alloc] init];
    }
    else if ([elementName isEqualToString:@"video"])
    {
        aVideo = [[VideoNode alloc] init];
    }
    else if ([elementName isEqualToString:@"back_title"])
    {
       
        currentElement=@"back_title";
    }
	

}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string { 
	
	if(!currentElementValue) 
		currentElementValue = [[NSMutableString alloc] initWithString:string];
	else
		[currentElementValue appendString:string];

	
   
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	
	if([elementName isEqualToString:@"sections"])
    {

		return;
    }
    if ([elementName isEqualToString:@"topic"])
    {
        // add the current topic to current topics array.
        [currentTopics addObject: aTopic];
    }
    if ([elementName isEqualToString:@"topic_title"])
    {
        
        
        
       // [currentTopics addObject:currentElementValue];
        
        aTopic.topic_title = [self refineString:(NSString*)currentElementValue];
        
  
        
        
        
    }
    if ([elementName isEqualToString:@"content"])
    {
        aTopic.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
        
        aTopic.webView = [self renderWebView:currentElementValue];
    }
    if ([elementName isEqualToString:@"subtopic"])
    {
        // if we are finishing a subtopic, add it to topics
        [aTopic.subtopics addObject: aSubTopic];
    }
    if ([elementName isEqualToString:@"subtopic_title"])
    {
        // add this title to the subtopic
        aSubTopic.subtopic_title = [self refineString:(NSString*)currentElementValue];
        
    }
    if ([elementName isEqualToString:@"mylinks"])
    {
        aSubTopic.type = 2;
        
        aSubTopic.webView = [self renderWebView:currentElementValue];
  
    }
    if ([elementName isEqualToString:@"page"])
    {
       
        aSubTopic.type = 0;
 
        
        aSubTopic.webView = [self renderWebView:currentElementValue];
        
       
        
      
    }
    if ([elementName isEqualToString:@"videos"])
    {
        aSubTopic.type = 1;
    }
    if ([elementName isEqualToString:@"video"])
    {
        [aSubTopic.videos addObject:aVideo];
    }
    if ([elementName isEqualToString:@"video_title"])
    {
        aVideo.title = [self refineString:(NSString*)currentElementValue];
    }
    if ([elementName isEqualToString:@"video_path"])
    {
        aVideo.path = [self refineString:(NSString*)currentElementValue];
    }
    if ([elementName isEqualToString:@"thumbnail"])
    {
        aVideo.thumbnail = [self refineString:(NSString*)currentElementValue];
    }
    if ([elementName isEqualToString:@"description"])
    {
        aVideo.description = [self refineString:(NSString*)currentElementValue];

    }
    if ([elementName isEqualToString:@"info"])
    {
        aSection.info = [self refineString:(NSString*)currentElementValue];
        
        aSection.webView = [self renderWebView:currentElementValue];
    }
    if ([elementName isEqualToString:@"back_title"])
    {
        aSection.back_title = [self refineString:(NSString*)currentElementValue];
    }
    if ([elementName isEqualToString:@"screen_title"])
    {
        aSection.screen_title = [self refineString:(NSString*)currentElementValue];
    }
   

	
	//There is nothing to do if we encounter the Sections element here.
	//If we encounter the Section element howevere, we want to add the section object to the array
	// and release the object.
	if([elementName isEqualToString:@"section"]) {
        
        // add section contents here
        
        for (int i = 0; i < currentTopics.count; i++)
        {
            [aSection.topics addObject:[currentTopics objectAtIndex:i]];
        }
        
        aSection.title = [self refineString:(NSString*)aSection.title];
        
        aSection.back_title = [self refineString:(NSString*)aSection.back_title];
        
        aSection.screen_title = [self refineString:(NSString*)aSection.screen_title];
        // then add the section object
		[appDelegate.sections addObject:aSection];
		
		
        aTopic = nil;
        aSubTopic = nil;
		aSection = nil;
        currentTopics = nil;
    
	}
	else
    {
		[aSection setValue:currentElementValue forKey:elementName];
    }
	
		currentElementValue = nil;
}

-(UIWebView*) renderWebView: (NSString*) str 
{
    NSString* page = [self refineString:(NSString*)str];
    
    NSURL* url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:page ofType:@"html"]];
    
    NSURLRequest* req = [NSURLRequest requestWithURL:url];
    
    
    UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,0,320,480)];
    
    // not sure if I need this...
    webView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    [webView loadRequest:req];
    
    
    
    return webView;
}
-(NSURLRequest*) getRequest:(NSString*) str
{
    NSString* page = [self refineString:(NSString*)str];
    
    NSURL* url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:page ofType:@"html"]];
    
    NSURLRequest* req = [NSURLRequest requestWithURL:url];
    
    return req;
}

-(NSString*)refineString: (NSString*) myString
{
    NSString* refinedString = [myString stringByReplacingOccurrencesOfString:@">" withString:@""];
    
    refinedString= [refinedString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return refinedString;
    
}

- (void) dealloc {

}

@end
