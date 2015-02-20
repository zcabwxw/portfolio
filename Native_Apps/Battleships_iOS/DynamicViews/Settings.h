//
//  Settings.h
//  Battleship
//
//  Created by nkatz on 4/1/13.
//  Copyright (c) 2013 nkatz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Settings : UIViewController

{

    int dimensions;
    
    int myLevel;
    
    int screenWidth;
    
    int screenHeight;
}

@property int dimensions;

@property int myLevel;

@property int screenWidth;

@property int screenHeight;


@end
