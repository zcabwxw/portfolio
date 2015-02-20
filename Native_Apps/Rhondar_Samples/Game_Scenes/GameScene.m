//
//  GameScene.m
//  Rogue of Rhondar
//
//  Created by nkatz on 11/26/12.
//  Copyright 2012 Birdley Media. All rights reserved.
//


#import "Player.h"

#import "IntroScreen.h"
#import "GameScene.h"
#import "GameLayer.h"
#import "UserInterfaceLayer.h"
#import "ItemMenu.h"
#import "YouWon.h"
#import "GameOver.h"

@implementation GameScene

@synthesize arrManager;
@synthesize GameLayer = _GameLayer;
@synthesize myMenu = _myMenu;
@synthesize uiLayer = _uiLayer;
@synthesize buttons;
@synthesize currentButton;
@synthesize scrollStart;
@synthesize soundManager;

static GameScene* sharedMultiLayerScene = nil;

+(GameScene*)sharedLayer
{

    NSAssert(sharedMultiLayerScene!= nil, @"Scene not available");
    return sharedMultiLayerScene;
}

-(GameLayer*) gameLayer
{
    CCNode* layer = [self getChildByName:@"LayerTagGameLayer" recursively:NO];
    NSAssert([layer isKindOfClass:[GameLayer class]], @"%@: not a GameLayer",
    NSStringFromSelector(_cmd));
    return (GameLayer*) layer;
}
-(UserInterfaceLayer*) uiLayer
{
    CCNode* layer = [[GameScene sharedLayer] getChildByName:@"LayerTagUILayer" recursively:NO];
    NSAssert([layer isKindOfClass:[UserInterfaceLayer class]], @"@: not a UI!",
    NSStringFromSelector(_cmd));
    return (UserInterfaceLayer*)layer;
}
-(ItemMenu*) itemMenu
{
    CCNode* layer = [self getChildByName:@"myMenuLayer" recursively:NO];
    NSAssert([layer isKindOfClass:[ItemMenu class]], @"@: not a menu!",
             NSStringFromSelector(_cmd));
    return (ItemMenu*) layer;
}

+(id) scene
{
    CCScene* scene = [CCScene node];
    GameScene* layer = [GameScene node];
    [scene addChild:layer];
    return scene;
}

-(id) init
{
    self = [super init];
    paused = NO;
    arrManager = [ArrayManager sharedArrayManager];
    soundManager = [SoundManager sharedSoundManager];
    
    [arrManager setItemNodes];
    
    if (!self) return (nil);
    
    self.userInteractionEnabled = YES;

    sharedMultiLayerScene = self;
        
    // The GameLayer
    GameLayer* gameLayer = [GameLayer node];
    
    // [self addChild:gameLayer z:1 tag:LayerTagGameLayer];
    [self addChild:gameLayer z:1 name:@"LayerTagGameLayer"];
    
    _GameLayer = gameLayer;
    
    // the uiLayer
    _uiLayer = [ UserInterfaceLayer node];
    
    _myMenu = [ItemMenu node];
    
    [self addChild:_uiLayer z:10 name:@"GameSceneLayerTagInput"];
    
    [self addChild:_myMenu z:5 name:@"myMenuLayer"];
    
    _myMenu.visible = NO;
    
    buttons = [NSArray arrayWithObjects:
               _uiLayer.item_B_Button,
               _uiLayer.item_A_Button,
               _uiLayer.pauseButton,nil];
    
    
    return self;
}

// we may add an argument for the button and place in UIhelpers for roundButtons.
-(bool)onButton:(ItemButton*)myButton touchAt:(CGPoint)touchLoc
{
    // get button location
    CGPoint buttonLoc = myButton.position;
    
    // get size of button
    float radius = myButton.contentSize.width/2;
    
    // get distance of touch from button center
    float dist = ccpDistance(buttonLoc, touchLoc);
    
    // return true if touch distance is less than radius.
    return (dist <= radius);
}
-(bool) onSquareTile: (CGPoint) tileLoc andTouch: (CGPoint) touchLoc
{
    
    int leftBounds = tileLoc.x - TILESIZE/2;
    int rightBonds = tileLoc.x + TILESIZE/2;
    int topBounds = tileLoc.y + TILESIZE/2;
    int botBounds = tileLoc.y - TILESIZE/2;

    if (touchLoc.x > rightBonds ||
        touchLoc.x < leftBounds ||
        touchLoc.y > topBounds ||
        touchLoc.y < botBounds)
        return NO;

    return YES;
}
-(void) menuSelect:(CGPoint)location
{
    NSMutableArray *myTiles = arrManager.menuTiles;
    
    for (int i = 0; i < myTiles.count; ++i)
    {
        MenuTile* myTile = [myTiles objectAtIndex:i];
        
        [_myMenu.myGroup setTileScreenPos:myTile];
        // any way to neaten this up? maybe with bitwise?
        ItemButton* otherButton =
        (currentButton == _uiLayer.item_A_Button)
        ? _uiLayer.item_B_Button
        : _uiLayer.item_A_Button;
        
        // if pressing a tile, the tile has a current item, and the other button doesn't have this item
        if ([self onSquareTile:myTile.screenPos andTouch:location] == YES
            && myTile.currentItemNode != nil
            && myTile.currentItemNode.itemString != otherButton.currentItemNode.itemString)
        {
            // change item here. 
            if (arrManager.currentMenuTile != nil)
                [arrManager.currentMenuTile leave];
            
            [myTile focus];
            
            // designate this as the current tile.
            arrManager.currentMenuTile = myTile;
            
            // update the current button
            currentButton.currentItemNode = myTile.currentItemNode;
            
    
            // change to whatever the current button is.
            [currentButton setItemSprite:myTile.currentItemNode.itemString];
            
            // we'll need to get the button's current frame. 
        }
        
    }
}
-(void) togglePause
{
    if (paused == NO)
    {
        [soundManager playSound:MENU_OPEN];
        currentButton = _uiLayer.item_B_Button;
        //if (currentButton == _uiLayer.item_A_Button)
            [self showCurrentItem];
        
        _myMenu.visible = YES;
        [_GameLayer pauseAll];
        
        // we start with the non-sword button, since that would change most frequently in my view.
        currentButton = _uiLayer.item_B_Button;
        paused = YES;
    }
    else
    {
        [soundManager playSound:MENU_CLOSE];
        _myMenu.visible = NO;
        [_GameLayer resumeAll];
        paused = NO;
    }
    // add button logic for A & B here. we should be switching the currentButton
}
 -(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
 {
     // write function for identifying the buttno touched?
      CGPoint location = [touch locationInNode:self];
     
      // test for strike button
     ItemButton* myButton = [self identifyButton:location];

     if (myButton) [_uiLayer pressButton:myButton];
     if (myButton == _uiLayer.pauseButton) [self togglePause];
     
     else if (paused == NO)
     {
         if (myButton !=nil)
         {
             // pass current button's item into a function that calls switch / case logic.
             // probably need an item manager class for this.
             switch (myButton.currentItemNode.itemCode)
             {
                     
                 case SWORD:
                 [_uiLayer heroStrike];
                 break;
                     
                 case MEDICINE:
                 [soundManager playSound:HEALTH_REGEN];
                 [_uiLayer.myHearts regen_fx];
                 arrManager.myHealth +=20;
                     if (arrManager.myHealth > arrManager.maxHealth)
                         arrManager.myHealth = arrManager.maxHealth;
                 break;
                     
                 case BOOMERANG:
                     if (_GameLayer.boom.active == NO)
                         [_GameLayer addBoomerang];
                 break;
                 
                 case FROSTBYTER_ESSENCE:
                     // TO DO
                 break;
             }
         }
        
         else
         {
             _GameLayer.aligningX = NO;
             _GameLayer.aligningY = NO;
             
             _GameLayer.XStart = location.x;
             _GameLayer.YStart = location.y;
         }
     }
     else // if paused
     {
         // make the current item light up. 
         if (myButton != nil)
         {
             currentButton = myButton;
             [self showCurrentItem];
         }
         
         // if on menu
         scrollStart = location.y;
         
        
         // creat a function for this.....
         
         // you can't pick the same item for both buttons.
         // if same item is pressed, nothing happens.
     }
}

-(void) showCurrentItem
{
    
     NSMutableArray *myTiles = arrManager.menuTiles;
    
  
    for (int i = 0; i < myTiles.count; ++i)
    {
        
       MenuTile* myTile = [myTiles objectAtIndex:i];
       [myTile leave];
        
        
       if (currentButton.currentItemNode == myTile.currentItemNode)
       {
           [myTile focus];
           arrManager.currentMenuTile = myTile;
       }
    }
    // if current button was A, blank out the current item
    // search through the tiles
    // if the button's currentItem == tile currentItemString
    // light up the tile & return!
}


-(void) touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
  
    CGPoint loc = [touch locationInNode:self];
	
    if (paused == YES)
    {
        int dist = 4;
        CGPoint pos = _myMenu.myGroup.position;
        
        int diff =  (loc.y - scrollStart > 0) ? dist : -dist;
        
        if ((diff < 0 && _myMenu.myGroup.position.y > _myMenu.myGroup.origPos.y) ||
            (diff > 0 && _myMenu.myGroup.position.y < _myMenu.myGroup.origPos.y + TILESIZE))
        pos.y += diff;
        
        _myMenu.myGroup.position = pos;
        scrollStart = loc.y;
    }
  
    [self checkButtons: loc];
    
    // move player
    if (paused == NO
        && _GameLayer.player.attacking == NO
        && [self identifyButton:loc] == nil)
        
        [self movePlayer:loc];
}
-(void) checkButtons: (CGPoint) location
{
        for (int i = 0; i < buttons.count; ++i)
        {
            ItemButton* myButton = [buttons objectAtIndex:i];
            if (myButton.down == YES && [self onButton:myButton touchAt:location]==NO)
                [_uiLayer releaseButton:myButton];
        }
    
}
-(void) movePlayer:(CGPoint) location
{
    if ( _GameLayer.player.attackFinish == YES)
    {
        [_GameLayer.player stopAllActions];
        [_GameLayer.player returnStance];
      
    }
    _GameLayer.XCurr = location.x;
    _GameLayer.YCurr = location.y;
    
    // calculate difference between current and start location.
    _GameLayer.XDiff = _GameLayer.XCurr - _GameLayer.XStart;
    _GameLayer.YDiff = _GameLayer.YCurr - _GameLayer.YStart;
    
    // if there is a significant difference between touches, reset the start point for a more accurate angle.
    if (_GameLayer.XDiff > 3 || _GameLayer.YDiff > 3)
    {
        _GameLayer.XStart = _GameLayer.XCurr;
        _GameLayer.YStart = _GameLayer.YCurr;
    }
    
    // set the player speed.

    
    // find the arctangent of the horiz. and vert. distances traveled.
    
    double radians = (double)atan2(_GameLayer.YDiff, _GameLayer.XDiff);
    
    // convert angle from degrees to radians.
    
    float angle = CC_RADIANS_TO_DEGREES(radians);
    
    // convert negative angles so that they are above 180.
    
     CGPoint velocity;
    
     velocity.x = _GameLayer.player.velocity.x;
     velocity.y = _GameLayer.player.velocity.y;
    
    if (angle < 0)
    {
        float newAngle = 360+angle;
        angle = newAngle;
    }

    //right
    if (angle < 22.5 || angle >= 337.5)
    {

        // START HERE
        velocity.y = 0;
        _GameLayer.player.velocity = velocity;
        
        [_GameLayer moveRight];
     
        _GameLayer.hitTop = NO;
        _GameLayer.hitBot = NO;
        _GameLayer.hitLeft = NO;
        
    }
    // up right
    else if (angle >= 22.5 && angle < 67.5)
    {
        [_GameLayer moveRight];
        [_GameLayer moveUp];
    }
    //up
    else if (angle >=67.5 && angle < 112.5)
    {
        
        velocity.x = 0;
        _GameLayer.player.velocity = velocity;
        [_GameLayer moveUp];
        
        _GameLayer.hitRight = NO;
        _GameLayer.hitLeft = NO;
        _GameLayer.hitBot = NO;
    }
    //up left
    else if (angle >=112.5 && angle < 157.5)
    {
        [_GameLayer moveLeft];
        [_GameLayer moveUp];
        
        _GameLayer.hitRight = NO;
        _GameLayer.hitBot = NO;
    }
    //left
    else if (angle >=157.5 && angle < 202.5)
    {
        velocity.y = 0;
        _GameLayer.player.velocity = velocity;
        [_GameLayer moveLeft];
        
        _GameLayer.hitRight = NO;
        _GameLayer.hitTop = NO;
        _GameLayer.hitBot = NO;
    }
    //left down
    else if (angle >=202.5 && angle < 247.5)
    {
        [_GameLayer moveLeft];
        [_GameLayer moveDown];
        
        _GameLayer.hitRight = NO;
        _GameLayer.hitTop = NO;
    }
    //down
    else if (angle >=247.5 && angle < 292.5)
    {
        
        velocity.x = 0;
        _GameLayer.player.velocity = velocity;
        [_GameLayer moveDown];
        
        _GameLayer.hitRight = NO;
        _GameLayer.hitTop = NO;
        _GameLayer.hitLeft = NO;
    }
    // down right
    else if (angle >=292.5 && angle < 337.5)
    {
        [_GameLayer moveRight];
        [_GameLayer moveDown];
        
        _GameLayer.hitLeft = NO;
        _GameLayer.hitTop = NO;
    }
    
}

-(ItemButton*) identifyButton: (CGPoint) touchLoc
{

    for (int i = 0; i < buttons.count; ++i)
    {
        ItemButton* myButton = [buttons objectAtIndex:i];
        if ([self onButton:myButton touchAt:(CGPoint) touchLoc])
            return myButton;
    }
    NSLog(@"nil");
    return nil;
}
-(void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [touch locationInNode:self];

       if (paused == YES) [self menuSelect:location];
    
    ItemButton* btn = [self identifyButton:(CGPoint) location];
    if (btn) [_uiLayer releaseButton:btn];
    else
    {
    // touch stops, so velocity is set to zero.
    _GameLayer.player.velocity = CGPointZero;
    
    _GameLayer.aligningX = NO;
    _GameLayer.aligningY = NO;
    
    [_GameLayer clearHits];
    }
    
    
}

-(void) GameOver

{
    
    
  //  CCTransitionDirection* transition = [[CCTransitionDirectionDown scene:[YouWon scene]];
    
    //[CCTransitionDirectionDown  transitionWithDuration:1.5f scene:[YouWon scene]];
    
    //[CCTransitionFade transitionWithDuration:1.5f scene:[GameOver  scene]];
   // [[CCDirector sharedDirector] replaceScene:transition];
                                         
  [[CCDirector sharedDirector] replaceScene:[GameOver scene]
   withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionDown duration:1.0f]];
}

-(void) YouWon
{
   // CCTransitionFade* transition = [CCTransitionFade transitionWithDuration:1.5f scene:[YouWon scene]];
   // [[CCDirector sharedDirector] replaceScene:transition];
    
    [[CCDirector sharedDirector] replaceScene:[YouWon scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionDown duration:1.0f]];
}

-(void) onEnter
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    [super onEnter];
}

-(void) onEnterTransitionDidFinish
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    [super onEnterTransitionDidFinish];
    
}
-(void) onExit
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    NSLog(@"EXITING!");
    [super onExit];
    
    
}
-(void) onExitTransitionDidStart
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    [super onExitTransitionDidStart];
}
-(void) dealloc
{
    
    CCLOG(@"dealloc: %@", self);
}



@end
