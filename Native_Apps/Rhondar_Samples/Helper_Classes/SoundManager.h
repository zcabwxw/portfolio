//
//  SoundManager.h
//  GameEngine2
//
//  Created by Katz, Nevin on 1/12/15.
//  Copyright 2015 BirdleyMedia LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#define NUMPLAYERS 10

@interface SoundManager : CCNode {
  
  
    NSMutableArray* audioplayers;

}


extern NSString* const ENEMY_DEATH;

extern NSString* const ENEMY_DAMAGE;

extern NSString* const PLAYER_DAMAGE;

extern NSString* const SWORD_SLASH;

extern NSString* const LONG_SLASH;

extern NSString* const GET_KEY;

extern NSString* const SHOOT_ARROW;

extern NSString* const OPEN_DOOR;

extern NSString* const MENU_OPEN;

extern NSString* const MENU_CLOSE;

extern NSString* const HEALTH_REGEN;

extern NSString* const BOOMERANG_SOUND;

@property NSMutableArray* audioplayers;

-(id)init;

+(id)sharedSoundManager;

-(int) playSound: mySound;

@end
