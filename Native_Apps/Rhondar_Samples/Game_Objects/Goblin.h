//
//  goblin.h
//  Rhondar
//
//  Created by nkatz on 12/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Enemy.h"
#import "Globals.h"
#import "SimpleItem.h"

//#import "Player.h"

#define GPARTS 8
#define DIRECTIONS 4
#define STANCES 2

#define HEAD 0
#define ARMOUR 1
#define MAIN_ARM 2
#define HAND 3
#define BACKARM 4
#define LEGHAND 5
#define STAFF 6

// correlates with goblin directions

#define NONE 0
#define HORIZ 1
#define VERT 2



#define CHASEDIST 128

#define BARPOS 32

typedef struct {
    CGPoint points[STANCES][DIRECTIONS][GPARTS];
    int indices[STANCES][DIRECTIONS][GPARTS];
} GMatrix;

@interface Goblin : Enemy {
    
    
    // debugging

    // animation
    
    GMatrix* SpriteMatrix;
    
    int walkCounter, bob;
    
    GameLayer* gLayer;
    
    // collision detection & direction

    int chase;
    
    int last_tried;
    
    int stored_direction;
    
    int stance, striking, recentSwitch;

     // combat
    
    int weaponDamage, baseDamage;
    
    CGPoint stunVel;
    
    // striking
    
    CGPoint attackPoint;
    
    float strikeDur;

    NSTimeInterval strikeStart, strikeStop;
    
    float strikeTimeSoFar;
    
    float refractory_period;
}


+(id) goblin;

-(id) initGoblin;

@property float strikeTimeSoFar, refractory_period;

@property float strikeDur;



@property NSTimeInterval strikeStart, strikeStop;

@property GameLayer* gLayer;

@property int chase, last_tried;


//@property CCSprite *head, *armour, *arm1, *arm2, *leg1, *hand1, *hand_leg, *weapon;

@property GMatrix *SpriteMatrix;

@property int walkCounter, bob, stance, striking, recentSwitch;

@property int stored_direction;

@property CGPoint attackPoint;

@property int weaponDamage, baseDamage;

@property CGPoint stunVel;


//@property int arm_rotateGoal, staff_rotateGoal, arm_rotateIncr, staff_rotateIncr;


@end