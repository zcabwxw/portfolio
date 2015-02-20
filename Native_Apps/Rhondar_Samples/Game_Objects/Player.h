//
//  Player.h
//  DoodleDrop
//
//  Created by nkatz on 12/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Enemy.h"
#import "Movable.h"
#import "Fightable.h"
#import "Phase.h"

@class MovingItem;
@class SwordItem;
@class Phase;


#define PARTS 6
#define DIRECTIONS 4
#define STANCES 2



typedef struct {
    CGPoint points[STANCES][DIRECTIONS][PARTS];
} CoordMatrix;

@interface Player : Fightable
{
    Boolean attacking, moving, attackFinish;
    
    CCSprite *head, *body, *front_arm, *back_arm, *leg1, *leg2, *item1, *item2, *arc;
 
    int bob, walkCounter, strikeMove, strikeCounter, strikeDirection;
    
    int arm_id, leg_id, head_id, tunic_id;
    
    float dim;
    
    MovingItem* myItem;
    
    SwordItem* swordItem;
    
    Phase *itemPhase, *armPhase, *arcPhase;
    
    CoordMatrix* SpriteMatrix;
    
    int playerWidth;
    
    CGSize size;
    
    CGPoint intention;
    
    int left_player_edge, top_player_edge, bot_player_edge, right_player_edge;
    
    float invincible_time_so_far, invTime;
    
    NSTimeInterval damageStart, recoveryStart;
}

@property CGPoint intention;
// sets positions of sprite!
@property (assign) CoordMatrix* SpriteMatrix;

@property NSTimeInterval damageStart, recoveryStart;

@property float invincible_time_so_far, invTime;

// properties
@property Boolean attacking, moving, attackFinish;

@property int playerWidth;

@property float dim;

// sprite variables, *
@property CCSprite *head, *body, *front_arm, *back_arm, *leg1, *leg2, *item;



@property int bob, walkCounter, strikeMove, strikeCounter;

@property int strikeDirection;

@property (nonatomic, strong) MovingItem *myItem;
@property (nonatomic, strong) SwordItem  *swordItem;
@property (nonatomic, retain) Phase *itemPhase, *armPhase, *arcPhase;

@property int arm_id, leg_id, head_id, tunic_id;

@property CGSize size;

// classes
+(id) player1;
-(id) init;

// movement methods
-(void) strike;
-(void) walk;
-(void) takeStep: (NSString*) fileName;
-(void) returnStance;
-(void) throwMotion;

-(void) onPause;
-(void) onResume;
@end
