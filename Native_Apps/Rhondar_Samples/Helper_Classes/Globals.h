//
//  Globals.h
//  GameEngine2
//
//  Created by Katz, Nevin on 6/14/14.
//  Copyright 2014 BirdleyMedia LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "ItemNode.h"

#define BOT 0
#define TOP 1

#define FRONT 0
#define BACK 1

#define DOWN 0
#define UP 1

#define RIGHT 2
#define LEFT 3

// phase out ONE!
#define TILESIZE 64
#define TILEDIM 64

#define SWORD 0
#define FROSTBYTER_ESSENCE 1
#define BOOMERANG 2
#define MEDICINE 3

#define DOWNBIT 1
#define UPBIT 2
#define RIGHTBIT 4
#define LEFTBIT 8

@interface Globals : NSObject {
    
    float contentScaleFactor;
}


// probably good for sprites...

//extern int TOP, BOT, FRONT, BACK, UP, DOWN, RIGHT, LEFT;

extern NSString* const BOOMERANG_IMG;

extern NSString* const FROSTBYTER_ESSENCE_IMG;

extern NSString* const SWORD_IMG;

extern NSString* const MEDICINE_IMG;


@property float contentScaleFactor;

+(id) myGlobals;

@end
