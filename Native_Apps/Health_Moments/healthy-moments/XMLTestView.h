//
//  XMLTestView.h
//  healthy-moments
//
//  Created by Katz, Nevin on 9/6/13.
//  Copyright (c) 2013 Katz, Nevin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMLStringFile.h"

@interface XMLTestView : UIViewController

<NSXMLParserDelegate>
{
    IBOutlet UITableView *tableview;
	
	//mutable array to store data from rss feed and display in table view
	
	NSMutableArray *rssOutputData;
	
	//to store data from xml node
	
	NSMutableString *nodecontent;
	
	//declare the object of nsxml parse which will we use later for parsing
	
	NSXMLParser *xmlParserObject;
	
	
	//declare the object of nsobject class
	
	XMLStringFile *xmlStringFileObject;

}

@property (nonatomic, retain)IBOutlet UITableView *tableview;

@end
