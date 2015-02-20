//
//  Tile.h
//  DynamicViews
//
//  Created by nkatz on 3/20/13.
//  Copyright (c) 2013 nkatz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Tile : UIButton
{
    // the current state of the tile
   int myType;
   
   // its true identity
   int trueType;
    
   // its location on the tileboard
   CGPoint myLoc;
    
    bool clicked;
    
    // is it in the red?
    bool tooClose;
    
    // as it been changed since the touch has started?
    bool changed;
    
    bool isHint;
    
    NSString* hintImage;
    
}

@property int myType;
@property int trueType;
@property CGPoint myLoc;
@property bool clicked;
@property bool tooClose;
@property bool changed;

@property bool isHint;
@property NSString*  hintImage;

@end

/*
0 = covered
1 = water
2 = ship
*/