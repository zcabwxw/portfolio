//
//  InfoScreen.h
//  healthy-moments
//
//  Created by Katz, Nevin on 9/5/13.
//  Copyright (c) 2013 Katz, Nevin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoScreen : UIViewController
{
    UIScrollView* mainView;
    
    NSString* myTitle;
    
    int section;
    
    int topic;
    
    int subtopic;
    
    int infoType; // 0 for topic background, 1 for subtopic info
    
    NSMutableArray* infoList;
    
    int screenWidth;
    
    int screenHeight;
    
    UITextView* myLabel;
    
}

@property IBOutlet UIScrollView* mainView;

@property int section;

@property int topic;

@property int subtopic;

@property int infoType;

@property NSMutableArray* infoList;

@property int screenWidth;

@property int screenHeight;

@property UITextView* myLabel;


@end
