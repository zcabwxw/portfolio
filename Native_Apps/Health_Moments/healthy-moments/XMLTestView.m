//
//  XMLTestView.m
//  healthy-moments
//
//  Created by Katz, Nevin on 9/6/13.
//  Copyright (c) 2013 Katz, Nevin. All rights reserved.
//

#import "XMLTestView.h"

@interface XMLTestView ()


@end

@implementation XMLTestView
@synthesize tableview;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark NSXMLParser delegate

//below delegate method is sent by a parser object to provide its delegate when it encounters a start tag

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
	//if element name is equat to item then only i am assingning memory to the NSObject class
    
	if([elementName isEqualToString:@"item"]){
		xmlStringFileObject =[[XMLStringFile alloc]init];
	}
	
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	//whatever data i am getting from node i am appending it to the nodecontent variable
	[nodecontent appendString:[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    NSLog(@"node content = %@",nodecontent);
}

//bellow delegate method specify when it encounter end tag of specific that tag

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	//I am saving my nodecontent data inside the property of XMLString File class
	
	if([elementName isEqualToString:@"title"]){
		xmlStringFileObject.xmlTitle=nodecontent;
	}
	else if([elementName isEqualToString:@"link"]){
		xmlStringFileObject.xmlLink=nodecontent;
	}
	
	//finally when we reaches the end of tag i am adding data inside the NSMutableArray
	if([elementName isEqualToString:@"item"]){
        
		[rssOutputData addObject:xmlStringFileObject];

        xmlStringFileObject = nil;
	}
	//release the data from mutable string variable
	
    
	//reallocate the memory to get new content data from file
	nodecontent=[[NSMutableString alloc]init];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    NSLog(@"here");
    rssOutputData = [[NSMutableArray alloc]init];
    
    //declare the object of allocated variable
    NSData *xmlData=[[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:@"http://images.apple.com/main/rss/hotnews/hotnews.rss"]];
    
    //allocate memory for parser as well as
    xmlParserObject =[[NSXMLParser alloc]initWithData:xmlData];
    [xmlParserObject setDelegate:self];
    
    //asking the xmlparser object to begin with its parsing
    [xmlParserObject parse];

    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma Mark For Table View Method:-

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return[rssOutputData count];
	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *MyIdentifier = @"MyIdentifier";
	
	// Try to retrieve from the table view a now-unused cell with the given identifier
	//UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	
	
	// If no cell is available, create a new one using the given identifier
	if (cell == nil) {
		//cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
		
		//add some extra text on table cell .........
		cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle   reuseIdentifier:MyIdentifier];
		
	}
	// Set up the cell
	[cell.textLabel setFont:[UIFont fontWithName:@"Verdana" size:12]];
	[cell.detailTextLabel setFont:[UIFont fontWithName:@"Verdana" size:12]];
	cell.textLabel.text=[[rssOutputData objectAtIndex:indexPath.row]xmlTitle];
	cell.detailTextLabel.text=[[rssOutputData objectAtIndex:indexPath.row]xmlLink];
	
	return cell;
}

- (void)dealloc {

  
}

@end


