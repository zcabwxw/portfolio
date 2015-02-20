//
//  Enemy.m
//  GameEngine2
//
//  Created by Katz, Nevin on 6/21/14.
//  Copyright 2014 BirdleyMedia LLC. All rights reserved.
//

#import "Enemy.h"
#import "GameLayer.h" 


@implementation Enemy

@synthesize width;


// health bars

@synthesize back_bar, front_bar;

@synthesize myPlayer;


-(void) hideBars:(CCTime) dt
{
    front_bar.visible = NO;
    back_bar.visible = NO;
}
-(void) addLifeBar:(int)myY
{
    front_bar = [CCSprite spriteWithImageNamed:@"lifebar-red.png"];
    back_bar = [CCSprite spriteWithImageNamed:@"lifebar-blue.png"];
    
    [self addChild:back_bar];
    [self addChild:front_bar];
    
    // change 32 to constant or variable
    CGPoint myPosition = ccp(0,myY);
    
    front_bar.position = myPosition;
    back_bar.position = myPosition;
    
    front_bar.visible = NO;
    back_bar.visible = NO;
    
    //front_bar.anchorPoint = ccp(0,0);
}

-(void) updateLifeBar:(int)myY
{
    front_bar.visible = YES;
    back_bar.visible = YES;
    
    float life = (float) health / (float) maxHealth;
    
    front_bar.scaleX = life;
    
    float shift = (1. - life)*front_bar.contentSize.width/2;
    
    front_bar.position = ccp(-shift,myY);
    
}
-(void) removeBars
{
    [self removeChild:front_bar];
    [self removeChild:back_bar];
}
/*damage*/
/*-(void) takeDamage: (Fightable*) foe
{
    //  GameLayer* gameLayer = [GameLayer* scene];
    health -= foe.attackDamage;
    

    if (health <=0)
    {
        [gameLayer removeObject:self];
    }
    else
    {
        [self damageState: foe];
    }
}*/

@end
