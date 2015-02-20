//
//  SoundManager.m
//  GameEngine2
//
//  Created by Katz, Nevin on 1/12/15.
//  Copyright 2015 BirdleyMedia LLC. All rights reserved.
//

#import "SoundManager.h"

#import "AudioToolbox/AudioToolbox.h"

#import "AVFoundation/AVFoundation.h"


@implementation SoundManager

@synthesize audioplayers;

NSString* const ENEMY_DEATH = @"enemy_death1.mp3";

NSString* const ENEMY_DAMAGE = @"damage.mp3";

NSString* const PLAYER_DAMAGE = @"e_ripple1.mp3";

NSString* const SWORD_SLASH = @"basic_slash3.mp3";

NSString* const GET_KEY = @"get_item2.mp3";

NSString* const LONG_SLASH = @"long_slash1.mp3";

NSString* const SHOOT_ARROW = @"shoot1.mp3";

NSString* const OPEN_DOOR = @"door_open2.mp3";

NSString* const MENU_OPEN = @"menu-open.mp3";

NSString* const MENU_CLOSE = @"menu-close.mp3";

NSString* const HEALTH_REGEN = @"health-regen.mp3";

NSString* const BOOMERANG_SOUND = @"boomerang.mp3";
/*
 To add menu
 */
+(id)sharedSoundManager {
    
   
    static id sharedSoundManager = nil;
    
    if (sharedSoundManager == nil)
    {
        sharedSoundManager = [[self alloc] init];
    }
    return sharedSoundManager;
}

-(id) init
{
 
    if ((self=[super init]))
    {
        audioplayers = [[NSMutableArray alloc] init];
 
    }
    return self;
}
// search the list of players and delete the ones that are not playing.
-(AVAudioPlayer*) removeFreePlayers
{
   
    for (int i = 0; i < audioplayers.count; ++i)
    {
        AVAudioPlayer* myPlayer = [audioplayers objectAtIndex:i];
        
        if (myPlayer.isPlaying == 0)  { NSLog(@"REMOVE");[audioplayers removeObject:myPlayer]; }
    }
    return nil;
}
// play a sound by adding a new player to the array
-(int)playSound: (NSString*) mySound
{
    // remove players that are finished from the array.
    [self removeFreePlayers];
    
    NSString *soundFilePath = [NSString stringWithFormat:@"%@/%@",
                              [[NSBundle mainBundle] resourcePath],mySound];
    
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    
    AVAudioPlayer* myPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
    
    [audioplayers addObject:myPlayer];
    
    [myPlayer play];
    
    return 0;
    
}

@end
