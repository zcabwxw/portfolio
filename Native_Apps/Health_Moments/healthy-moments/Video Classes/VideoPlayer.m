//
//  VideoPlayer.m
//  healthy-moments
//
//  Created by Katz, Nevin on 9/11/13.
//  Copyright (c) 2013 Katz, Nevin. All rights reserved.
//

#import "VideoPlayer.h"

#import <QuartzCore/QuartzCore.h>

@interface VideoPlayer ()

@end

@implementation VideoPlayer

@synthesize thumbnail;

@synthesize myTitle;

@synthesize videoPath;

@synthesize description;

@synthesize screenWidth, screenHeight;
@synthesize landView;

@synthesize portView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
   
        self.automaticallyAdjustsScrollViewInsets = NO; // Avoid the top UITextView space, iOS7 (~bug?)
    
    
    [super viewDidLoad];
    
    [self setLandscapeView];
    [self setPortraitView];

    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:)name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    
    /* sets initial orientation*/
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        
        self.view = landView;
    }
    else
    {
        self.view = portView;
    }
    
      
    screenHeight = self.view.frame.size.height;
    
    screenWidth = self.view.frame.size.width;
    
}

// orientation change response


- (void)orientationChanged:(NSNotification*)object
{
    UIDeviceOrientation deviceOrientation = [[object object] orientation];
    
    if (deviceOrientation == UIInterfaceOrientationLandscapeLeft || deviceOrientation == UIInterfaceOrientationLandscapeRight)
    {
      
        self.view = landView;
    }
    else if (deviceOrientation == UIInterfaceOrientationPortrait || deviceOrientation ==  UIInterfaceOrientationPortraitUpsideDown)

    {
       
        self.view = portView;
        
    }
    
}

-(void)setLandscapeView
{
  
  
    // declare main view!
    landView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    
    // get screen dimensions
    int land_screenHeight = landView.frame.size.width; /*+ frameCorrect;*/
    
    int land_screenWidth = landView.frame.size.height;
    
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
     if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
        land_screenWidth +=20;
   
    
    // set main view's background color
    landView.backgroundColor = [UIColor whiteColor];
    
    [self landscapeElements:land_screenWidth andHeight:land_screenHeight];
}

-(void)setPortraitView
{
    // declare main view!
    portView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    
    // get screen dimensions
    int port_screenHeight = portView.frame.size.height;
    
    
    int port_screenWidth = portView.frame.size.width;
    
     UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
     
     if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight)
     port_screenWidth +=20;
    
    // set main view's background color
    portView.backgroundColor = [UIColor whiteColor];
    
    [self portraitElements:port_screenWidth andHeight: port_screenHeight];
}
-(void)landscapeElements:(int)land_screenWidth andHeight:(int)land_screenHeight
{
    int margin = 10;
    
    int btnWidth = 250;
    
    int btnHeight = 212;
    
    int thumbnailX = margin*2;
    
    int thumbnailY = margin*9.5;
    
    int descDim[4];
    
    int titleDim[4];
    
    titleDim[0] = margin;
    titleDim[1] = land_screenHeight*0.18;
    
    titleDim[2] = land_screenWidth-2*margin;
    
    titleDim[3] = 100;
    
    descDim[0] = thumbnailX + btnWidth + margin;
    
    descDim[1] = thumbnailY - margin;
    
    descDim[2] = land_screenWidth - descDim[0]- margin;
    
    descDim[3] = land_screenHeight - thumbnailY;
    
	[self addText:titleDim andDesc:descDim andView:landView];
    
    int tag = 10;
    
    NSString* myImage = thumbnail;

    
    [self addButton:thumbnailX
               andY:thumbnailY
          withImage:myImage
              width:btnWidth
             height:btnHeight
              myTag:tag
            andView:landView];
}
-(void)portraitElements:(int) port_screenWidth andHeight:(int) port_screenHeight
{
    int margin = 10;
    int btnWidth = 250;
    
    int btnHeight = 212;
    
    int myX = (port_screenWidth - btnWidth)/2;
    
    int thumbnailY = port_screenHeight*0.25;
    
    int descDim[4];
    
    int titleDim[4];
    
    titleDim[0] = margin;
    titleDim[1] = port_screenHeight*0.17;
    
    titleDim[2] = port_screenWidth-2*margin;
    
    titleDim[3] = 40;
    
    //x & y positions
    descDim[0] = margin*2;
    
    descDim[1] = thumbnailY + btnHeight;
    
    // width & height
    descDim[2] = port_screenWidth - 2*margin;
    
    descDim[3] =  port_screenHeight - descDim[1];
    
	[self addText:titleDim andDesc:descDim andView:portView];
    
    int tag = 10;
    
    NSString* myImage = thumbnail;
    
    [self addButton:myX
               andY:thumbnailY
          withImage:myImage
              width:btnWidth
             height:btnHeight
              myTag:tag
            andView:portView];
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}
- (BOOL)shouldAutoRotate {
    return YES;
}

-(void)addButton: (int) myX
            andY: (int) myY
       withImage:(NSString*) myImage
           width:(int) btnWidth
          height:(int) btnHeight
           myTag:(int)index
         andView:(UIView*)myView
{
    UIButton* myButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [myButton setBackgroundImage:[UIImage imageNamed:myImage] forState:UIControlStateNormal];
    
    
    [myButton setImage:[UIImage imageNamed:@"play_icon.png"] forState:UIControlStateNormal];
    
    [[myButton layer] setBorderWidth:1.0f];
    
    [[myButton layer] setBorderColor:[UIColor blackColor].CGColor];
    
    
    CGRect frame = CGRectMake(myX, myY, btnWidth, btnHeight);
    
    myButton.frame = frame;
    
    myButton.tag = index;
    
    [myView addSubview:myButton];
    
    [myButton addTarget:self action:@selector(PlayMovie:)
       forControlEvents:UIControlEventTouchUpInside];
}

-(void) addText:(int*)titleDim andDesc:(int*)descDim andView:(UIView*)myView
{
   
    
    UIFont* textFont = [UIFont fontWithName:@"Arial" size:16];
    
    UIFont* titleFont = [UIFont fontWithName:@"Arial-BoldMT" size:16];
    
    NSString* bgTitle = myTitle;
    
    NSString* str = description;


    
    UITextView *myText = [[UITextView alloc] initWithFrame:CGRectMake(descDim[0],descDim[1],descDim[2],descDim[3])];
    
   
    
    UITextView *myLabel = [[UITextView alloc] initWithFrame:CGRectMake(titleDim[0],titleDim[1],titleDim[2],titleDim[3])];
    
    myText.userInteractionEnabled = FALSE;
    
    myLabel.userInteractionEnabled = FALSE;
    
  
    
    myText.text = str;
    
    myLabel.text = bgTitle;
    
   // [myLabel setScrollEnabled:YES];
    
    // color
    
    myText.textColor = [UIColor blackColor];
    
    myLabel.textColor = [UIColor blackColor];
    
    myLabel.backgroundColor = [UIColor clearColor];
    
    myText.backgroundColor = [UIColor clearColor];
    
    // font
    
    [myText setFont:textFont];
    
    [myLabel setFont:titleFont];
    
    // alignment
    
    myText.textAlignment = NSTextAlignmentLeft;
    
    myLabel.textAlignment = NSTextAlignmentCenter;
    
    
    CGSize containerSize = CGSizeMake(screenWidth, screenHeight);
    
    UIView* myContainer = [[UIView alloc] initWithFrame: (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=
        containerSize}];
    

    
    
    
    [myContainer addSubview:myText];
    
    [myContainer addSubview:myLabel];
    
        [myView addSubview:myContainer];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// play movie function
- (IBAction)PlayMovie:(id)sender
{
    
     NSURL* url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:videoPath ofType:@"mov"]];

    _moviePlayer =  [[MPMoviePlayerController alloc]
                     initWithContentURL:url];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:_moviePlayer];
    
    _moviePlayer.controlStyle = MPMovieControlStyleDefault;
    _moviePlayer.shouldAutoplay = YES;
    [self.view addSubview:_moviePlayer.view];
    [_moviePlayer setFullscreen:YES animated:YES];
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification {
    MPMoviePlayerController *player = [notification object];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:MPMoviePlayerPlaybackDidFinishNotification
     object:player];
    
    if ([player
         respondsToSelector:@selector(setFullscreen:animated:)])
    {
        [player.view removeFromSuperview];
    }
}
@end
