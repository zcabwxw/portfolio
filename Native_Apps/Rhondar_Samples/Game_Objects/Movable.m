//
//  Movable.m
//  GameEngine2
//
//  Created by Katz, Nevin on 6/21/14.
//  Copyright 2014 BirdleyMedia LLC. All rights reserved.
//

#import "Movable.h"
#import "Phase.h"

@implementation Movable

@synthesize counter;

@synthesize origSpeed, moveSpeed;

@synthesize origin;

@synthesize orientation;

@synthesize frameCache;

@synthesize scaleFactor;

@synthesize parts;

@synthesize status;

@synthesize left_signal, right_signal, top_signal, bot_signal, attack_point;


// multi-purpose function that sets the properties of a given sprite based on the phase passed into it.


// sets the frames of a list of sprites.

-(void) addSprite: (CCSprite*) mySprite z: (int) zi
{
    
    [self addChild:mySprite z:zi];

    
    // scaleFactor should ultimately come from the game layer. 
    mySprite.scaleX = 2*scaleFactor;
    mySprite.scaleY = 2*scaleFactor;
    [mySprite.texture setAntialiased:NO];
    mySprite.opacity = 1;
}
-(void) setSprites: (NSArray*) files
{
    for (NSUInteger i = 0; i < [files count]; i++)
    {
        NSString* filename = [files objectAtIndex:i];
        CCSprite* myPart = [parts objectAtIndex:i];
        CCSpriteFrame* myFrame = [frameCache spriteFrameByName:filename];
        [myPart setSpriteFrame: myFrame];
    }
}

-(void) initPhase: (Phase*) myPhase
{
    myPhase.pos = ccp(0,0);
    myPhase.flipX = 0;
    myPhase.flipY = 0;
    myPhase.rotate = 0;
}
-(void) spriteProps: (Phase*) myPhase andSprite: (CCSprite*) mySprite
{
  
    NSString* activeString= [NSString stringWithFormat:@"%@",myPhase.frame];
    
    //  NSLog(@"sprite frame: %@",activeString);
    CCSpriteFrame* myFrame = [frameCache spriteFrameByName:activeString];
    
    [mySprite setSpriteFrame:myFrame];
    
    mySprite.position = ccp(myPhase.pos.x*scaleFactor, myPhase.pos.y*scaleFactor);
    
    if (myPhase.z_index > -1) mySprite.zOrder = myPhase.z_index;
    
    mySprite.flipX = myPhase.flipX;
    
    mySprite.flipY = myPhase.flipY;
    
    mySprite.rotation = myPhase.rotate;
}
-(void) addSignals
{
    NSLog(@"ADD SIGNALS");
      [frameCache addSpriteFramesWithFile:@"utility.plist"];
    
    left_signal = [[CCSprite alloc] init];
    right_signal = [[CCSprite alloc] init];
    top_signal = [[CCSprite alloc] init];
    bot_signal = [[CCSprite alloc] init];
    
    CCSpriteFrame* myFrame = [frameCache spriteFrameByName:@"collision-wall.png"];
    
    
    NSMutableArray *signals = [NSMutableArray arrayWithObjects:left_signal,right_signal,top_signal,bot_signal, nil];
    
    CGPoint positions[4] = {ccp(-32,0),ccp(32,0),ccp(0,32),ccp(0,-32)};
    for (int i = 0; i < 4; ++i)
    {
        //CCSprite* mySignal = [[CCSprite alloc] initWithSpriteFrame:myFrame];
        CCSprite* mySignal = [signals objectAtIndex:i];
        [mySignal setSpriteFrame:myFrame];
        [self addSprite:mySignal z:40];
        mySignal.rotation = (i > 1) ? 0 : 90;
        mySignal.position = positions[i];
      
        mySignal.visible = NO;
        
       
        
    }
    
    
    
    /*  status = [CCLabelTTF labelWithString:@"HELLO WORLD!"
     fontName:@"Marker Felt"
     fontSize:10];
     
     [self addChild:status z:41 name:@"status"];
     
     status.position = ccp(0,32);
     
     status.visible = NO;*/
}
-(void) onPause
{
    
    [self stopAllActions];
    [self stopMoving];
}
-(void) onResume
{
    
}
-(void) stopMoving
{
    
}
-(void) setOpacity: (float) opacity
{
    for (int i = 0; i < [parts count]; ++i)
    {
        CCSprite* myPart = [parts objectAtIndex:i];
        myPart.opacity = opacity;
    }
}
@end
