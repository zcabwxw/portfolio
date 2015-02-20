//
//  Fightable.m
//  GameEngine2
//
//  Created by Katz, Nevin on 6/22/14.
//  Copyright 2014 BirdleyMedia LLC. All rights reserved.
//

#import "Fightable.h"
#import "GameLayer.h"
#import "CCAnimation.h"

@implementation Fightable

@synthesize killed;

@synthesize invincible;

@synthesize stunSpeed;

@synthesize attackDamage;

@synthesize health, maxHealth;

@synthesize showingDamage;

@synthesize arrayManager;

@synthesize soundManager;

@synthesize hitTop, hitBot, hitRight, hitLeft;

@synthesize damageSound;

@synthesize deathFrames;

@synthesize damageTime, dmgTimeSoFar;

-(void) initSounds
{
    damageSound = ENEMY_DAMAGE;
}

/*
 
 [ damageState ] => [showingDamage YES ] => [ schedule showDamage]
 */
-(void) damageState: (SimpleItem*) foe
{
   // generalized to simpleItem to account for hand-held weapons and projectiles.
   // damageState -> stun -> stunDir
    
    if (showingDamage == NO)
    {
        [soundManager playSound:damageSound];
        [self stun:foe.velocity];
        [self schedule:@selector(showDamage:) interval:damageTime];
        showingDamage = YES;
    }

}
-(void)decrementHealth:(SimpleItem*)weapon
{
    // this is expanded upon in the actual enemies. We need it here to manage combat in GameLayer. 
}

-(void) normalColor
{
    ccColor3B normal = ccc3(255,255,255);
    [self setSpriteColor:normal];
}
-(void) recoveryState
{
    [self normalColor];
    [self unschedule:@selector(showDamage:)];
    showingDamage = NO;
    counter = 0;
    self.velocity = CGPointZero;
    
  
    
}

-(void) showDamage:(CCTime)dt
{
    int max = 12;
    
    counter++;
    if (counter > max)
        [self recoveryState];
    else
        [self dmgFX];
}

-(CGPoint) stunDir: (CGPoint) vel dir:(int)orient
{
   
    switch (orient)
    {
        case RIGHT:
            if (!hitLeft && !showingDamage) vel.x = -stunSpeed; else vel.x = 0;
            break;
        case LEFT: // left
            if (!hitRight && !showingDamage) vel.x = stunSpeed; else vel.x = 0;
            break;
        case BACK: // up
            if (!hitBot && !showingDamage) vel.y = -stunSpeed; else vel.y = 0;
            break;
        case FRONT: // down
            if (!hitTop && !showingDamage) vel.y = stunSpeed; else vel.y = 0;
            break;
    }
    return vel;
}

-(void) stun: (CGPoint) foeVelocity
{
    arrayManager = [ArrayManager sharedArrayManager];
    
    CGPoint vel = self.velocity;
    int myX = [arrayManager xToTile:self.position.x];
    int myY = [arrayManager yToTile:self.position.y];
    
    // we may want to revise to account for diagonal motion.
    
    if (foeVelocity.x > 0 && [arrayManager checkForWall:(myX+1) andY:myY] == 0)
        vel = [self stunDir:vel dir:LEFT];
    
    else if (foeVelocity.x < 0 && [arrayManager checkForWall:(myX-1) andY:myY] == 0)
        vel = [self stunDir:vel dir:RIGHT];
    
    else if (foeVelocity.y > 0 && [arrayManager checkForWall:myX andY:(myY-1)] == 0)
        vel = [self stunDir:vel dir:FRONT];
    else if (foeVelocity.y < 0 && [arrayManager checkForWall:myX andY:(myY+1)] == 0)
        vel = [self stunDir:vel dir:BACK];
    else vel = [self stunDir:vel dir:self.orientation];
    
    self.velocity = vel;
}
/*
-(void) setSpriteColor: (ccColor3B) style {
     self.color = [[CCColor alloc] initWithCcColor3b:style];
}*/

// for indicating damage
-(void) setSpriteColor: (ccColor3B) style {
    
    NSUInteger n = [parts count];
    
    for (NSUInteger i = 0; i < n; i++)
    {
        CCSprite* mySprite = [parts objectAtIndex:i];
        
        mySprite.color = [[CCColor alloc] initWithCcColor3b:style];
        
    }
    
}
-(void) dmgFX
{
    ccColor3B redStyle = ccc3( 237, 45, 45 );
    ccColor3B electricPurpleOldStyle = ccc3( 191, 0, 255 );
    
    if (counter%2 == 0)
    {
        [self setSpriteColor:redStyle];
    }
    else // if (counter%4 == 0)
    {
        [self setSpriteColor:electricPurpleOldStyle];
    }
}


-(void) removeMe
{
    self.killed = YES;
    
    [soundManager playSound:ENEMY_DEATH];
    
    [self unschedule];
    
    [self removeSprites];
    
    [self deathAnimation:0];
    
    // add a sound effect here.
}
-(void) unschedule
{
  //  [self unschedule:@selector(goblin_update:)];
    
  //  [self unschedule:@selector(goblin_anim)];
}
-(void) removeSprites
{
}
-(void) setDeathFrames
{
    
}
-(void) deathAnimation: (int) index
{
   
    int frameCount = 8;
    
    NSMutableArray* frames = [NSMutableArray arrayWithCapacity:frameCount];
    
    /*
     *  Replace 0 with starting_frame.
     */
    for (int i = index; i < frameCount; i++)
    {
        int frameNumber = i+1;
        
        NSString* file = [NSString stringWithFormat:@"death-effect-1_0%i.png", frameNumber];
        
        CCSpriteFrame* frame = [frameCache spriteFrameByName:file];
        
        [frames addObject:frame];
    }
    
    float delay = 0.08f;
    
    self.scaleX = 2;
    self.scaleY = 2;
    CCAnimation* anime = [CCAnimation animationWithSpriteFrames:frames delay:delay];
    
    CCActionAnimate* animate = [CCActionAnimate actionWithAnimation:anime];
    
    CCActionCallFunc* callParent = [CCActionCallFunc actionWithTarget:self selector:@selector(parentRemove)];
    
    CCActionSequence* seq = [CCActionSequence actions: animate, callParent, nil];
    //CCActionRepeatForever* repeat = [CCActionRepeatForever actionWithAction:animate];
    
    [self runAction:seq];
}
-(void) parentRemove
{
    NSLog(@"parent remove");
    [(GameLayer*)[self parent] removeThis:self];
}

@end

