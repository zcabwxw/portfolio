//
//  VideoPlayer.h
//  healthy-moments
//
//  Created by Katz, Nevin on 9/11/13.
//  Copyright (c) 2013 Katz, Nevin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface VideoPlayer : UIViewController

{
    
    UIView* landView;
    
    UIView* portView;
    
NSString* description;

NSString* myTitle;

NSString* videoPath;

NSString* thumbnail;
    
    int screenWidth, screenHeight;

}

@property int screenWidth, screenHeight;

@property NSString* thumbnail;

@property NSString* myTitle;

@property NSString* videoPath;

@property NSString* description;

@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;
- (IBAction)PlayMovie:(id)sender;

@property UIView* landView;

@property UIView* portView;


@end
