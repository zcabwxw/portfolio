//
//  HitDetect.h
//  GameEngine2
//
//  Created by Katz, Nevin on 1/29/15.
//  Copyright 2015 BirdleyMedia LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Globals.h"
#import "Player.h"
#import "GameLayer.h"
#import "ArrayManager.h"
#import "SoundManager.h"

@class GameLayer;
@class Player;

@interface HitDetect : CCNode {
    
    SoundManager* soundManager;
    
    NSMutableArray* blockPoints;
    
    NSMutableArray* Doors;
    
    ArrayManager* arrM;
    
    Player* myPlayer;
    
    GameLayer* game_layer;
    
    int head_top_margin;
    
}



@property SoundManager* soundManager;

@property ArrayManager* arrM;

@property NSMutableArray* blockPoints;

@property NSMutableArray* Doors;

@property Player* myPlayer;

@property GameLayer* game_layer;

@property int head_top_margin;

-(id) init;

+(id) SharedHitDetect;

-(int)wallCollision;

-(int)doorCollision;

-(Boolean) isLeftOpen;
-(Boolean) isRightOpen;
-(Boolean) isUpOpen;
-(Boolean) isDownOpen;

-(Boolean) hitCollision: (CGPoint) blockPoint size:(CGSize)obstacle_size;

@end
