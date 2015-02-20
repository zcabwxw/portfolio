//
//  AboutScreen.h
//  healthy-moments
//
//  Created by Katz, Nevin on 9/14/13.
//  Copyright (c) 2013 Katz, Nevin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>


@class headstart_appAppDelegate, Section;


@interface AboutScreen : UITableViewController
<MFMailComposeViewControllerDelegate>
{

    
    UITableViewCell* myCell;
    NSMutableArray* listArray;
    
    headstart_appAppDelegate* appDelegate;
    
    Section* aSection;
    
    int aboutHeight, landHeight, portHeight;
    
    
    
    UITableViewCell* aboutCell;
    
    UITableViewCell* contactCell;
    
    UITableViewCell* ackCell;
    
    NSString* aboutString;
    
    int aboutWidth;
    
    int frameY;
    
    int landY, portY;
    
    int type;
    
    CGPoint linkLoc, portLoc, landLoc;
}


@property CGPoint linkLoc, portLoc, landLoc;

@property (nonatomic, retain) NSMutableArray* listArray;

@property UITableViewCell* myCell;

@property Section * aSection;

@property headstart_appAppDelegate* appDelegate;

@property int aboutHeight, landHeight, portHeight;

@property (nonatomic, retain)NSString* aboutString;

@property UITableViewCell* aboutCell;

@property UITableViewCell* contactCell;

@property UITableViewCell* ackCell;

@property int aboutWidth;

@property int frameY, landY, portY;

@property int type;


@end
