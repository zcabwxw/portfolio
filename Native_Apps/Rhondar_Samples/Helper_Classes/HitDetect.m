//
//  HitDetect.m
//  GameEngine2
//
//  Created by Katz, Nevin on 1/29/15.
//  Copyright 2015 BirdleyMedia LLC. All rights reserved.
//

#import "HitDetect.h"


@implementation HitDetect

@synthesize blockPoints;
@synthesize Doors;

@synthesize arrM;
@synthesize soundManager;

@synthesize game_layer = _gamelayer;
@synthesize myPlayer = _player;

@synthesize head_top_margin;

+(id) SharedHitDetect {
    
    static id SharedHitDetect = nil;
    
    if (SharedHitDetect == nil)
        SharedHitDetect = [[self alloc] init];
    return SharedHitDetect;
}

/*
 * Section 1: Initialization
 */
-(id) init
{
    if (self=[super init])
    {
        head_top_margin = 20;
        arrM = [ArrayManager sharedArrayManager];
        
        soundManager = [SoundManager sharedSoundManager];
        
        blockPoints = [[NSMutableArray alloc] init];
        
        Doors = [[NSMutableArray alloc] init];
    }
    return self;
}
/*
 * Section 2 - Collision Detection with doors & walls
 */

-(int)doorCollision
{
    // iterate through blocks
    for (NSUInteger i = 0, n = Doors.count; i < n; i++)
    {
        // get the ith block
        CCSprite* currentDoor = [Doors objectAtIndex:i];
        
        // if actual distance is less than max distance, test for collision
        if ([Doors containsObject:currentDoor] && Doors.count > 0)
        {
            CGPoint doorPoint = currentDoor.position;
            
            int doorHeight = currentDoor.contentSize.height;
            
            int doorWidth = currentDoor.contentSize.width;
            
            int touchDist = (doorHeight < doorWidth) ?
            (_player.size.height/2 + currentDoor.contentSize.height)
            : (_player.size.width/2 + currentDoor.contentSize.width);
            
            // get actual distance between player and block's central point
            float actualDistance = ccpDistance(_player.position, doorPoint);
            
            if (actualDistance < touchDist)
            {
                // remove door from stage
                [_gamelayer removeChild: currentDoor cleanup:YES];
                
                if  (arrM.myKeys > 0)
                {
                    [soundManager playSound:OPEN_DOOR];
                    
                    int myX = [arrM xToTile:currentDoor.position.x];
                    int myY = [arrM yToTile:currentDoor.position.y];
                    
                    arrM.map[myY][myX] = 0;
                    // remove door from array
                    [Doors removeObject:currentDoor];
                    
                    // decrement keys
                    arrM.myKeys--;
                    
                }
                return 0;
                
            }
            if (ccpDistance(_player.position,doorPoint) < _player.size.height)
                [self collisionTest:doorPoint size:currentDoor.contentSize];
        }
    }
    
    
    return 0;
}

-(int)wallCollision
{
    CGSize blockSize = CGSizeMake(TILESIZE,TILESIZE);
    // iterate through blocks
    for (NSUInteger i = 0, n = blockPoints.count; i < n; i++)
    {
        // get the ith block
        NSValue* value = [blockPoints objectAtIndex:i];
        
        CGPoint blockPoint = [value CGPointValue];
       
    if (ccpDistance(_player.position,blockPoint) < _player.size.height*2)
        [self collisionTest:blockPoint size:blockSize];
    }
    return 0;
}

// Section 3: Helper functions for detecting whether player is within bounds, and stopping player, getting player's current tile

-(bool) inBounds: (int) obj C: (int) center L: (int) lim
{
    return (obj > center - lim && obj < center + lim);
}
-(void) stopVelX
{
    CGPoint vel = _player.velocity;
    vel.x = 0;
    _player.velocity = vel;
}
-(void) stopVelY
{
    CGPoint vel = _player.velocity;
    vel.y = 0;
    _player.velocity = vel;
    
}
-(CGPoint) getPlayerTile
{
    int myX = [arrM xToTile:_player.position.x];
    int myY = [arrM yToTile:_player.position.y];
    return CGPointMake(myX,myY);
}

/*
 * Section 4 - Touch functions
 */

-(Boolean)touchDown: (CGPoint)blockPoint size:(CGSize)obstacle_size
{
    int bot_player_edge = _player.position.y - _player.size.height/2;
    int block_top_edge = blockPoint.y + obstacle_size.height/2;
    
    return (bot_player_edge <= block_top_edge &&
            bot_player_edge > blockPoint.y &&
            [self alignedHoriz_WithBlock:blockPoint]);
}
-(Boolean)touchUp: (CGPoint)blockPoint size:(CGSize)obstacle_size
{
    int top_player_edge = _player.position.y + _player.size.height/2 - head_top_margin;
    int block_bot_edge = blockPoint.y - obstacle_size.height/2;
    
    return (top_player_edge >= block_bot_edge &&
            top_player_edge < blockPoint.y &&
             [self alignedHoriz_WithBlock:blockPoint]);
}
-(Boolean)touchRight: (CGPoint)blockPoint size:(CGSize)obstacle_size
{
    int block_left_edge = blockPoint.x - obstacle_size.width/2;
    int right_player_edge = _player.position.x + _player.size.width/2;
    
    return (right_player_edge >= block_left_edge
            && right_player_edge < blockPoint.x
            &&  [self alignedVert_WithBlock:blockPoint]);
}
-(Boolean)touchLeft: (CGPoint) blockPoint size:(CGSize)obstacle_size
{
    int block_right_edge = blockPoint.x + obstacle_size.width/2;
    int left_player_edge = _player.position.x - _player.size.width/2;
    
    return (left_player_edge <= block_right_edge
            && left_player_edge > blockPoint.x
            && [self alignedVert_WithBlock:blockPoint]);
}

/*
 *  Section 5 - Test alignment functions
 */
-(Boolean) alignedVert_WithBlock: (CGPoint) blockPoint
{

    int top_player_edge = _player.position.y + _player.size.height/2 - head_top_margin;
    int bot_player_edge = _player.position.y - _player.size.height/2;
    
    return ([self inBounds: bot_player_edge C:blockPoint.y L: TILESIZE/2]==YES
            || [self inBounds:top_player_edge C:blockPoint.y L:TILESIZE/2] == YES );
}
-(Boolean) alignedHoriz_WithBlock: (CGPoint) blockPoint
{
    // maybe align player if too close;
    
    int shoulderWidth = 0;
    int myWidth = _player.size.width-shoulderWidth;
    int right_player_edge = _player.position.x + myWidth/2;
    int left_player_edge = _player.position.x - myWidth/2;
    
    return ([self inBounds: left_player_edge C:blockPoint.x L: TILESIZE/2]==YES
            || [self inBounds: right_player_edge C:blockPoint.x L: TILESIZE/2]==YES );
    
}

/*
 * Section 6 - Listeners for Horizontal and Vertical Collision detection
 */
-(Boolean) horizCollision: (CGPoint) blockPoint size:(CGSize)obstacle_size
{
    if([self touchRight:blockPoint size:obstacle_size] && _player.velocity.x > 0)
    {
        _player.hitRight = YES;
        return YES;
    }

    if ([self touchLeft:blockPoint size:obstacle_size] && _player.velocity.x < 0)
    {
        _player.hitLeft = YES;
        return YES;
    }
    return NO;
    
}
-(Boolean) vertCollision: (CGPoint) blockPoint size:(CGSize)obstacle_size
{
   if ([self touchUp:blockPoint size:obstacle_size] && _player.velocity.y > 0)
   {
       _player.hitTop = YES;
       return YES;
   }
    if ([self touchDown:blockPoint size:obstacle_size] && _player.velocity.y < 0)
    {
        _player.hitBot = YES;
        return YES;
    }
    return NO;
}

-(Boolean) hitCollision: (CGPoint) blockPoint size:(CGSize)obstacle_size
{
    return ([self touchUp:blockPoint size:obstacle_size]    ||
            [self touchDown:blockPoint size:obstacle_size]  ||
            [self touchRight:blockPoint size:obstacle_size] ||
            [self touchLeft:blockPoint size:obstacle_size]);
       
}
/*
 *  Section 8 - Handlers for Collision Detection
 */
-(void) hitVert: (CGPoint) blockPoint size:(CGSize)obstacle_size
{
    int right_player_edge = _player.position.x + _player.size.width/2;
    int left_player_edge = _player.position.x - _player.size.width/2;

    int block_right_edge = blockPoint.x + obstacle_size.width/2;
    int block_left_edge = blockPoint.x - obstacle_size.width/2;

    int Xdiff_right = abs(right_player_edge - block_left_edge);
    int Xdiff_left = abs(left_player_edge - block_right_edge);
    
    int margin = 16;
    
    if (Xdiff_left < margin || Xdiff_right < margin)
        [_gamelayer alignPlayer:_player.position withX:YES andY:NO];
    else
        [self stopVelY];
}
-(void) hitHoriz: (CGPoint) blockPoint size:(CGSize)obstacle_size
{
    int top_player_edge = _player.position.y + _player.size.height/2;
    int bot_player_edge = _player.position.y - _player.size.height/2;
    
    int block_top_edge = blockPoint.y + obstacle_size.height/2;
    int block_bot_edge = blockPoint.y - obstacle_size.height/2;
    
    int Ydiff_head = abs(top_player_edge - block_bot_edge);
    int Ydiff_feet = abs(bot_player_edge - block_top_edge);
    
    int margin = 16;
    
    if (Ydiff_feet < margin || Ydiff_head < margin)
        [_gamelayer alignPlayer:_player.position withX:NO andY:YES];
    else [self stopVelX];
}
-(int) collisionTest:(CGPoint)blockPoint size:(CGSize)obstacle_size
{
    if ([self horizCollision:blockPoint size:obstacle_size])
        [self hitHoriz:blockPoint size:obstacle_size];
    
    if ([self vertCollision:blockPoint size:obstacle_size])
        [self hitVert:blockPoint size:obstacle_size];

    return 0;
}
/*
 *  Section 9 - Helpers for GameLayer's movement functions
 */
-(Boolean) isLeftOpen
{
    CGPoint my = [self getPlayerTile];
    if (_player.hitLeft == NO  &&
        ([arrM relToTileX:_player.position] > -20 || [arrM checkForWall:my.x-1 andY:my.y] != 1))
        return YES;
    return NO;
}
-(Boolean) isRightOpen
{
    CGPoint my = [self getPlayerTile];
    if (_player.hitRight == NO  &&
        ([arrM relToTileX:_player.position] < 20 || [arrM checkForWall:my.x+1 andY:my.y] != 1))
        return YES;
    return NO;
}
-(Boolean) isUpOpen
{

    CGPoint my = [self getPlayerTile];
    
    if (_player.hitTop == NO &&
        // if not high on tile OR there is no wall above
        ([arrM relToTileY:_player.position] - head_top_margin < 10  || [arrM checkForWall:my.x andY:my.y-1] != 1)
        
        // if not too high and no door above (this might go away with new doors)
     &&  ([arrM relToTileY:_player.position] - head_top_margin < 22 || [arrM checkForWall:my.x andY:my.y-1] != 2))
        return YES;
    return NO;
}
-(Boolean) isDownOpen
{
    CGPoint my = [self getPlayerTile];
    NSLog(@"hitBot: %d", _player.hitBot);
    if (_player.hitBot == NO &&
        ([arrM relToTileY:_player.position] > 0 ||
         [arrM checkForWall:my.x andY:my.y+1] != 1))
        return YES;
    
    return NO;
}


@end
