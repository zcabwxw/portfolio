//
//  Settings.m
//  Battleship
//
//  Created by nkatz on 4/1/13.
//  Copyright (c) 2013 nkatz. All rights reserved.
//

#import "Settings.h"

#import "DynamicViewsViewController.h"

@interface Settings ()

@end

@implementation Settings

@synthesize dimensions;

@synthesize myLevel;

@synthesize screenWidth;

@synthesize screenHeight;

- (void)viewDidLoad
{

    
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    // set defaults
    dimensions = 6;
    myLevel = 1;
    
	// Do any additional setup after loading the view.
    
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    
    view.backgroundColor = [UIColor lightGrayColor];
    
    screenHeight = view.frame.size.height;
    
    screenWidth = view.frame.size.width;
    
    self.view = view;
    
    float dimDist;
    float levelDist;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        dimDist = 0.07;
        levelDist = 0.04;
    }
    else
    {
        dimDist = 0.1;
        levelDist = 0.44;
    }
    
    
    
    [self addText: view withText:@"Set your Board Dimensions." andY: screenHeight*dimDist];
    
    [self addText: view withText:@"Choose your Level." andY: screenHeight*levelDist];

    
    
    [self startButton: view];
    
    [self levelSelector: view];
     
    [self boardSizeControl: view];
    
   
}
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void) addText: (UIView*) view withText: (NSString*) myText andY: (int) y;
{
    CGRect frame = CGRectMake(0, y, screenWidth, 50);
    
    UILabel* myTitle = [[UILabel alloc] initWithFrame:frame];
    
    myTitle.textAlignment = NSTextAlignmentCenter;
    
    
    
    myTitle.backgroundColor = [UIColor clearColor];
    
    
    int fontSize;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        fontSize = 30;
    else
        fontSize = 19;
    
    
   // myTitle.font = [UIFont boldSystemFontOfSize:46.0f];
    
    myTitle.font = [UIFont fontWithName:@"Verdana" size:fontSize];
    
    myTitle.text = myText;
    
    [view addSubview: myTitle];
}
-(void) startButton: (UIView*) view
{
    int height = 50;
    
    int width = 140;
    
    int locY = screenHeight*0.85;
    
    int locX = screenWidth*0.5 - width/2;
    
    CGRect frame = CGRectMake(locX, locY, width, height);
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    
    button.frame = frame;
    
    [button setTitle:@"Start Game" forState:UIControlStateNormal];
    
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    // color
    button.backgroundColor = [UIColor clearColor];
    
    // functionality
    [button addTarget:self
               action:@selector(switchScreen:)
     forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:button];
    
}
-(void) boardSizeControl: (UIView*) view
{
    int height = 60;
    
    int width = 260;
    
    int locY = screenHeight*0.09 + 60;
    
    int locX = screenWidth*0.5 - width/2;
    
    CGRect frame = CGRectMake(locX, locY, width, height);
    
    UISegmentedControl *segControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"6 x 6", @"8 x 8", @"10 x 10", nil]];
    
    [segControl setSelectedSegmentIndex:0];
   
     [segControl setTintColor:[UIColor whiteColor]];
    
      UIColor *myColor = [UIColor colorWithRed:0.0 green:.50 blue:.50 alpha:1.0];
    [segControl setBackgroundColor: myColor];
        // set default value here
    
    segControl.frame = frame;
    
     [segControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    
    [view addSubview:segControl];
    
    segControl.tag = 1;
}

-(void)levelSelector: (UIView*) view
{
    int height = 60;
    
    int width = 260;
    
    int locY = screenHeight*0.425+60;
    
    int locX = screenWidth*0.5-width/2;
    
    CGRect frame = CGRectMake(locX, locY, width, height);
    
    UISegmentedControl *segControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Level A", @"Level B", nil]];
    
    [segControl setSelectedSegmentIndex:0];
    
    segControl.frame = frame;
    
    [segControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    
    [segControl setTintColor:[UIColor whiteColor]];
    
    UIColor *myColor = [UIColor colorWithRed:0.0 green:.50 blue:.50 alpha:1.0];
    [segControl setBackgroundColor: myColor];
    
    [view addSubview:segControl];
    
    segControl.tag = 2;
    
}
-(IBAction)segmentAction:(id)sender
{
   // UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    
   
    int myTag = (int) [sender tag];
    
    int index = (int) [sender selectedSegmentIndex];
    
    switch (myTag)
    {
        case 1:
            NSLog(@"board selected");
            [self setBoardDimensions: index];
            
            break;
            
        case 2:
            NSLog(@"level selected");
            myLevel = index+1;
            break;
    }
   
}


-(void) setBoardDimensions: (int) index
{
    switch (index)
    {
        case 0:
            dimensions = 6;
            break;
            
        case 1:
            dimensions = 8;
            break;
            
        case 2:
            dimensions = 10;
            break;
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"preparing");
    if ([segue.identifier isEqualToString:@"settingsToGame"])
    {
       
        DynamicViewsViewController *controller = (DynamicViewsViewController*)segue.destinationViewController;
        controller.boardDim = dimensions;
        
        controller.enteredBoardNumber = myLevel;
    }
}

- (void) switchScreen: (id) sender
{
    [self performSegueWithIdentifier:@"settingsToGame" sender:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

/*
 Next up 
 
4) reset best time option

5) App Icons & Launch Images
 
7) ANDROID!!!!!

 
 */
