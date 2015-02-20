//
//  ArrayManager.m
//  Rogue of Rhondar
//
//  Created by nkatz on 11/26/12.
//  Copyright 2012 Birdley Media. All rights reserved.
//
#import "ArrayManager.h"

/*should probably model off of this for my conversion functions....*/

@implementation ArrayManager

// player status
@synthesize myKeys;
@synthesize myHealth, maxHealth;
@synthesize goalCaptured;

@synthesize heightTiles, widthTiles;
// level data

@synthesize currentLevel = _currenLevel;
@synthesize maxLevels;
@synthesize tileWidth, tileHeight;

@synthesize map;

@synthesize player_position;

@synthesize mapHeight, mapWidth;

@synthesize menuTiles;

@synthesize currentMenuTile;

@synthesize currentItem_A;

@synthesize currentItem_B;

@synthesize boomerang_node, FROSTBYTER_ESSENCE_node, sword_node, medicine_node;

@synthesize itemNodes;


+(id)sharedArrayManager {
    
    static id sharedArrayManager = nil;
    
    if (sharedArrayManager == nil)
    {
        sharedArrayManager = [[self alloc] init];
    }
    return sharedArrayManager;
}

// roles: setting item data, coordinate conversion, storing current items & player stats

-(void) setItemNodes
{
    sword_node = [ItemNode item_node];
    sword_node.itemCode = 0;
    sword_node.itemString = SWORD_IMG;
    
    FROSTBYTER_ESSENCE_node = [ItemNode item_node];
    FROSTBYTER_ESSENCE_node.itemCode = 1;
    FROSTBYTER_ESSENCE_node.itemString = FROSTBYTER_ESSENCE_IMG;
    
    boomerang_node = [ItemNode item_node];
    boomerang_node.itemCode = 2;
    boomerang_node.itemString = BOOMERANG_IMG;
    
    medicine_node = [ItemNode item_node];
    medicine_node.itemCode = 3;
    medicine_node.itemString = MEDICINE_IMG;
    
    itemNodes = [NSMutableArray arrayWithObjects:sword_node, FROSTBYTER_ESSENCE_node, boomerang_node, medicine_node, nil];
    
}

-(id) init
{
    if ((self=[super init]))
    {
        goalCaptured = NO;
        
        maxLevels = 3;
        
        maxHealth = myHealth = 20;
        
        self.currentLevel = 1;
        
        menuTiles = [[NSMutableArray alloc] init];
        
        currentItem_A = SWORD;
    }
    return self;
}

/*
 * Helper functions that convert point coordinates  to tile coordinates.
 */

// move to array Manager
-(int) xToTile: (int) xCoord
{
    int tileX =  xCoord / TILEDIM;
    
    return tileX;
}
-(int) yToTile: (int) yCoord
{
    int invertedTile =  (yCoord + TILEDIM)/ TILEDIM;  // used to be + 3*TILEDIM/2
    
    int tileY = heightTiles - invertedTile;
    
  //  NSLog(@"y to tileY: %i", tileY);
    return tileY;
}

/*
 * Helper functions that convert tile coordinates (small numbers) to point coordinates.
 */

-(float) tileToHorizCoord: (int) tileX
{
    float myX = tileX * TILEDIM + TILEDIM/2;
    
    return myX;
}

-(float) tileToVertCoord: (int) tileY
{
    // center point of tile is at bottom edge.
    // the coordinate of the tile is 32 less than it should be.
    
    float invertedPoint = tileY * TILEDIM + TILEDIM/2;
    
    float myY = mapHeight - invertedPoint;
    
    return myY;
}
/*
 * Get position relative to current tile
 */

-(float) relToTileX: (CGPoint) pos
{
    
    int myX = [self xToTile:pos.x];
    float alignedX = [self tileToHorizCoord:myX];
    float diff = pos.x-alignedX;
    
    return diff;
}
-(float) relToTileY: (CGPoint) pos
{
    // converting y position to a tile here.
    int myY = [self yToTile:pos.y/*-TILEDIM/2*/];
    
    // converting tile coord back to a position. 
    float alignedY = [self tileToVertCoord:myY];
   
    float diff= (pos.y-alignedY)/*-TILEDIM/2*/;
    
     //NSLog(@"pos: %0.0f myY: %i alignedY: %i diff: %0.0f", pos.y, myY, alignedY, diff);
    return diff;
}
/*
 * Check for Wall
 */

-(int) checkForWall: (int) myX andY: (int) myY
{
    if (myX < 0 || myX >= widthTiles
     || myY < 0 || myY >= heightTiles) return 1;
    return self.map[myY][myX];
}

@end
