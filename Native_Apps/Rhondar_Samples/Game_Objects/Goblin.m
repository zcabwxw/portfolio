//
//  goblin.m
//  Rhondar
//
//  Created by nkatz on 12/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.

#import "Goblin.h"
#import "GameLayer.h"
#import "UserInterfaceLayer.h"

#import "AudioToolbox/AudioToolbox.h"

#import "AVFoundation/AVFoundation.h"




/*Then, in the not-so-far-off future: 
 
 Map
 Item Menu
 Overworld
 Teleport points
 
 */


@interface Goblin (PrivateMethods)

-(id) initWithGoblinImage;

@end

@implementation Goblin

@synthesize strikeTimeSoFar;
@synthesize strikeDur;
@synthesize attackPoint;
@synthesize refractory_period;


@synthesize strikeStart, strikeStop;

@synthesize SpriteMatrix;



@synthesize walkCounter, bob, stance;

@synthesize gLayer = _glayer;

@synthesize chase;

@synthesize last_tried, stored_direction;

@synthesize striking, recentSwitch;

@synthesize stunVel;

@synthesize weaponDamage, baseDamage;
//@synthesize arm_rotateGoal, staff_rotateGoal arm_rotateIncr, staff_rotateIncr;

+(id) goblin
{
    return [[self alloc] initGoblin];
}

-(void) addSprite: (CCSprite*) mySprite z: (int) zi
{
    // next up: check attackPoints during a scheduled action if striking = 1
    [self addChild:mySprite z:zi];
    
    attackPoint = ccp(0,0);
    // sprites are 128 by 128.
    mySprite.scaleX = 2*scaleFactor;
    mySprite.scaleY = 2*scaleFactor;
    [mySprite.texture setAntialiased:NO];
    mySprite.opacity = 1;
}
-(id) initGoblin
{
    strikeDur = 0.25;
    refractory_period = 0.75; // random?
    damageTime = 0.0215;
    killed = NO;
    recentSwitch = 0;
    striking = 0;
    stance = 0;
    chase = 0;
    stored_direction = 0;
    walkCounter = bob = 0;
    // damage FX
    showingDamage = NO;
    
    // goblin orientation
    orientation = 2;
    
    // goblin speed
    moveSpeed = origSpeed = 1;
    
    // speed at which goblin moves when stunned
    stunSpeed = 10;
    
    // how much damage the goblin inflicts; could change based on weapon.
    baseDamage = attackDamage = 1;
    
    weaponDamage = 4;
    
    // initial health of goblin
    maxHealth = health = 20;
    
    // how much to scale the goblin by. For now, 0.5 is the normal scale factor.
    scaleFactor = 1;
    
    // stores goblin frames
    frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
    
    
     soundManager = [SoundManager sharedSoundManager];
    
    // change this to a specific goblin file.
    [frameCache addSpriteFramesWithFile:@"goblin.plist"];
    [frameCache addSpriteFramesWithFile:@"death-effect-1.plist"];
  
    if ((self = [super init]))
    {
        arrayManager = [ArrayManager sharedArrayManager];
        
        // change width once the other sprite is added. 
        range = 60; // change to range
        
        // set velocity (?)
        self.velocity = ccp(moveSpeed,0);
        
        // set goblin movement
        [self startMoving];
        
        // might change for later
        [self initSounds];
        
        // set up position matrix.
        [self setSpriteParts];
        
        // defines the parts of the goblin
        [self defineParts];
        
    
        [self detectPlayer];
        
        // MODIFY
        // add the sprite to the "stage"
      //  [self addSprite:head z:10];
    }
    return self;
}
-(void) detectPlayer
{
    GameLayer* gl = (GameLayer*)[self parent];
    
    myPlayer = (Movable*) gl.player;
}
-(void) stopMoving
{
    [self unscheduleAllSelectors];
    
   // [self unschedule];
    
    // get time stamp of strike if necessary...
    
    //
}
-(int) frameIndex: (CCSpriteFrame*) targetFrame
{
    int frameCount = 8;
    
    for (int i = 0; i < frameCount; i++)
    {
        int frameNumber = i+1;
        
        NSString* file = [NSString stringWithFormat:@"death-effect-1_0%i.png", frameNumber];
        
        CCSpriteFrame* currentFrame = [frameCache spriteFrameByName:file];
        
        if (targetFrame == currentFrame) return i;
    }
    return -1;
}
-(void) onResume
{
    if (killed == NO)
    {
        if (front_bar.visible == YES)
            [self scheduleOnce:@selector(hideBars:)delay:0.25];
        [self startMoving];
        
        if (striking == 1)
        {
            float remainingTime = strikeDur - strikeTimeSoFar;
            [self scheduleOnce:@selector(stopStrike:)delay:remainingTime];
        }
        else if (striking == 2)
        {
            float remainingTime = refractory_period - strikeTimeSoFar;
            [self scheduleOnce:@selector(resumeStrikeWatch:)delay:remainingTime];
        }
    }
    else
    {
        CCSpriteFrame* frame = self.spriteFrame;
        int index = [self frameIndex:frame];
        if (index >= 0)[self deathAnimation:index];
    
    }
        
}
-(void) startMoving
{
    [self schedule:@selector(goblin_update:) interval:0.035];
    
    [self schedule:@selector(goblin_anim:) interval:0.08];
}
/*
-(int) searchParts: (CCSprite*) mySprite
{
    for (int i = 0; i < [parts count]; ++i)
        if ([parts objectAtIndex:i] == mySprite) return i;
    return -1;
}*/

-(void) rotateSprite: (CCSprite*) mySprite withDur: (int) dur andAngle:(int) myAngle
{
    CCActionRotateBy *rotateAction = [CCActionRotateBy actionWithDuration:dur angle:180];
    
    [mySprite runAction:rotateAction];
    

    
}
// THEN USE HELPER FUNCTION
// Figure out rotate around point for hand.
-(void) setSpriteParts
{

    CGPoint headPos = ccp(0,14);
    CGPoint armourPos = ccp(0,-2);
    CGPoint armPos = ccp(24,-2);
    CGPoint handPos = ccp(22,armPos.y-10);
    CGPoint back_handPos = ccp(28, armPos.y-2);
    CGPoint legPos = ccp(0,-21);
    CGPoint right_legPos = ccp(-2,-24);
    CGPoint points[STANCES][DIRECTIONS][GPARTS] =
    {
        { // walking
            { // front
                headPos, // head
                armourPos, // armour
                ccp(-(armPos.x+2),armPos.y), // arm1
                armPos, // arm2
                legPos, //legs
                ccp(-handPos.x,handPos.y), // hand
                handPos, // hand
                ccp(-24,0), // staff
            },
            { // back
                headPos, // head
                armourPos, // armour
                ccp(-(armPos.x),armPos.y), // arm1
                armPos, // arm2
                legPos, //legs
                ccp(-(handPos.x+2),handPos.y-2), // hand
                ccp(handPos.x+4,handPos.y-2), // hand
                ccp(26,0), // staff -- I actually think this is the ONLY thing that changes here....
            },
            { // right
                ccp(4,headPos.y), // head
                ccp(0,-5), // armour
                ccp(armPos.x-34,armPos.y-3), // arm1
                ccp(armPos.x-34,armPos.y-3), // arm2
                right_legPos, // leg
                ccp(-4,handPos.y-2), // hand
                ccp(4,right_legPos.y), // leg (in this case)
                ccp(-4,0), // staff
            },
            { // left
                ccp(-4,headPos.y), // head
                ccp(0,-5), // armour
                ccp(armPos.x-18,armPos.y-3), // arm1
                ccp(armPos.x-24,armPos.y-3), // arm2
                ccp(2,right_legPos.y), // leg
                ccp(2,handPos.y-2), // hand
                ccp(-4,right_legPos.y), // leg (in this case)
                ccp(-4,0), // staff
            }
        },
        /*
         staff.position = ccp(14,0);
         arm.position = ccp(20,6);
         hand.position = ccp(58,16);
         */
        { // striking
            { // front
                headPos, // head
                armourPos, // armour
                ccp(-armPos.x,armPos.y), // arm1
                armPos, // arm2
                legPos, //legs
                ccp(-handPos.x-4,handPos.y-4), // hand
                handPos, // hand
                ccp(-26,-30), // staff
            },
            { // back
                headPos, // head
                armourPos, // armour
                ccp(-(armPos.x),armPos.y), // arm1
                ccp(armPos.x,armPos.y+12), // arm2
                legPos, //legs
                ccp(-(handPos.x),handPos.y), // hand
                ccp(back_handPos.x-2,back_handPos.y+28), // hand
                ccp(26,36), // staff -- I actually think this is the ONLY thing that changes here....
            },
            { // right
                ccp(4,headPos.y), // head
                ccp(0,-4), // armour
                ccp(armPos.x-30,armPos.y+2), // arm1
                ccp(armPos.x-16,armPos.y-2), // arm2
                right_legPos, // leg
                ccp(13,handPos.y+12), // hand
                ccp(4,right_legPos.y), // leg (in this case)
                ccp(28,+2), // staff
            },
            { // left
                ccp(-4,headPos.y), // head
                ccp(0,-3), // armour
                ccp(armPos.x-18,armPos.y-3), // arm1
                ccp(armPos.x-44,armPos.y), // arm2
                ccp(2,right_legPos.y), // leg
                ccp(4,handPos.y-2), // hand
                ccp(-4,right_legPos.y), // leg (in this case)
                ccp(-34,0), // staff
            }
        }
        
    };
    
    int indices[STANCES][DIRECTIONS][GPARTS] =
    {
        {
          // h,b,a,a,l,n,w,s
            {8,4,1,1,2,7,6,5}, // front
            {2,6,3,3,5,2,2,1}, // back
            {4,5,6,1,2,8,1,7}, // right
            {5,6,7,3,4,8,2,1}, // left
        },
        {
          // h,b,a,a,l,n,w,s
            {8,4,1,1,2,7,6,5}, // front
            {2,6,3,3,5,1,5,4}, // back
            {4,5,6,1,2,8,1,7}, // right
            {4,5,6,2,3,8,1,1}, // left
        }
      // w = wildcard; a = arm; b = body armour; h = head; s = staff; l = leg; n = hand
 
    };
    
    // allocate memory for sprite matrix.
    SpriteMatrix = malloc(sizeof(GMatrix));
    
    // dump all these into the matrix.
    for (int i = 0; i < STANCES; ++i)
        for (int j = 0; j < DIRECTIONS; ++j)
            for (int k = 0; k < GPARTS; ++k)
            {
                SpriteMatrix->points[i][j][k] = points[i][j][k];
                SpriteMatrix->indices[i][j][k] = indices[i][j][k];
            }

}



-(NSArray*) spriteImages
{
  //  NSLog(@"orientation: %i", self.orientation);
    int dir = (self.orientation > 2) ? 2 : self.orientation;
    
    // 2,3 => side(2); 0,1 => front(0);
    int armdir = (self.orientation > 1) ? 2 : 0;
    
    // because goblins are different than the player!!
    NSString* suffix[3] = {@"front",@"back",@"side"};
    
    // where is head backside coming from?
    /*
     *  Body part sprite names for STARTING FRONT
     */

    NSString* g_head = [NSString stringWithFormat:@"head-%@.png", suffix[dir]];
    
    NSString* g_armour = [NSString stringWithFormat:@"armour-%@.png", suffix[dir]];
    
    // arm will be used twice in the case of front / back
    NSString* arm = [NSString stringWithFormat:@"arm-%@.png", suffix[armdir]];
    
    // this doesn't need to be initialized every time...work in some code for constant sprites...
    NSString* staff = [NSString stringWithFormat:@"staff.png"];
    
    NSString* const_hand = [NSString stringWithFormat:@"hand-right.png"];
    NSString *const_leg, *leg_or_hand, *arm_or_hand;
    
    // if front or back, use one animation for legs;
    if (self.orientation < 2)
    {
        // const leg will be animated in front / back situations
        const_leg = [NSString stringWithFormat:@"legs-%@-0.png", suffix[dir]];
        leg_or_hand = const_hand;
    }
    // leg1 is front leg, and leg_or_hand is back leg
    else
    {
        // these legs will move in a pattern
        const_leg = [NSString stringWithFormat:@"leg-side-front.png"];
        leg_or_hand = [NSString stringWithFormat:@"leg-side-back.png"];
    }
    // for striking
    if (self.orientation == 3)
        arm_or_hand = [NSString stringWithFormat:@"hand-right.png"];
    else
        arm_or_hand = [NSString stringWithFormat:@"arm-%@.png", suffix[armdir]];
    /*
     * Body part sprite names for SIDE
     */
    
    NSArray* g_sprites = [[NSArray alloc] init];
    
    // assign to phases?
    g_sprites = [NSArray arrayWithObjects:
                 g_head,
                 g_armour,
                 arm,
                 arm_or_hand,
                 const_leg,
                 const_hand,
                 leg_or_hand,
                 staff, nil];
    
    return g_sprites;
    
    
}



-(void) defineParts
{
    /* 
     *   Energy bar ssprite names
     */
    
  //  NSString* back_bar_string = [NSString stringWithFormat:@"back_bar.png"];
    
  //  NSString* front_bar_string = [NSString stringWithFormat:@"front_bar.png"];
    
    /* 
     *  Init Energy Bar Sprite
     */
    // store filenames in variables?
   // front_bar = [CCSprite spriteWithImageNamed:front_bar_string];
    // back_bar = [CCSprite spriteWithImageNamed:back_bar_string];
    
    // make front-back-side part of array?
 
  //  NSLog(@"parts: %i sprites: %i", [parts count],[g_sprites count]);
    
    
    // parts = [NSArray arrayWithObjects:head,nil]; // add front and back bars soon.
    
    // put this in the init function - it should be stored somewhere.
    // perhaps make an indices constant for the goblin.
    // yeah, that's a good idea. to add next.
    // put into phases. parts array comes from movable.m

    parts = [[NSMutableArray alloc] init];
  
    NSArray *g_sprites = [self spriteImages];
   
    // then re-initialize...
    for (int i = 0; i < [g_sprites count]; ++i)
    {
  
        // initialize sprites
        CCSprite* myPart = [[CCSprite alloc] init];
      
        [parts addObject:myPart];
        
        // ADD CHILD --takes care of antialiasing, scale, and opacity.
        [self addSprite:myPart z:SpriteMatrix->indices[stance][orientation][i]]; // replace 1 with orientation
       
        CCSpriteFrame* myFrame = [frameCache spriteFrameByName:[g_sprites objectAtIndex:i]];

        [myPart setSpriteFrame:myFrame];

        myPart.position = SpriteMatrix->points[stance][orientation][i]; // replace 1 with orientation
        
        [myPart.texture setAntialiased:NO];
        
    }
    
   [self addSignals];
  
    [self addLifeBar:BARPOS];

}

-(void) addAttackPoint
{
    
    attack_point = [[CCSprite alloc] init];
    CCSpriteFrame* myFrame = [frameCache spriteFrameByName:@"attackpoint.png"];
    [attack_point setSpriteFrame:myFrame];
    
    // this adds the child
    [self addSprite:attack_point z:40];
    attack_point.position = attackPoint;
    attack_point.visible = YES;

}
-(void) switchPosition
{
    if (striking == 1)
     {
     NSLog(@"RETRACT");
     [self unschedule:@selector(stopStrike:)];
     [self retractWeapon];
     }
    // gather sprite images
    NSArray *g_sprites = [self spriteImages];
    
    for (int i = 0; i < [g_sprites count]; ++i)
    {
       CCSprite* myPart = [parts objectAtIndex:i];

        // set stacking
        myPart.zOrder = SpriteMatrix->indices[stance][orientation][i]; // replace 1 with orientation

        // set position
        myPart.position = SpriteMatrix->points[stance][orientation][i]; // replace 1 with orientation
        
        CCSpriteFrame* myFrame = [frameCache spriteFrameByName:[g_sprites objectAtIndex:i]];
        
        // set sprite frame of part
       [myPart setSpriteFrame:myFrame];
        myPart.flipX = (orientation == 3) ? YES : NO;
    }
  //  recentSwitch = 1;
  //  [self scheduleOnce:@selector(switchReady:)delay:1];
  
}
/*
 * Reset Sprite Properties
 */
-(void) resetProps
{
    if ([parts count] >= 8 && stance == 0)
    {
        // make these global?
        CCSprite* arm = [parts objectAtIndex:2];
        CCSprite* armhand = [parts objectAtIndex:3];
        CCSprite* hand = [parts objectAtIndex:5];
        CCSprite* staff = [parts objectAtIndex:7];
        
        staff.flipY = NO;
        staff.rotation = 0;
        arm.rotation = 0;
        armhand.flipY = NO;
        armhand.rotation = 0;
        hand.rotation = 0;
        hand.flipX = NO;
    }
}
-(void) resumeStrikeWatch:(CCTime)dt
{
     striking = 0;
    [status setString:([NSString stringWithFormat:@"striking: %i", striking])];
}
-(void) switchReady:(CCTime)dt
{
    recentSwitch = 0;
}
/*
 *  Strike Logic
 */
-(void) stopStrike:(CCTime)dt
{
    [self retractWeapon];
   // attack_point.position = attackPoint;
    
}
-(void) retractWeapon
{
    stance = 0;
    striking = 2; // refractory period
    [self setStaff];
    [self resetProps];
    [self scheduleOnce:@selector(resumeStrikeWatch:)delay:refractory_period];
    strikeStop = [NSDate timeIntervalSinceReferenceDate];
    
    attackPoint = ccp(0,0);
}
-(void) setStaff
{
    int nums[4] = {2,3,4,7};
    
    for (int i = 0; i < 4; ++i)
    {
        CCSprite* mySprite = [parts objectAtIndex:nums[i]];
        mySprite.position = SpriteMatrix->points[stance][orientation][nums[i]];
       
    }
    for (int i = 0; i < [parts count]; ++i)
    {
         CCSprite* mySprite = [parts objectAtIndex:i];
         mySprite.zOrder = SpriteMatrix->indices[stance][orientation][i];
    }
    
}
-(void) onPause
{
    NSTimeInterval pauseTime = [NSDate timeIntervalSinceReferenceDate];
    if (striking == 1)
    {
      strikeTimeSoFar = pauseTime-strikeStart;
       assert(strikeTimeSoFar > 0);
    }
    else if (striking == 2)
    {
      strikeTimeSoFar = pauseTime-strikeStop;
       assert(strikeTimeSoFar > 0);
    }
    
    [self stopAllActions];
    [self stopMoving];
}
-(int) strike
{
    if (striking > 0 || showingDamage == YES) return 0;
    
    [soundManager playSound:LONG_SLASH];
    
    strikeStart = [NSDate timeIntervalSinceReferenceDate];
    
      if ([parts count] >= 8)
    {
        striking = 1;
        stance = 1;
   //     NSLog(@"set staff");
        [self setStaff];
        [self scheduleOnce:@selector(stopStrike:)delay:strikeDur];
        
        CCSprite* arm = [parts objectAtIndex:2];
        CCSprite* armhand = [parts objectAtIndex:3];
        CCSprite* hand = [parts objectAtIndex:5];
        CCSprite* staff = [parts objectAtIndex:7];
        
        int vertX = 27;
        int vertY = 62;
        int horizX = 58;
        int front_angle = 0;
        switch (orientation)
        {
            case 0:
                staff.flipY = YES;
                staff.rotation = front_angle;;
                arm.rotation = 0;
                armhand.flipY = NO;
                hand.rotation = front_angle;
                armhand.rotation = 0;
                hand.flipX = YES;
                attackPoint = ccp(-vertX,-vertY);
                break;
                
            case 1:
                staff.flipY = NO;
                /*  staff.position = ccp(26,24);*/
                staff.rotation = 0; // maybe encapsulate in helper function
                arm.rotation = 0;
                armhand.flipY = YES;
                hand.rotation = 0;
                armhand.rotation = 0;
                attackPoint = ccp(vertX,vertY);
                break;
                
            case 2:
                staff.rotation = 90;
                staff.flipY = NO;
                arm.rotation = -90;
                armhand.flipY = NO;
                hand.rotation = 90;
                armhand.rotation = 0;
                attackPoint = ccp(horizX,0);
                break;
                
                // we may need to add another hand for this one!! ACK!!
                // or we could just have another image for the staff...
            case 3:
                staff.flipY = NO;
                staff.rotation = -90;
                staff.position = ccp(-22,0);
                armhand.flipY = NO;
                hand.rotation = 0;
                arm.rotation = 0;
                armhand.rotation = 90;
                attackPoint = ccp(-horizX,0);
                break;
     
        }
        // debugging
     //   attack_point.position = attackPoint;
    }
    return 0;
}
-(void) front_back_feet
{
    // get leg
    CCSprite* leg = [parts objectAtIndex:4];

    // first and fifth animation frame.
    int index = 0;
    
    // if at an odd-numbered frame, we use middle frame; else, use frame 0 (the default) or 2.
    if (walkCounter%2 == 1)
        index = 1;
    else if (walkCounter%4 == 2)
        index = 2;

    // can we use !orientation?
    NSString* orient = (orientation == 0) ? @"front" : @"back";
    NSString* legFrame = [NSString stringWithFormat:@"legs-%@-%i.png", orient,index];
    
    CCSpriteFrame* myFrame = [frameCache spriteFrameByName:legFrame];
    
    // set sprite frame of part
    [leg setSpriteFrame:myFrame];
    
    leg.flipX =  (walkCounter > 4) ? YES : NO;
    
}
-(void) side_feet
{
    
    // next up: finish side feet!
    CGPoint front_origin = SpriteMatrix->points[stance][orientation][4]; // replace 1 with orientation
    CGPoint back_origin = SpriteMatrix->points[stance][orientation][6]; // replace 1 with orientation
    
    CCSprite* front_leg = [parts objectAtIndex:4];
    CCSprite* back_leg = [parts objectAtIndex:6];
    
    int sign = (orientation == RIGHT) ? 1 : -1;
    
    CGPoint front_diff = ccp(0,0);
    CGPoint back_diff = ccp(0,0);
    
    switch (walkCounter)
    {
            
        case 1:
        front_diff = ccp(2,2);
        back_diff = ccp(-2,0);
        break;
            
        case 2:
        front_diff = ccp(4,4);
        back_diff = ccp(-4,0);
        break;
            
        case 3:
        front_diff = ccp(6,2);
        back_diff = ccp(-6,0);
        break;
            
        case 4:
        front_diff = ccp(8,0);
        back_diff = ccp(-8,0);
        break;
            
        case 5:
        front_diff = ccp(6,0);
        back_diff = ccp(-6,2);
        break;
            
        case 6:
        front_diff = ccp(4,0);
        back_diff = ccp(-4,4);
        break;
            
        default:
        front_diff = ccp(2,0);
        back_diff = ccp(-2,2);
        break;

    }
    front_diff.x *=sign;
    back_diff.x *= sign;
    front_leg.position = ccp(front_origin.x+front_diff.x,front_origin.y+front_diff.y);
    back_leg.position = ccp(back_origin.x+back_diff.x, back_origin.y+back_diff.y);
}
-(void) goblin_bob
{
    for (int i = 0; i < [parts count]; ++i)
    {
        // don't count legs
        if (i != 4 && (i != 6 || orientation < 2))
        {
            CGPoint part_origin = SpriteMatrix->points[stance][orientation][i];
            CCSprite* myPart = [parts objectAtIndex:i];
            myPart.position = ccp(part_origin.x, part_origin.y+bob);
        }
    }
   
}
-(bool) facingPlayer
{
    float limit = 164.;
    CGPoint player_pos = arrayManager.player_position;
    float actualDistance = ccpDistance(player_pos, self.position);
    
    if (actualDistance > limit) return NO;
    
    int p_range = 32;
    
    switch (orientation)
    {
        NSLog(@"switch");
        case 0:
        if (player_pos.y < self.position.y && abs(player_pos.x - self.position.x) < p_range)
                return YES; else return NO;
        break;
        case 1:
        if (player_pos.y > self.position.y && abs(player_pos.x - self.position.x) < p_range)
                return YES; else return NO;
        break;
        case 2:
        if (player_pos.x > self.position.x && abs(player_pos.y - self.position.y) < p_range)
            return YES; else return NO;
        break;
        case 3:
        if (player_pos.x < self.position.x && abs(player_pos.y - self.position.y) < p_range)
                return YES; else return NO;
        break;
    }
    return NO;
}
-(void) goblin_anim: (CCTime) dt {
    
   
   // NSLog(@"orient: %i", myPlayer.orientation);
    // leg movements
    if (orientation < 2)
        [self front_back_feet];
    else
        [self side_feet];
    
    // up and down motion
    bob = (walkCounter > 3) ? 2 : 0;
    
    // make upper body move
    [self goblin_bob];
    
    // increment walk counter
    ++walkCounter;
    
    if (walkCounter > 7) walkCounter = 0;
    
  
    
 //   if ([self facingPlayer] == YES) [self strike];
    
    
    
}


-(int) checkTile: (int) myX andY: (int) myY // t=0 r=1 b=2 l=3
{
    // we may need to do diagonal wall checks as well - what if he is half on one tile, have on the other....
    if (myY < 0 || myX < 0) return 1;
   
    int lim = 32;
    switch (orientation)
    {
        case TOP:
            if (myY == 0) return 1;
            if ([arrayManager relToTileY:self.position] > lim) return 0; // switched
            // work in split tile logic here
            return [arrayManager checkForWall:myX andY:myY-1];
            break;
            
        case RIGHT:
         
            if ([arrayManager relToTileX:self.position] < -lim) return 0;
            
            // work in split tile logic here...
            if (abs(myX - (arrayManager.widthTiles-1)) < 2) return 1;
             return [arrayManager checkForWall:myX+1 andY:myY];
            break;
            
        case BOT:
            // NSLog(@"checking bot\n");
            if ([arrayManager relToTileY:self.position] < -lim) return 0;
           // if (abs(myY - (arrayManager.heightTiles-1)) < 2) return 1;
            
            return [arrayManager checkForWall:myX andY:myY+1]; // rev.
            break;
            
        case LEFT:
            if ([arrayManager relToTileX:self.position] > lim) return 0;
            // NSLog(@"checking left\n");
         
            return [arrayManager checkForWall:myX-1 andY:myY];
            break;
    }
    
    return 0;

}

/* 
 *  Goblin movement - we will want to improve the AI here and provide collision detection...
 */
-(void) stopChase:(CCTime)dt
{
    self.chase = 0;
    [self setOpacity:1];
}



-(void) checkDiagonals
{
    int myY = [arrayManager xToTile:self.position.y];
    int myX = [arrayManager yToTile:self.position.x];
    
    int t_up = myY-1; // switched...
    int t_down = myY+1;
    int t_right = myX+1;
    int t_left = myY-1;
    
    int orig = orientation;

    // for each of these cases, it depends on where goblin is.
    if (orientation > 1) // HORIZ MOVEMENT
    {
        if ([arrayManager relToTileY:self.position] > 0) // towards top
        {
            // if wall is on above left / goblin is going left
            if (([arrayManager checkForWall:t_left andY:t_up]>0 && orientation == LEFT)
            ||  ([arrayManager checkForWall:t_right andY:t_up]>0 && orientation == RIGHT)
                ||  ([arrayManager checkForWall:myX andY:t_up]>0))
            {
                self.stored_direction = orientation;
                orientation = BOT;
                [self switchPosition];
            }
            
        }
        else if ([arrayManager relToTileY:self.position] <= 0) // towards bottom
        {
            // if wall is on above left / goblin is going left
            if (([arrayManager checkForWall:t_left andY:t_down] > 0 && orientation == LEFT)
                ||  ([arrayManager checkForWall:t_right andY:t_down] > 0 && orientation == RIGHT)
                ||  ([arrayManager checkForWall:myX andY:t_down]>0))
            {
                /*ccColor3B normal = ccc3(248,47,8);
                [self setSpriteColor:normal];*/
            
                self.stored_direction = orientation;
                orientation = TOP;
            }
        }
    }
    else // VERT MOVEMENT
    {
        if ([arrayManager relToTileX:self.position] > 0) // towards right
        {
            // if wall is on top right and goblin is going up
            // OR
            // if wall is on bot right and goblin is going down
            // if wall is on above left / goblin is going left
            if (([arrayManager checkForWall:t_right andY:t_up] > 0 && orientation == TOP)
                ||  ([arrayManager checkForWall:t_right andY:t_down] > 0 && orientation == BOT)
                ||  ([arrayManager checkForWall:t_right andY:myY]>0))
            {
              /*  ccColor3B normal = ccc3(248,47,8);
                [self setSpriteColor:normal];*/
                
          
                self.stored_direction = orientation;
                orientation = LEFT;
            }
        }
        else if ([arrayManager relToTileX:self.position] < 0) // towards left
        {
             //  NSLog(@"%@blocked on left!",self.name);
            if (([arrayManager checkForWall:t_left andY:t_up] > 0 && orientation == TOP) // switched
                ||  ([arrayManager checkForWall:t_left andY:t_down] > 0 && orientation == BOT)
                ||  ([arrayManager checkForWall:t_left andY:myY]>0))
            {
              /*  ccColor3B normal = ccc3(248,47,8);
                [self setSpriteColor:normal];*/

                self.stored_direction = orientation;
                orientation = RIGHT;
            }
        }
        
    }
    if (orientation != orig) [self switchPosition];

}


-(bool) isOnTileX
{
    int myX = [arrayManager xToTile:self.position.x];
    float alignedX = [arrayManager tileToHorizCoord:myX];
    float diff = abs(alignedX-self.position.x);
    
    return (diff < 0.001) ? YES : NO;
}
-(bool) isOnTileY
{
    int myY = [arrayManager yToTile:self.position.y];
    int alignedY = [arrayManager tileToVertCoord:myY];
    float diff= abs(alignedY-self.position.y);
    
    return (diff < 0.001) ? YES : NO;
}
-(int) newDirection: (int)myX andY:(int)myY
{
    int nearMap = [self bitwise_wallcheck];
    
   // int inters = [self bitwise_playerdetect] & nearMap;
    
   // nearMap = (inters > 0) ? inters : nearMap;
    
    int twiddle = ~nearMap & 15;
    if (nearMap == 0 || twiddle == 0) return -1; // no openings or all openings
    
    float log2val = log(nearMap)/log(2);
  
    if (ceilf(log2val) == log2val)
    {
        int orig = orientation;
        orientation = log2val;
        if (orig != orientation)[self switchPosition];
        return 0;
    }
    
    // mask out all bits except smallest 4. this would yield 1, 2, 4, or 8 if 3 openings
    float t_log2val = log(twiddle)/log(2);
    
    // if three openings, create an array of 3; else, create an array of 2.
    int num =  (ceilf(t_log2val) == t_log2val) ? 3 : 2;
    // case for three openings
    
    
    int arr[num];
        
    int count = 0;
    
    // add workable directions to the array.
    for (int i = 0; i < 4; ++i)
    {
        int shifted = 1 << i;
            
        if ((nearMap & shifted) == shifted)
        {
                arr[count] = i;
                ++count;
           
        }
    }
    
    // generate random index - between 0-2 or 0,1.
    srand(time(NULL));
    int index = rand()%num;

    orientation = arr[index];
    
    [self switchPosition];
    return 0;
    
}
-(int) bitwise_playerdetect
{
    int dir = 0;
    
    CGPoint player_pos = arrayManager.player_position;
    
    if (player_pos.x > self.position.x) dir |= RIGHTBIT; else dir |= LEFTBIT;
    
    if (player_pos.y > self.position.y) dir |= UPBIT; else dir |= DOWNBIT;
    
    return dir;
    
}
/*
 1010,0101,0110,1001
 1 = down, 2 = up, 4 = right, 8 = left
 1+4,1+8,2+4,2+8 = 5,9,6,10
 1+2,4+8 = 3=VERT,12=HORIZ
 
 
 */

/* decide on how to chase the player based on
 onTile
 whether player is closer vertically or horizontally
 whether there are walls in the way
*/
-(int) chaseAxis: (CGPoint) player_pos
{
    if (abs(self.position.x - player_pos.x) < abs(self.position.y - player_pos.y))
        return HORIZ; else return VERT;
}
-(int) chasePlayer: (CGPoint) player_pos
{
    if (![self isOnTileX] && ![self isOnTileY]) return 0;
   // [self setOpacity:0.5];
    self.chase = 1;
    [self scheduleOnce:@selector(stopChase:)delay:1.];
    
    int orig = orientation;
    int final_dir = 0;
    int walls_loc = [self bitwise_wallcheck];
    int player_loc = [self bitwise_playerdetect];
    
    int options = walls_loc & player_loc;
    // how to factor in walls? what if you decide on a vert direction but there are walls?
  
    float log2val = log(options)/log(2);
        
        // if one option (use log2 to find out), go in that direction.
    if (ceilf(log2val) == log2val)
    {
            
        orientation = log2val;
        if (orientation != orig) [self switchPosition];
        return 0;
    }
    else // we have 2
    {
            // if two options, find which one has least distance.
        int vert_opt = options & 3;
        int horiz_opt = options & 12;
            
        // whatever dist is shortest, go in that direction.
        if ([self isOnTile])
            final_dir = ([self chaseAxis:player_pos] == VERT) ? vert_opt : horiz_opt;
        else if ([self isOnTileX])
            final_dir = vert_opt;
        else if ([self isOnTileY])
            final_dir = horiz_opt;
        else return 0;
        
        orientation = (int) log(final_dir)/log(2);
        
        if (orientation != orig)
          [self switchPosition];
    }
    return 0;
    
}

-(Boolean) dead_end
{
    return (([self bitwise_wallcheck] & (1 << orientation)) == 0);
}
-(Boolean) cenVelX
{
     float relX = [arrayManager relToTileX:self.position];
    return (self.orientation > 1 && relX < 2);
}
-(Boolean) cenVelY
{
    float relY = [arrayManager relToTileY:self.position];
    return (self.orientation < 2 && relY < 2);
}

-(Boolean) need_to_turn
{
    return ([self dead_end]==YES && ([self cenVelX] || [self cenVelY]));
}
-(Boolean) can_find_player
{
    float limit = 128.;
    float actualDistance = ccpDistance(arrayManager.player_position, self.position);
    return (actualDistance < limit && ([self cenVelX] || [self cenVelY]));
}
-(void) checkObstacles//:(CCTime)dt
{
    //[status setString:([NSString stringWithFormat:@"striking: %i", striking])];
    if ([self need_to_turn] || [self can_find_player])
    {
        int myX = [arrayManager xToTile:self.position.x];
        int myY = [arrayManager yToTile:self.position.y];
        [self newDirection:myX andY:myY];
    }

}
-(bool) openAbove: (int) myX andY:(int) myY
{
    int between_tile_range = 10;
   // int allowed_proximity = 2;
   // float relY = [arrayManager relToTileY:self.position];
    float relX = [arrayManager relToTileX:self.position];
    
   // if (relY < allowed_proximity) { [self setOpacity:0.75]; return YES; }
   // else [self setOpacity:1];
    
    if ([arrayManager checkForWall:myX andY:myY-1] == 1 ||
       /* [arrayManager checkForWall:myX andY:myY] == 1 ||*/
        
        (relX > between_tile_range && [arrayManager checkForWall:myX+1 andY:myY-1] == 1) ||
        (relX < between_tile_range && [arrayManager checkForWall:myX-1 andY:myY-1] == 1))
        return NO;
    
    return YES;
}

-(bool) openBelow: (int) myX andY:(int) myY
{
    
    int between_tile_range = 5;
   // int allowed_proximity = 2;
    
   // float relY = [arrayManager relToTileY:self.position];
    float relX = [arrayManager relToTileX:self.position];
    
  //  if (relY > -allowed_proximity) { [self setOpacity:0.75]; return YES; }
  //  else [self setOpacity:1];
    
    if ([arrayManager checkForWall:myX andY:myY+1] == 1 ||
   // [arrayManager checkForWall:myX andY:myY] == 1 ||
   
        (relX > between_tile_range && [arrayManager checkForWall:myX+1 andY:myY+1] == 1) ||
        (relX < -between_tile_range && [arrayManager checkForWall:myX-1 andY:myY+1] == 1))
    return NO;
    
    return YES;
}

-(bool) openLeft: (int) myX andY: (int) myY
{
    float relY = [arrayManager relToTileY:self.position];
  //  float relX = [arrayManager relToTileX:self.position];
    
    int between_tile_range = 5;
  //  int allowed_proximity = 2;
    
   // if (relX > -allowed_proximity) { /*[self setOpacity:0.50];*/ return YES; }
   // else [self setOpacity:1];
    
    if ([arrayManager checkForWall:myX-1 andY:myY] == 1 ||
      /*  [arrayManager checkForWall:myX andY:myY] == 1 ||*/
        
       (relY > between_tile_range && [arrayManager checkForWall:myX-1 andY:myY-1] == 1) ||
        (relY < -between_tile_range && [arrayManager checkForWall:myX-1 andY:myY+1] == 1))
        return NO;
    
    return YES;
}

-(bool) openRight: (int) myX andY: (int) myY
{
    float relY = [arrayManager relToTileY:self.position];
  //  float relX = [arrayManager relToTileX:self.position];
    
    int between_tile_range = 5;
   // int allowed_proximity = 2;
    
    
   // if (relX < allowed_proximity) { [self setOpacity:0.75]; return YES; }
  //  else [self setOpacity:1];
    
    if ([arrayManager checkForWall:myX+1 andY:myY] == 1 ||
      /*  [arrayManager checkForWall:myX andY:myY] == 1 ||*/
        
        (relY > between_tile_range && [arrayManager checkForWall:myX+1 andY:myY-1] == 1) ||
        (relY < -between_tile_range && [arrayManager checkForWall:myX+1 andY:myY+1] == 1))
        return NO;
    
    return YES;
}
// idea 1: make results of bitwise_walcheck persist.
// idea 2: make goblins stick with their position.
// idea 3: only do bitwise wallcheck when on tile.
-(int) bitwise_wallcheck
{
    int openings = 0;
    
    int myX = [arrayManager xToTile:self.position.x];
    int myY = [arrayManager yToTile:self.position.y];
    
    if ([self openBelow:myX andY:myY] == YES || [self isOnTileY]== NO)
    { openings |= DOWNBIT; bot_signal.visible = NO; } else { bot_signal.visible = YES; }
    
    if ([self openAbove:myX andY:myY] == YES || [self isOnTileY]==NO)
    {   openings |= UPBIT; top_signal.visible = NO; } else top_signal.visible = YES;
    
    if ([self openRight:myX andY:myY]==YES || [self isOnTileX]==NO)
    { openings |= RIGHTBIT; right_signal.visible = NO; } else right_signal.visible = YES; // 4
    
    if ([self openLeft:myX andY:myY]==YES || [self isOnTileX]==NO)
    { openings |= LEFTBIT;  left_signal.visible = NO; } else left_signal.visible = YES; // 8
    
    return openings;
    
}

-(bool) isOnTile
{
    return [self isOnTileX] && [self isOnTileY];
}
-(void) onTileCheck:(CCTime)dt
{
    int orig = orientation;
    
    // return to normal direction after aligning to tile.
    if ([self isOnTile])
    {
        // could be problematic because we're not checking if there's a wall. 
        if (self.stored_direction > -1)
        {
          /*  ccColor3B normal = ccc3(94,94,231);
            [self setSpriteColor:normal];*/
            int orig = orientation;
            orientation = stored_direction;
            if (orientation != orig) [self switchPosition];
            stored_direction = -1;
           
        }
    }
    if (orig != orientation) [self switchPosition];
}
/* tests*/
-(bool) inBounds: (int) obj C: (int) center L: (int) lim
{
    return (obj > center - lim && obj < center + lim);
}
/*
-(bool) touchWeapon: (int) obj C: (int) center L: (int) lim andHilt: (int) hilt
{
    bool hit = NO;

    for (int i = obj; i > obj-length; --i)
    {
        if ([self inBounds: (int) obj C: (int) center L: (int) lim] == YES)
        {
            hit = YES;
            break;
        }
    }
    
    return hit;
}*/
/* next up: test whether one line overlaps with another line*/
-(bool) overlaps: (int) start_A eA: (int) end_A sB: (int) start_B eB: (int) end_B
{
    assert(start_A < end_A);
    assert(start_B < end_B);
    
    if ((start_B >= start_A && start_B <= end_A) || (start_A >= start_B && start_A <= end_B))
        return YES; else return NO;
    /*
     SA----------EA
        SB-----------EB
     
     here, SB > SA AND SB < EA AND
     
         SA----------EA
     SB-------EB
     
     here, SA > SB AND EB > SA
     
                 SA----------EA
     SB-------EB
     
     here, SSA > SB BUT EB < SA
     
     SA----------EA
                    SB-------EB
     
     here, SB > SA BUT SB > EA
     */
}
// checks to see if staff made contact with the player
-(void) checkAttack
{
    // get position of player
    CGPoint player_pos = [arrayManager player_position];
    
    // set dimensions of staff and player. player_lim is 1/2 player width; replace 32 with player width at one point
    int player_lim = 32;
    int wlength = 28;
    
    // initialize variables for the various points
    int start_A, end_A, start_B, end_B;
    int point, playerCenter;
    
    CGPoint weapon_tip;
    weapon_tip.x = self.position.x + attackPoint.x;
    weapon_tip.y = self.position.y + attackPoint.y;
    switch (orientation)
    {
        case BOT:
            // staff
            start_A = weapon_tip.y; // end of staff
            end_A = weapon_tip.y + wlength; // hilt
            
            //player
            start_B = player_pos.y - player_lim;
            end_B = player_pos.y + player_lim;
            playerCenter = player_pos.x;
            point = weapon_tip.x;
            break;
        case TOP: // top & right are similar
            //staff
            start_A = weapon_tip.y - wlength; // hilt
            end_A = weapon_tip.y; //end
            
            //player
            start_B = player_pos.y - player_lim;
            end_B = player_pos.y + player_lim;
            playerCenter = player_pos.x;
            point = weapon_tip.x;
            break;
        case RIGHT:
            //staff
            start_A = weapon_tip.x - wlength; // hilt
            end_A = weapon_tip.x; //end
            
            //player
            start_B = player_pos.x - player_lim;
            end_B = player_pos.x + player_lim;
            
            // for testing bounds
            playerCenter = player_pos.y;
            point = weapon_tip.y;
            break;
        case LEFT:
            start_A = weapon_tip.x; // end of staff
            end_A = weapon_tip.x + wlength; // hilt
            
            //player
            start_B = player_pos.x - player_lim;
            end_B = player_pos.x + player_lim;
            playerCenter = player_pos.y;
            point = weapon_tip.y;
            break;
    }
    
    if ([self inBounds:point C:playerCenter L:player_lim] == YES
        && [self overlaps: start_A eA: end_A sB: start_B eB: end_B])
    {
        NSLog(@"hit with spear!!");
        [(GameLayer*)[self parent] playerDamage:self]; // inflict damage to player
    }
}
-(CGPoint) getNormalVelocity
{
    CGPoint vel = self.velocity;
    switch (orientation)
    {
        case BOT:
            vel.y = -moveSpeed;
            vel.x = 0;
            break;
            
        case RIGHT:
            vel.x = moveSpeed;
            vel.y = 0;
            break;
            
        case TOP:
            vel.x = 0;
            vel.y = moveSpeed;
            break;
            
        case LEFT:
            vel.x = -moveSpeed;
            vel.y = 0;
            break;
    }
    return vel;
}
-(void) goblin_update:(CCTime)dt
{
    if (striking == 1)
        [self checkAttack];
    else
        [self checkObstacles];
    
    CGPoint pos = self.position;
    CGPoint vel;
    if (showingDamage == NO)
      vel = [self getNormalVelocity];
    else
    {
      [self checkStunPath];
      vel = stunVel;
    }
    
    self.velocity = vel;
    pos.x += vel.x;
    pos.y += vel.y;
    self.position = pos;

}

/* 
 * Positioning Parts by Getting SpritePoints
 */

// spritePoints is called by switchPos and setParts
-(NSMutableArray*) spritePoints: (int) st
{
    // why set these arrays EVERY TIME if we are just using one of them?
    // Could we make htem global?
    int dir = self.orientation;
    
    CGPoint myPoints[GPARTS];
    // dir determines horiz. positioning. bob determines vert positioning.
    for (NSInteger i = 0; i < GPARTS; i++)
    {
        myPoints[i] = SpriteMatrix->points[stance][dir][i];
        myPoints[i].x *= scaleFactor;
        myPoints[i].y *= scaleFactor;
    }
    
     NSMutableArray* points = [self convertArray:myPoints];
    
    return points;
}
// converts C array to NSMutable Array
-(NSMutableArray*) convertArray: (CGPoint [GPARTS]) myPoints
{
    NSMutableArray* points = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 6; i++)
        [points addObject:[NSValue valueWithCGPoint:myPoints[i]]];
    
    return points;
}
-(void) unschedule
{
    [self unschedule:@selector(goblin_update:)];
    [self unschedule:@selector(goblin_anim:)];
}
-(void) removeSprites
{
    for (int i = 0; i < [parts count]; ++i)
    {
        CCSprite* mySprite = [parts objectAtIndex:i];
        [self removeChild:mySprite cleanup:YES];
    }
    
    [self removeBars];
   
    
  //   [self removeChild:status];
     [self removeChild:top_signal];
     [self removeChild:bot_signal];
     [self removeChild:right_signal];
     [self removeChild:left_signal];
}


-(void) stun: (CGPoint) foeVelocity
{
    [self updateLifeBar:BARPOS];
    
    GameLayer* gl = (GameLayer*)[self parent];
    
    myPlayer = (Movable*) gl.player;
    
    arrayManager = [ArrayManager sharedArrayManager];
    
    CGPoint vel = self.velocity;
    
    stunVel = [self stunDir:vel dir:myPlayer.orientation];
}


-(void) showDamage:(CCTime)dt
{
    int max = 12;
    
    counter++;
    if (counter > max)
    {
        // add timestamp logic for this.
        [self scheduleOnce:@selector(hideBars:)delay:0.45];
        [self recoveryState];
    }
    else
        [self dmgFX];
    
}
/*
 * Sets velocity to zero if there is something in the way.
 */
-(void) checkStunPath
{
    int myX = [arrayManager xToTile:self.position.x];
    int myY = [arrayManager yToTile:self.position.y];
    
    if ((stunVel.x < 0 && [arrayManager checkForWall:(myX-1) andY:myY]==1)
        || (stunVel.x > 0 && [arrayManager checkForWall:(myX+1) andY:myY]==1))
        stunVel.x = 0;
    
    if ((stunVel.y < 0 && [arrayManager checkForWall:myX andY:(myY+1)]==1)
        || (stunVel.y > 0 && [arrayManager checkForWall:myX andY:(myY-1)]==1))
        stunVel.y = 0;
}
-(CGPoint) stunDir: (CGPoint) vel dir:(int)d
{
    
     int myX = [arrayManager xToTile:self.position.x];
     int myY = [arrayManager yToTile:self.position.y];
    
    int orig = self.orientation;
    switch (d)
    {
        case RIGHT: // right
            if ([arrayManager checkForWall:(myX+1) andY:myY]==0)
              vel.x = stunSpeed; else vel.x = 0;
            self.orientation = LEFT;
            break;
        case LEFT: // left
             if ([arrayManager checkForWall:(myX-1) andY:myY]==0)
               vel.x = -stunSpeed; else vel.x = 0;
            self.orientation = RIGHT;
            break;
        case BACK: // up
            if ([arrayManager checkForWall:myX andY:(myY-1)]==0)
              vel.y = stunSpeed; else vel.y = 0;
            self.orientation = FRONT;
            break;
        case FRONT: // down
            if ([arrayManager checkForWall:myX andY:(myY-1)]==0)
              vel.y = -stunSpeed; else vel.y = 0;
            self.orientation = BACK;
            break;
    }
    if (orig != self.orientation) [self switchPosition];
    return vel;
}


-(void)decrementHealth:(SimpleItem*)weapon
{
    if (self.killed == NO)
    {
      if (showingDamage == NO)
      {
        health -= weapon.dmgStats.goblin_damage;
      }
    
      if (health <= 0) [self removeMe];
    }
}

@end
