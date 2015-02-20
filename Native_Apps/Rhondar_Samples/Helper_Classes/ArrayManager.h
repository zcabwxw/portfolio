//
//  GameLayer.m
//  Rogue of Rhondar
//
//  Created by nkatz on 11/26/12.
//  Copyright 2012 Birdley Media. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
// #import "Player.h"

#import "MenuTile.h"
#import "Globals.h"
#import "ItemNode.h"

@interface ArrayManager : NSObject {

    // these variables persist across scenes...
    int currentLevel;
    int maxLevels;
    
   // Player* _player;
    // and these persist across layers. 
    CCSpriteFrameCache *sframeCache;
    
    Boolean goalCaptured;
    
    int myKeys;
    int myHealth, maxHealth;
    int tileWidth;
    int tileHeight;

    int heightTiles, widthTiles;
    
    int mapHeight, mapWidth;
    int** map;
    
    CGPoint player_position;
    
    NSMutableArray* menuTiles;
    
    MenuTile* currentMenuTile;
    
    NSString* currentItem_A;
    
    NSString* currentItem_B;
    
    NSMutableArray* itemNodes;
    
    ItemNode *boomerang_node, *sword_node, *medicine_node, *FROSTBYTER_ESSENCE_node;
}


//@property (nonatomic, strong) Player* player;

@property Boolean goalCaptured;

// player properties
@property int myKeys;

@property CGPoint player_position;

@property int myHealth, maxHealth;

// game properties
@property int maxLevels;

@property int currentLevel;

// map
@property int heightTiles, widthTiles;

@property int** map;

@property int mapHeight, mapWidth;

// menu variables
@property int tileWidth, tileHeight;

@property NSMutableArray* menuTiles;

@property MenuTile* currentMenuTile;

@property NSMutableArray* itemNodes;

@property ItemNode *boomerang_node, *sword_node, *medicine_node, *FROSTBYTER_ESSENCE_node;

// currrent item
@property NSString* currentItem_A;

@property NSString* currentItem_B;



-(id)init;

+(id)sharedArrayManager;

// helpers

-(int) xToTile: (int) xCoord;

-(int) yToTile: (int) yCoord;

-(float) tileToHorizCoord: (int) tileX;

-(float) tileToVertCoord: (int) tileY;

-(float) relToTileX: (CGPoint) pos;

-(float) relToTileY: (CGPoint) pos;

-(int) checkForWall: (int) myX andY: (int) myY;

-(void) setItemNodes;
@end


