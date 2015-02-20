//
//  XMLTest.h
//  healthy-moments
//
//  Created by Katz, Nevin on 9/6/13.
//  Copyright (c) 2013 Katz, Nevin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMLStringFile.h"

@interface XMLTest : UITableViewController
<NSXMLParserDelegate>
{
    // store data from RSS feeds, display inside table
    NSMutableArray *rssOutputData_MutableArray;
    
    // store data from xml node
    NSMutableString *nodecontent;
    
    // declare object of NSXMLParser which will e used for parsing
    NSXMLParser *xmlParserObject;
    
    // declare object of NSObject subclass file (we added this!)
    XMLStringFile *XMLStringFileObject;
}

-(void)parser:(NSXMLParser*)parser didStartElement:(NSString*)elementName namespaceURI:(NSString*)namespaceURI qualifiedName:(NSString*)qualifiedName attributes:(NSDictionary*)attributeDict;

-(void)parser:(NSXMLParser*)parser foundCharacters:(NSString*)string;

-(void)parser:(NSXMLParser*)parser didEndElement:(NSString*)elementName namespaceURI:(NSString*)namespaceURI qualifiedName:(NSString*)qName;



@end
