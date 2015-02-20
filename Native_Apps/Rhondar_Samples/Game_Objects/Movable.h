//
//  Movable.h
//  GameEngine2
//
//  Created by Katz, Nevin on 6/21/14.
//  Copyright 2014 BirdleyMedia LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Phase.h"
#import "SimpleItem.h"

@interface Movable : SimpleItem {
    
    int counter;
    
    int origSpeed, moveSpeed;
    
    int orientation;
    
    int scaleFactor;
    
    CCSpriteFrameCache* frameCache;
    
    CGPoint origin;
    
    NSMutableArray *parts;
    
    CCSprite* left_signal, *right_signal, *top_signal, *bot_signal, *attack_point;
    
    CCLabelTTF* status;
    
}


@property int counter;

@property int orientation;

@property int origSpeed, moveSpeed;

@property int scaleFactor;

@property CCSpriteFrameCache* frameCache;

@property CGPoint origin;

@property NSArray *parts;

@property CCSprite* left_signal, *right_signal, *top_signal, *bot_signal, *attack_point;

@property  CCLabelTTF* status;

-(void) spriteProps: (Phase*) myPhase andSprite: (CCSprite*) mySprite;

-(void) setSprites: (NSArray*) files;

-(void) addSprite: (CCSprite*) mySprite z: (int) zi;

-(void) addSignals;

-(void) onPause;

-(void) onResume;

-(void) setOpacity: (float) opacity;
@end
