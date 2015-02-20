//
//  Globals.m
//  GameEngine2
//
//  Created by Katz, Nevin on 6/14/14.
//  Copyright 2014 BirdleyMedia LLC. All rights reserved.
//

#import "Globals.h"


@implementation Globals

@synthesize contentScaleFactor;



NSString* const BOOMERANG_IMG = @"boomerang5-128.png";

NSString* const FROSTBYTER_ESSENCE_IMG = @"FROSTBYTER_ESSENCE-128.png";

NSString* const SWORD_IMG = @"sword-128.png";

NSString* const MEDICINE_IMG = @"medicine-128.png";


+(id) myGlobals {
    
    static id myGlobals = nil;
    
    if (myGlobals == nil)
    {
        myGlobals = [[self alloc] init];
    }
    return myGlobals;
}

-(id) init
{
    if ((self=[super init]))
    {
        
        CCDirector *director = [CCDirector sharedDirector];
        contentScaleFactor = [director contentScaleFactor];
        
        NSLog(@"GLOBALS SCALE: %f",contentScaleFactor);
        
        
        
    }
    return self;
}
@end
