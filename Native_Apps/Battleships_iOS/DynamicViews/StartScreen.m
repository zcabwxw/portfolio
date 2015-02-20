//
//  StartScreen.m
//  Battleship
//
//  Created by nkatz on 4/1/13.
//  Copyright (c) 2013 nkatz. All rights reserved.
//

#import "StartScreen.h"

@interface StartScreen ()

@end

@implementation StartScreen

@synthesize screenWidth;

@synthesize screenHeight;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSLog(@"loaded");
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    screenHeight = view.frame.size.height;
    
    screenWidth = view.frame.size.width;
    
    view.backgroundColor = [UIColor colorWithRed:0.0 green:.50 blue:.50 alpha:1.0];
    
    self.view = view;
    
    float titleSize;
    float timeSize;
    
      if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
      {
          titleSize = 90.0;
          timeSize = 50.0;
      }
      else
      {
          titleSize = 46.0;
          timeSize = 30.0;
      }
    
    int titleLoc = screenHeight*0.15;
    int timeLoc = screenHeight*0.9;
    // title
    [self addText: view withSize: titleSize
           andLoc: titleLoc
          andText:@"Battleships!"
           andTag: 7000
          andFont:@"Marker Felt"];
    
    // best time
    [self addText: view withSize:timeSize
           andLoc: timeLoc
          andText:@""
           andTag: 8000
          andFont:@"MarkerFelt-Thin"];
    
    [self startButton: view];
    
    [self getTime: view];
    
}
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void) getTime: (UIView*) view
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
   NSString* myTime = [defaults objectForKey:@"bestTime"];
    
    if (myTime != nil) [self postTime: myTime];
}
-(void) postTime: (NSString*) myTime
{
    UILabel* myText = (UILabel*) [self.view viewWithTag:8000];
    
    NSString* bestTime = [NSString stringWithFormat:@"Best Time - %@",myTime];
    [myText setText:bestTime];
    
}
-(void) addText:(UIView*) view
       withSize:(int) size
         andLoc:(int) y
        andText:(NSString*) text
         andTag:(int) myTag
        andFont:(NSString*) myFont
{
    
    NSLog(@"add text");
    CGRect frame = CGRectMake(0, y, screenWidth, size);
    
    UILabel* myText = [[UILabel alloc] initWithFrame:frame];
    
    myText.tag = myTag;
    
    myText.textAlignment = NSTextAlignmentCenter;
    
    
    
    myText.backgroundColor = [UIColor clearColor];
    
    myText.font = [UIFont boldSystemFontOfSize:size];
    
    myText.font = [UIFont fontWithName:myFont size:size];
    
    myText.textColor = [UIColor whiteColor];
    
    myText.text = text;
    
    [view addSubview: myText];
}
-(void) startButton: (UIView*) view
{
    int width = 140;
    
    int myY = screenHeight*0.5;
    
    int myX = screenWidth*0.5 - width/2;
    
    CGRect frame = CGRectMake(myX, myY, width, 50);
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    
    button.frame = frame;
    
    [button setTitle:@"New Game" forState:UIControlStateNormal];
    
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    // color
    button.backgroundColor = [UIColor clearColor];
    
    // functionality
    [button addTarget:self
               action:@selector(switchScreen:)
     forControlEvents:UIControlEventTouchUpInside];
    
    
    [view addSubview:button];
    
}

- (void) switchScreen: (id) sender
{
    [self performSegueWithIdentifier:@"startToSettings" sender:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
