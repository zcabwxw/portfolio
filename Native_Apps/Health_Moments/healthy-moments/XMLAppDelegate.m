//
//  XMLAppDelegate.m
//  XML
//
//  Created by Chakra on 05/04/2011.

#import "XMLAppDelegate.h"
//#import "RootViewController.h"
#import "XMLParser.h"
#import "headstart_appViewController.h"

@implementation XMLAppDelegate

@synthesize window;
@synthesize navigationController, sections;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	// get the data
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"appdata" ofType:@"xml"]];
    
    
	NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:url];
	
	//Initialize the delegate.
	XMLParser *parser = [[XMLParser alloc] initXMLParser];
	
	//Set delegate
	[xmlParser setDelegate:parser];
	
	//Start parsing the XML file.
	BOOL success = [xmlParser parse];
	
	if(success)
		NSLog(@"No Errors");
	else
		NSLog(@"Error Error Error!!!");
	
	// Configure and show the window
//	[window addSubview:[navigationController view]];
//	[window makeKeyAndVisible];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
}


- (void)dealloc {

}

@end
