//
//  DynamicViewsViewController.h
//  DynamicViews
//
//  Created by nkatz on 3/20/13.
//  Copyright (c) 2013 nkatz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AudioToolbox/AudioToolbox.h"

#import "AVFoundation/AVFoundation.h"



@class Tile;

@interface DynamicViewsViewController : UIViewController

<NSXMLParserDelegate>

{
    int boardDim;
    
    int Level[10][10];
    
    NSXMLParser* xmlParser;
    
    bool getData;
    
    int rowCounter;
    
    int tileDim;
    
    bool isSomethingEnabled;
    
    UIView* gridView;
    
    UIView* mainView;
    
    int enteredBoardNumber;
    
    int shipTilesFound;
    
    int actualShipTiles;
    
    int boardPosY;
    
    int boardPosX;
    
    int time;
    
    AVAudioPlayer* player;
    
    int screenWidth;
    
    int screenHeight;
}

@property int boardDim;

@property int tileDim;

@property int boardPosX;

@property int boardPosY;

@property int Level;

@property int rowCounter;

@property bool getData;

@property  NSXMLParser* xmlParser;

@property bool isSomethingEnabled;

@property UIView* mainView;

@property UIView* gridView;

@property int enteredBoardNumber;

@property int shipTilesFound;

@property int actualShipTiles;

@property int time;

@property AVAudioPlayer* player;

@property int screenWidth;

@property int screenHeight;



@end


