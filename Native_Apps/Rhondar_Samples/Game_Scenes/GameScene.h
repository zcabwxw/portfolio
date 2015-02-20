//
//  GameScene.h
//  DoodleDrop
//
//  Created by nkatz on 11/30/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

// #import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "cocos2d-ui.h"
#import "ArrayManager.h"
#import "ItemButton.h"
#import "SoundManager.h"

#define TILESIZE 64
#define ITEM_BTN 0
#define ATTACK_BTN 1
#define PAUSE_BTN 2

typedef enum
{
    LayerTagGameLayer,
    LayerTagUILayer,
}
MultiLayerSceneTags;

typedef enum
{
    ActionTagGameLayerMovesBack,
    ActionTagGameLayerRotates,
}
MultiLayerSceneActionTags;

// declare classes
@class GameLayer;
@class UserInterfaceLayer;
@class ItemMenu;

@interface GameScene : CCScene
{
    
    ArrayManager* arrManager;
    
    SoundManager* soundManager;
    
    BOOL isTouchForUserInterface;
    
    NSMutableArray* walkFrames;
    
    GameLayer* GameLayer;
    
    ItemMenu* myMenu;

    NSArray* buttons;
    
    bool paused;
    
    ItemButton* currentButton;
    
    int scrollStart;
}






// Accessor methods
+(GameScene*) sharedLayer;

@property int scrollStart;
@property ItemMenu* myMenu;
@property bool paused;
@property (strong, readonly) GameLayer* GameLayer;
@property (weak, readonly) UserInterfaceLayer* uiLayer;
@property NSArray* buttons;
@property ArrayManager* arrManager;
@property SoundManager* soundManager;
@property ItemButton* currentButton;
+(id) scene;
-(void) GameOver;
-(void) YouWon;
-(void) dealloc;
@end
