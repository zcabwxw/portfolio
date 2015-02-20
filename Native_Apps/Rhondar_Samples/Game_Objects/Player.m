/*
Next up: 
 
 Fix Indents
 Make SetSpriteParts variables intrinsic to the character? 
 Try an inheritance pattern with current player. 
 Extend logic to goblin
 Finish Goblin Sprites
 
 */

//
//  Player.m
//  DoodleDrop
//
//  Created by nkatz on 12/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Player.h"
#import "GameLayer.h"
#import "UserInterfaceLayer.h"
#import "CCAnimation.h"
#import "Enemy.h"
#import "SwordItem.h"
#import "MovingItem.h"
#import "Item_Manager.h"
// remember to add class to GameLayer


@interface Player (PrivateMethods)

-(id) init;

@end

@implementation Player

@synthesize size;

@synthesize SpriteMatrix;
@synthesize attacking, moving, attackFinish;

@synthesize myItem = _myItem;

@synthesize swordItem = _swordItem;


@synthesize head, body, leg1, leg2, front_arm, back_arm, item;

@synthesize intention;

@synthesize bob, walkCounter, strikeMove, strikeCounter;

@synthesize strikeDirection;

@synthesize dim;

@synthesize arm_id, head_id, leg_id, tunic_id;

//@synthesize SpriteMatrix;

@synthesize itemPhase, armPhase, arcPhase;

@synthesize playerWidth;

@synthesize damageStart, recoveryStart;

@synthesize invincible_time_so_far, invTime;

+(id) player1
{
    return [[self alloc] init];
}


-(id) init
{
   
    intention = ccp(0,0);
    size.height = 56; //60; // 62 doesn't work
    size.width = 40; //32; // 20
    // encapsulate in initGlobals?
    
    // avatar stuff?
    arm_id = 0;
    head_id = 0;
    leg_id = 0;
    tunic_id = 1;
    
    scaleFactor = 1;
    
    dim = 64*scaleFactor;
    
    // movement variables - should stay constant on pause
    walkCounter = 0;
    bob = 0;
    
    // damage
    showingDamage = NO;
    counter = 0;
    attackDamage = 2;
    damageTime = 0.0125;
    
    // speeds
    origSpeed = 2;
    stunSpeed = 6;
    moveSpeed = origSpeed;
    
    invincible = NO;
    invTime = 1;
    
    [self setSpriteParts];
    

    // debugging
     [frameCache addSpriteFramesWithFile:@"utility.plist"];
    
    soundManager = [SoundManager sharedSoundManager];
    
    frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
    
    [self addSignals];
    // sprite data holders.
     _swordItem = [SwordItem swordItem1];
    
    _myItem = _swordItem;
    
    armPhase = [Phase phase1];
    itemPhase = [Phase phase1];
    arcPhase = [Phase phase1];
    
    // add new frameCaches here
    [frameCache addSpriteFramesWithFile:@"maze-art.plist"];
    
    NSString* sprite = @"sword.plist";
    [frameCache addSpriteFramesWithFile:sprite];
    
    NSArray *spriteFiles =
    [NSArray arrayWithObjects:@"sword.plist",@"legs.plist",@"arms.plist",@"body.plist",@"head.plist", nil];

    for (NSUInteger i = 0; i < 5; i++)
    {
        NSString* myFile = [spriteFiles objectAtIndex:i];
       
        [frameCache addSpriteFramesWithFile:myFile];
    }
    
    // add sprites below; eliminate spriteFrame; start with head.
    // start with all sprites in one node:
    // head, body, arm1, arm2, leg1, leg2 (not always visible)
    if ((self = [super init]))
    {
         self.orientation = RIGHT;
        
        [self initSounds];
        [self defineParts];
        [self setParts];
       
        self.attacking = NO;
        self.attackFinish = NO;
        
       [self schedule:@selector(animatePlayer:)interval:0.1f];
    }
    return self;
}
// maintains the walk cycle by telling the player to decide on a frame switch every half-second
-(void) animatePlayer: (CCTime) dt
{
    [self walkStance];
       
}
/*
 * Walking
 */
-(void) walkStance
{
    //  if moving vertically, walk cycle depends on player's orientation.
    if (self.velocity.y !=0 || self.velocity.x != 0)
    {
        moving = YES;
        walkCounter++;
        [self walk];
    }
    
    // reverting to standing position
    else if (moving == YES && self.velocity.y == 0 && self.velocity.x == 0)
    {
        moving = NO;

        if (orientation > 1) //  right or left
        {
            walkCounter = 0;
            
            NSString  *legFile = [NSString stringWithFormat:@"legs0_stand_right_0.png"];
            
            CCSpriteFrame* main_leg = [frameCache spriteFrameByName:legFile];
            
            [leg1 setSpriteFrame: main_leg];
        }
        
    }
}
/*
 * Initializing parts
 */
-(void) defineParts
{
    NSString* pos = @"right";
    
    NSString* it = [NSString stringWithFormat:@"diag_%@.png", pos];
    NSString* he = [NSString stringWithFormat:@"head%i_%@.png", head_id, pos];
    NSString* fa = [NSString stringWithFormat:@"arms%i_walk_%@_0.png", arm_id, pos];
    NSString* ba = [NSString stringWithFormat:@"arms%i_walk_%@_4.png", arm_id, pos];
    NSString* tu = [NSString stringWithFormat:@"body%i_walk_%@.png", tunic_id, pos];
    NSString* le = [NSString stringWithFormat:@"legs%i_walk_%@_0.png", leg_id, pos];
    NSString* ar = [NSString stringWithFormat:@"full-arc.png"];
    
    // store filenames in variables?
    item1 = [CCSprite spriteWithImageNamed:it];
    head = [CCSprite spriteWithImageNamed:he];
    body = [CCSprite spriteWithImageNamed:tu];
    front_arm = [CCSprite spriteWithImageNamed:fa];
    back_arm = [CCSprite spriteWithImageNamed:ba];
    leg1 = [CCSprite spriteWithImageNamed:le];
    
    // for striking
    leg2 = [CCSprite spriteWithImageNamed:le];
    arc = [CCSprite spriteWithImageNamed:ar];
    
    leg2.visible = NO;
    arc.visible = NO;
    item1.visible = NO;

    front_arm.opacity = 1;
    
    parts = [NSMutableArray arrayWithObjects:
             back_arm,
             leg1,
           
             body,
             front_arm,
          
             head,
             leg2,
        
             item1,
             arc,
             nil];

}

-(void)throwMotion
{
    NSString* myFrame;
    CCSprite* mySprite = (orientation == RIGHT) ? front_arm : back_arm;
    int LeftRightX = 10;
    int leftRightY = 6;
    int frontBackX = 16;
    switch(orientation)
    {
        case FRONT:
        myFrame = [NSString stringWithFormat:@"arms0_strike_front_2.png"];
        mySprite.position = CGPointMake(-frontBackX,-2);
        mySprite.flipX = NO;
        mySprite.zOrder = 20;
        break;
            
        case BACK:
        myFrame = [NSString stringWithFormat:@"arms0_strike_front_2.png"];
        mySprite.flipY = YES;
        mySprite.position = CGPointMake(frontBackX,24);
        break;
        case RIGHT:
        // maybe make the body lean in more
        myFrame = [NSString stringWithFormat:@"arms0_strike_right_2.png"];
        mySprite.position = CGPointMake(LeftRightX,leftRightY);
        break;
            
        case LEFT:
        myFrame = [NSString stringWithFormat:@"arms0_strike_right_2.png"];
        mySprite.position = CGPointMake(-LeftRightX,leftRightY);
        break;
    }
    CCSpriteFrame* long_arm = [frameCache spriteFrameByName:myFrame];
    
    [mySprite setSpriteFrame: long_arm];
    
    [self holdPosReturn:0.25];
}
/*
 *  Called during walk cycle.
 */
-(void) walkFrames: (NSString*) frameDir andFrames: (int[3])myFrames
{
    NSString  *le, *a1, *a2, *he, *tu;
    
    NSString* legDir = (self.orientation == BACK) ? @"front" : frameDir;
    
    NSString* headDir = (self.orientation == LEFT) ? @"left" : frameDir;
    
    a2 = [NSString stringWithFormat:@"arms%i_walk_%@_%i.png", arm_id, frameDir, myFrames[2]];
    le = [NSString stringWithFormat:@"legs%i_walk_%@_%i.png", leg_id, legDir, myFrames[0]];
    tu = [NSString stringWithFormat:@"body%i_walk_%@.png", tunic_id, frameDir];
    a1 = [NSString stringWithFormat:@"arms%i_walk_%@_%i.png", arm_id, frameDir, myFrames[1]];
    he = [NSString stringWithFormat:@"head%i_%@.png",head_id, headDir];
    
    NSArray* files = [NSArray arrayWithObjects: a2, le, tu, a1, he, nil];
    
    [self setSprites:files];
}

/* use for static frames*/
-(void) damagePos // points, farmes, rotates, & flips for 7 sprites at 4 PARTS
{
    CGPoint pos[4][7] =
    {
        
            // front
            {
              ccp(0,0)
            },
            // back
            {
                ccp(0,0)
            },
        
            {
            // right
               ccp(0,0)
            },
            // left
            {
              ccp(0,0),
            
            },
    };


    NSArray* right = [NSArray arrayWithObjects:@"one",@"two",@"three", nil];
    NSArray* left = [NSArray arrayWithObjects:@"one",@"two",@"three", nil];
    NSArray* back = [NSArray arrayWithObjects:@"one",@"two",@"three", nil];
    NSArray* front = [NSArray arrayWithObjects:@"one",@"two",@"three", nil];
    
    NSArray* frameSets = [NSArray arrayWithObjects:front, back, right, left, nil];
    NSArray* myFrameSet = [frameSets objectAtIndex:orientation];
    
    // needed?
    int rotates[4][7] =
    {
        {0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0},
        {0,0,0,0,0,0,0},
    };
    
    // stores the indices of the parts that actually need flips. we may want to use strings rather than ints for this one - could be easier.
    NSArray* flipX = [NSArray arrayWithObjects:
                    
                    
                    [NSSet setWithObjects: 0, nil], // front
                    [NSSet setWithObjects: 0, 1, nil],  // back
                    [NSSet setWithObjects: 0, 1, 3, nil], // right
                    [NSSet setWithObjects:  nil],nil]; // left
    
     NSArray* flipY = [NSArray arrayWithObjects:
                 
                    [NSSet setWithObjects: @(0), nil], nil]; // front
                     [NSSet setWithObjects: @(0), @(1), nil], // back
                    
                    [NSSet setWithObjects: @(0), @(1), @(3), // right
                     [NSSet setWithObjects:  nil], nil]; // left
    
    NSSet* setX = [flipX objectAtIndex:orientation];
    
    NSSet* setY = [flipY objectAtIndex:orientation];
    
    
    [self staticPose: pos[orientation] andFrames: myFrameSet fX:setX fY:setY rot:rotates[orientation]];
    
   
}

// I have not tried using this yet - it's for static poses like pushing and taking damage.
-(void) staticPose: (CGPoint[7])points andFrames: (NSArray*) frames fX:(NSSet*)flipX fY:(NSSet*) flipY rot:(int[7])rotates
{
  
    for (NSUInteger i = 0; i < 7; i++)
    {
       Phase* myPhase;
        myPhase.pos = points[i];
        myPhase.rotate = rotates[i];
        if ([flipX containsObject:@(i)])  myPhase.flipX = YES;
        if ([flipY containsObject:@(i)]) myPhase.flipY = YES;
       CCSprite* mySprite = [parts objectAtIndex:i];
       [self spriteProps: myPhase andSprite: mySprite];
    }
    
}

// creates an array of points and then passes it into the firstPos position.
// **revise for standing mode, though.
-(void) setParts
{
    NSMutableArray* points;
    points = [self spritePoints:0];
    [self firstPos: points];
    
}

// add a given sprite, scale it, and set its stacking.


// establish starting position and related stacking.
-(void) firstPos: (NSMutableArray*) points
{
           //   a,l,b,a,h,l,i
    int zi[] = {0,1,3,5,4,2,6,7};
    
    for (NSUInteger i=0; i < [parts count]; i++)
    {
         CCSprite* mySprite = [parts objectAtIndex:i];
        [self addSprite: mySprite z:zi[i]];
        
        // sprites that are not the atom
        if (i < 6)
        {
            // get the position from the points
            NSValue* locValue = [points objectAtIndex:i];
            mySprite.position  = locValue.CGPointValue;
        }
    }
    front_arm.opacity = 1;
    
    arc.opacity = 0.6;

    [self switchPos:0];
}

// switch from striking to walking and vice-versa
-(void) switchPos: (int) st
{
   
    NSMutableArray* myPoints = [self spritePoints:st];
    
    for (NSUInteger i=0; i < 6; i++)
    {
        CCSprite* mySprite = [parts objectAtIndex:i];
        NSValue* locValue = [myPoints objectAtIndex:i];
        mySprite.position  = locValue.CGPointValue;
        
    }
}
/*
 * Initializes Sprite positions for the four different orientations.
 */
-(int) setSpriteParts
{
    
    CGPoint orig = ccp(2,4);
    CGPoint front_walk_arm = ccp(0,0);
    
    // BOB
    CGPoint side_arm = CGPointMake(orig.x-6,orig.y-10);

    
    // front arm y
    front_walk_arm.y = side_arm.y+4;
    
    
    // side arm horiz: walk, strike
    int side_arm_x[2][2] = {
        {side_arm.x,side_arm.x + 6},
        {side_arm.x-2,side_arm.x+14}};
    
    // front arm horiz: walk, strike
    int front_arm_x[STANCES][DIRECTIONS]={
        {orig.x+24,
         orig.x-30,
         orig.x+24,
         orig.x-30},
        
        {orig.x-22,
         orig.x+12,
         orig.x+16,
         orig.x-18}};
    
    int legHFS[] = {orig.x+18,orig.x-2};
    
    // BOB
    int front_strike_armY[3] =  {orig.x+6, orig.x+2, orig.x};
    
    
    
    int side_strike_armY[3] = {side_arm.y,side_arm.y+6,side_arm.y+10};
    
    
    // walk, strike
    int legY = orig.y-18;
    
    int legV[] = {legY,legY+4};
    
    // left, right
    int legH[2][2] = {
        {orig.x,orig.x-4},
        {orig.x+10,orig.x-14}};
    
    int headH[2][2] = {
        {orig.x,orig.x-4},
        {orig.x+2,orig.x-6}};
    
 
    
    CGPoint torso = ccp(orig.x-2,orig.y-4);
    
    int body_x2 = orig.x-10;
    // head vert PARTS
    CGPoint pts[2] = {ccp(0,0),ccp(0,0)};
    
    CGPoint myX;
    myX.y = pts[0].y;
        
    // base vert position of head;
    int headC = 18; // head constant
    
    //BOB
    int headS = orig.y+headC; // head sum
    
    int hdV[] = {headS+2,headS+4,headS};
    
    SpriteMatrix = malloc(sizeof(CoordMatrix));
    
    CGPoint points[STANCES][DIRECTIONS][PARTS] =
    {
        { /*
           * Walking
           */
           
            // front
            {
                // arm
                ccp(front_arm_x[0][3],front_walk_arm.y),
                // leg
                ccp(torso.x, legV[0]),
                // body
                torso,
                // arm - front_arm_x is only difference from front
                ccp(front_arm_x[0][2],front_walk_arm.y),
                // head
                ccp(torso.x,hdV[2]),
                // leg or item?
                ccp(legHFS[0],legV[0])
            },
            // back
            {
                // arm
                ccp(front_arm_x[0][0],front_walk_arm.y),
                // leg
                ccp(torso.x,legV[0]),
                // body
                torso,
                // arm
                ccp(front_arm_x[0][1],front_walk_arm.y),
                // head
                ccp(torso.x,hdV[1]),
                // leg or item?
                ccp(legHFS[0],legV[0])

            },
          
            
            // right
            {
                // arm
                ccp(side_arm_x[0][1],side_arm.y),
                // leg
                ccp(legH[0][0],legV[0]),
                // body
                torso,
                // arm
                side_arm,
                // head
                ccp(headH[0][0],hdV[0]),
                // leg or item?
                ccp(legHFS[1],legV[0])
            },
            // left
            
            
            {
                // arm
                ccp(side_arm_x[0][0],side_arm.y),
                // leg
                ccp(legH[0][1],legV[0]),
                // body
                torso,
                // arm
                ccp(side_arm_x[0][1],side_arm.y),
                // head
                ccp(headH[0][1],hdV[0]),
                // leg or item?
                ccp(legHFS[1],legV[0])
            }
        },
        { /*
           * Striking
           */
           
         
            // front
            {
                // arm
                ccp(front_arm_x[1][3],front_strike_armY[1]),
                // leg
                ccp(body_x2,legV[1]),
                // body
                torso,
                // arm
                ccp(front_arm_x[1][1],side_strike_armY[1]),
                // head
                ccp(torso.x,hdV[2]),
                // leg or item?
                ccp(legHFS[0],legV[1])
            },
            // back
            {
                // arm
                ccp(1,1),//ccp(front_arm_x[1][0]+20,front_strike_armY[0]),
                // leg
                ccp(body_x2,legV[1]),
                // body
                torso,
                // arm
                ccp(front_arm_x[1][1],side_strike_armY[2]),
                // head
                ccp(torso.x,hdV[1]),
                // leg or item?
                ccp(legHFS[0],legV[1])
            },
       
           
            // right  {side_strike_armY[1],  legV[0],  bodyV,   side_strike_armY[0], hdV[0],    legV[0]},
            {
                // arm
                ccp(side_arm_x[1][1],side_strike_armY[1]),
                // leg
                ccp(legH[1][0],legV[0]),
                // body
                torso,
                // arm
                ccp(side_arm_x[1][0],side_strike_armY[0]),
                // head
                ccp(headH[1][0],hdV[0]),
                // leg or item?
                ccp(legHFS[1],legV[0])
            },
            
            // left
            {
                // arm
                ccp(side_arm_x[1][0],side_strike_armY[1]),
                // leg
                ccp(legH[1][1],legV[0]),
                // body - bodyV is always the same
                torso,
                // arm
                ccp(side_arm_x[1][1],side_strike_armY[2]),
                // head
                ccp(torso.x-4,hdV[0]),
                // leg or item?
                ccp(legHFS[1],legV[0])
            },
        }
    };
  
    // transfer into 3D Matrix
    for (int i = 0; i < STANCES; ++i)
      for (int j = 0; j < DIRECTIONS; j++)
        for (int k = 0; k < PARTS; k++)
            SpriteMatrix->points[i][j][k] = points[i][j][k];

    return 0;
}
// spritePoints is called by switchPos and setParts
-(NSMutableArray*) spritePoints: (int) st
{
   
    // why set these arrays EVERY TIME if we are just using one of them?
    // Could we make htem global?
    int dir = self.orientation;
    
    CGPoint myPoints[6];
    // dir determines horiz. positioning. bob determines vert positioning.
    for (NSInteger i = 0; i < PARTS; i++)
    {
        int mod = (i == 1 || i == 5) ? 0 : bob;
       
        myPoints[i] = ccp(SpriteMatrix->points[st][dir][i].x*scaleFactor,
                          (SpriteMatrix->points[st][dir][i].y-mod)*scaleFactor);
    }
  
    NSMutableArray* points = [self convertArray:myPoints];
    return points;
}

-(NSMutableArray*) convertArray: (CGPoint [7]) myPoints
{
    NSMutableArray* points = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 6; i++)
        [points addObject:[NSValue valueWithCGPoint:myPoints[i]]];
    
    return points;
}

-(void) turn: (BOOL) dir // flip - determine whether to flip sprites
{
    for (NSUInteger i=0; i < [parts count]-1; i++)
    {
        CCSprite* mySprite = [parts objectAtIndex:i];
        mySprite.flipX = dir;
    }
    
    // if front and back, flip the back arm; otherwise, don't do it
    back_arm.flipX = (self.orientation != RIGHT) ? YES : NO;
}
-(void) strike
{
    if (strikeCounter == 0 || strikeCounter >= 4 || strikeDirection == -1)
    {
        arc.visible = NO;
        
        // we'll need to use this for pause
        [self stopAllActions];
        
        [soundManager playSound:SWORD_SLASH];
  
        // changed
        bob = (orientation > 1) ? 2 : 0;
    
        [self switchPos:1];
    
        [self strikeFrames];
    
        self.attacking = YES;
    
        leg2.visible = YES;
    }
}

-(void) walk
{
    if (item1.visible == YES) item1.visible = NO;
    if (leg2.visible == YES) leg2.visible = NO;
    
    BOOL flip = (self.orientation == LEFT) ? YES : NO;
    [self turn:flip];
    
    [self switchPos: 0];
    
    [self walkCycle];
    
    }
-(void) walkCycle // CHANGED
{
    int legframe, armframe1, armframe2;
    
    legframe = walkCounter%8;
    
    // FRONT & BACK
    if (self.orientation < 2 && legframe > 4)
    {
        int tempframe = legframe;
        legframe = 8 - tempframe;
    }
     
    // to make him bob up and down
    if (self.orientation > 1 && (legframe < 2 || legframe == 4 || legframe == 5)) bob = 2; else bob = 0;
    
    if (legframe < 5)  armframe1 = legframe; else armframe1 = 8 - legframe;
        
    armframe2 = 4 - armframe1;

    NSString* frameDir = [self getDir];
    
    int myFrames[] = {legframe, armframe1, armframe2};
    
    [self walkFrames: frameDir andFrames:myFrames];

}
-(NSString*) getDir // CHANGED
{
    NSArray* dirs =[NSArray arrayWithObjects:@"front",@"back",@"right", nil];
    
    int dir = (self.orientation == LEFT ) ? RIGHT : self.orientation;
    
    NSString *frameDir =[dirs objectAtIndex:dir];
    
    return frameDir;
}

/*
 * Strike Functions
 */

-(void) strikeFrames
{
   
    // include variable for length and logic for unidirectional weapon.
    
    // change?
    strikeDirection = (strikeCounter >=4 && strikeDirection == 1) ? -1 : 1;
    
    // declare direction for frames
    NSString* frameDir = [self getDir];
    
    // initialize sprites
    NSString *legFile1, *legFile2, *armFile1, *headFile, *armFile2, *bodyFile;
    
    // establish direction of head
    NSString* headDir = (self.orientation == LEFT) ? @"left" : frameDir;
    
    // pull in sprite file for head
    headFile = [NSString stringWithFormat:@"head%i_%@.png",head_id, headDir];
    
    // CHANGE FILE DATA BASED ON ORIENTATION CODE SWITCH
    armPhase = [[_myItem.armClip objectAtIndex:orientation] objectAtIndex:0];
    
    itemPhase = [[_myItem.itemClip objectAtIndex:orientation] objectAtIndex:0];
    
   
    
    NSString* activeFrame = [NSString stringWithFormat:@"%@",armPhase.frame];
   
    // use sword item.
    
    NSString* inactiveFrame = (orientation < 2)
    ? [NSString stringWithFormat:@"arms%i_strike_%@_inactive.png",arm_id, frameDir]
    : [NSString stringWithFormat:@"arms%i_walk_right_0.png", arm_id];
    
   // int armType = orientation%2;
    
    // OLD: 0* (right) 1 (left) 2* (back) 3(front)
    
    // NEW: 0 (front) 1* (back) 2* (right) 3 (left)
    switch (orientation)
    {
        case RIGHT:
        case BACK:
            armFile1 =  inactiveFrame;
            armFile2 =  activeFrame;
            break;
        case LEFT:
        case FRONT:
            armFile1 =  activeFrame;
            armFile2 = inactiveFrame;
            break;
    }
    
   
    
    legFile1 = (orientation < 2) ? [NSString stringWithFormat:@"legs%i_attack_front_left.png", leg_id] :
                 [NSString stringWithFormat:@"legs%i_attack_right_front.png", leg_id];
    
    legFile2 = (orientation < 2) ? [NSString stringWithFormat:@"legs%i_attack_front_right.png", leg_id] :
    
    [NSString stringWithFormat:@"legs%i_attack_right_back.png", leg_id];
    
    bodyFile = [NSString stringWithFormat:@"body%i_strike_%@.png", tunic_id, frameDir];
    
    NSArray* files = [NSArray arrayWithObjects: armFile2, legFile1, bodyFile, armFile1, headFile, legFile2, nil];
  
    [self setSprites:files];
    
    if (orientation != LEFT) back_arm.flipX = NO;
    
    strikeCounter = 0;
    
    [self resetStacking];
    
    [self strikeKeyFrame];
    
    strikeMove = 0; 
    
    [self schedule:@selector(animateStrike:)interval: _myItem.timeInterval];
    
}

// finishPos -> holdPosReturn -> returnStance
-(void) finishPos
{
    attacking = NO;
    attackFinish = YES;
    [self unschedule:@selector(animateStrike:)];
    strikeCounter = 4;
    [self holdPosReturn:0.5f];
    
}
-(void) holdPosReturn: (float) delayTime
{
    id delay = [CCActionDelay actionWithDuration: delayTime];
    // return to non-striking stance
    id callBack = [CCActionCallFunc actionWithTarget: self selector: @selector(returnStance)];
    id sequence = [CCActionSequence actions: delay, callBack, nil];
    [self runAction: sequence];
}
-(int) animateStrike: (CCTime) dt
{
    item1.visible = YES;
    
    if (strikeCounter == 5) // change to max variable
    {
      
        [self finishPos];
        return 0;
    }
    
    [self strikeKeyFrame];
    
     strikeCounter ++; // might move this.
    
    return 0;
    
}

/* 
 *  This depends HEAVILY on the item classes - specifically (for now) SwordItem.m. 
 *  This determines the arc for the sword.
 *  This means we don't need as much data here so we can eliminate some coordinates maybe...
 */
// select what frame to use based on 2D array.

-(void) setPhases
{
    // set keyFrame based on strikeCounter
    
    int keyFrame = (strikeDirection == 1) ? strikeCounter : 4 - strikeCounter;
    
    // using whatever item classe we have - the data is external to this file. 
    itemPhase = [[_myItem.itemClip objectAtIndex:orientation] objectAtIndex:keyFrame];
    
    armPhase = [[_myItem.armClip objectAtIndex:orientation] objectAtIndex:keyFrame];
    
    // create arc
     if  (_myItem.arc == YES && strikeCounter > 0 && strikeCounter < 5)
     {
         int frame;
         NSMutableArray* clip = [[NSMutableArray alloc] init];
         switch (strikeDirection)
         {
            
             case 1:
                 clip = _myItem.arc_fwd_clip;
                 frame = strikeCounter - 1;
                                break;
                 
             case -1:
                 clip = _myItem.arc_back_clip;
                 frame = strikeCounter;
                
                 break;
         }
         arcPhase = [[clip objectAtIndex:orientation] objectAtIndex:frame];
      
     }
}
-(CCSprite*) chooseArm
{
    CCSprite* myArm = (orientation%3 == 0) ? front_arm : back_arm;
 
    // RIGHT (back) LEFT(front) BACK(back) FRONT(front)
    // front, back, back, front
  //  CCSprite* arms[2] = {front_arm, back_arm, back_arm, front_arm};
    
   // CCSprite* myArm = arms[orientation];
    
    return myArm;
}

-(void) hideArc: (CCTime) dt
{
  //  NSLog(@"dt:%f ", dt);
     arc.visible = NO;
    
    [self unschedule:@selector(hideArc:)];
}
-(void) strikeKeyFrame
{
    // add conditional for unidirectional weapons, e.g., wand
    
    // add in a variable for the key key frame length / # key frames.
    
    [self resetStacking];
    
       if ((strikeDirection == 1 && strikeCounter ==2) || (strikeDirection == -1 && strikeCounter == 1))
    arc.visible = YES;

    // makes the arc disappear shortly before the weapon motion has completed.
        else if ((strikeCounter == 4 && strikeDirection == 1) || (strikeDirection == -1 && strikeCounter >= 3))
        {
      
            float delay = 0.125f;
            
            [self scheduleOnce:@selector(hideArc:)delay:delay];
          
        }
    
    [self setPhases];
    
    // NOTE: spriteProps is defined in Movable.h.
    
    // select the striking arm based on orientation
    CCSprite* myArm = [self chooseArm];
    
    // mobilize arm, item, and arc.
    [self spriteProps: armPhase andSprite: myArm];
    
    // mobilize item
    [self spriteProps: itemPhase andSprite:item1];
    
    // *** make conditional on whether this is an arc item.
    [self spriteProps: arcPhase andSprite:arc];
   
}

// resets stacking of back arm and item. we will need an item 2 as well.

-(void) resetStacking
{
    back_arm.zOrder = 0;
    item1.zOrder = 6;
}
// resets the flips of the back arm.
-(void) resetFlips
{
   back_arm.flipX = NO;
   back_arm.flipY = NO;
}
-(void) returnStance
{
    strikeCounter = 0;
    attackFinish = NO;
    walkCounter = 1;
    
    [self resetStacking];
    [self resetFlips];
    
    [self walk];
    //*** change this so it goes back to standing position.
}




-(void) takeStep: (NSString*)fileName
{
    CCSpriteFrame* step = [frameCache spriteFrameByName:fileName];
    [self setSpriteFrame: step];
}
-(void) initSounds
{
    damageSound = PLAYER_DAMAGE;
}

-(void) recoveryState
{
    [self normalColor];
    [self unschedule:@selector(showDamage:)];
    showingDamage = NO;
    counter = 0;
    self.velocity = CGPointZero;
    
    self.invincible = YES;
    
    [self setOpacity:0.5];
    [self scheduleOnce:@selector(normalState:)delay:invTime];
    
    recoveryStart = [NSDate timeIntervalSinceReferenceDate];
    
}
-(void) normalState:(CCTime)dt
{
    NSLog(@"NORMAL");
    [self setOpacity:1];
    self.invincible = NO;
}
-(void) onPause
{
    NSTimeInterval pauseTime = [NSDate timeIntervalSinceReferenceDate];
    if (invincible == YES)
        invincible_time_so_far = pauseTime - recoveryStart;
    
    [self unscheduleAllSelectors];
    
    // we could also factor in recovery after the strike, but it may be needless work. 
    
}
-(void) onResume
{
    [self schedule:@selector(animatePlayer:)interval:0.1f];
    if (attacking == YES)
         [self schedule:@selector(animateStrike:)interval: _myItem.timeInterval];
    
    if (invincible == YES)
    {
        float t = invTime - invincible_time_so_far;
        NSLog(@"time remaining: %f", t);
        [self scheduleOnce:@selector(normalState:)delay:t];
    }
    else if (showingDamage == YES)
        [self schedule:@selector(showDamage:)interval:damageTime];
}

@end
