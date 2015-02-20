//
//  Enemy.h
//  GameEngine2
//
//  Created by Katz, Nevin on 6/21/14.
//  Copyright 2014 BirdleyMedia LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Fightable.h"
#import "GameLayer.h"


@interface Enemy : Fightable {
    
    int range;
    
    // add energy bar here.
    
    CCSprite *back_bar, *front_bar;
    
    Movable* myPlayer;

}


@property int width;

@property Movable* myPlayer;

@property CCSprite *back_bar, *front_bar;

-(void) hideBars:(CCTime) dt;

-(void) removeBars;

-(void) addLifeBar:(int)myY;

-(void) updateLifeBar:(int)myY;


@end
