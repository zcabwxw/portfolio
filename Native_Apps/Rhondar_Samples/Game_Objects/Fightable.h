//
//  Fightable.h
//  GameEngine2
//
//  Created by Katz, Nevin on 6/22/14.
//  Copyright 2014 BirdleyMedia LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Movable.h"
#import "ArrayManager.h"
#import "SoundManager.h"
#import "SimpleItem.h"
@interface Fightable : Movable {
  
    int stunSpeed;
    
    int attackDamage;
    
    int health;
    
    int maxHealth;
    
    bool showingDamage;
    
    bool hitTop, hitBot, hitRight, hitLeft;
    
    ArrayManager* arrayManager;
    
    SoundManager* soundManager;
   
    bool killed;
    
    NSString* damageSound;
    
    NSMutableArray* deathFrames;
    
    Boolean invincible;
    
    float damageTime, dmgTimeSoFar;
}

@property float damageTime, dmgTimeSoFar;

@property Boolean invincible;

@property ArrayManager* arrayManager;

@property SoundManager* soundManager;

@property NSString* damageSound;

@property int stunSpeed;

@property int attackDamage;

@property int health, maxHealth;

@property bool killed;

@property bool showingDamage;

@property bool hitTop, hitBot, hitRight, hitLeft;

@property NSMutableArray* deathFrames;

-(void) damageState: (SimpleItem*) foe;

-(void) stun: (CGPoint) foeVelocity;

-(void) setSpriteColor: (ccColor3B) style;

-(void) removeMe;

-(void) initSounds;

-(void) deathAnimation:(int)index;


-(void) recoveryState;

-(void) dmgFX;

-(void) normalColor;

-(void) decrementHealth:(SimpleItem*)weapon;

-(void) showDamage:(CCTime)dt;
-(CGPoint) stunDir: (CGPoint) vel dir:(int)d;
@end
