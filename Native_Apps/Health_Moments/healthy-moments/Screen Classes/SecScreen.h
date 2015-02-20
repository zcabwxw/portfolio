//
//  SecScreen.h
//  healthy-moments
//
//  Created by Katz, Nevin on 9/5/13.
//  Copyright (c) 2013 Katz, Nevin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class headstart_appAppDelegate, Section;

@interface SecScreen : UITableViewController
{
    int type;
    
    NSMutableArray* listArray;
    
    IBOutlet UITableView* myList;
    
    NSInteger destination;
    
    headstart_appAppDelegate* appDelegate;
    
    Section* aSection;

}

@property int type;

@property (nonatomic, retain) UITableView* myList;

@property (nonatomic, retain) NSMutableArray* listArray;

@property NSInteger destination;

@property headstart_appAppDelegate *appDelegate;

@property Section* aSection;


@end
