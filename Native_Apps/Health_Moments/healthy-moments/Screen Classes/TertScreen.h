//
//  TertScreen.h
//  healthy-moments
//
//  Created by Katz, Nevin on 9/5/13.
//  Copyright (c) 2013 Katz, Nevin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SubTopic, SimBrowser;

@interface TertScreen : UITableViewController

{
    NSMutableArray* listArray;
    
    NSMutableArray* pageArray;
    
    NSMutableArray* requests;
    
    NSMutableArray* webviews;
    
    NSMutableArray* subtopics;
    
    SubTopic* aSubTopic;
    
    NSInteger type;
    
    NSInteger subtype;
    
    NSInteger destination;
}
@property (nonatomic, retain) NSMutableArray* listArray;

@property (nonatomic, retain) NSMutableArray* pageArray;

@property (nonatomic, retain) NSMutableArray* requests;

@property (nonatomic, retain) NSMutableArray* webviews;

@property (nonatomic, retain) NSMutableArray* subtopics;

@property NSInteger type;

@property NSInteger subType;

@property NSInteger destination;

@end
