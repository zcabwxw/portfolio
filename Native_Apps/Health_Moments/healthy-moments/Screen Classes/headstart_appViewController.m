//
//  headstart_appViewController.m
//  healthy-moments
//
//  Created by Katz, Nevin on 9/4/13.
//  Copyright (c) 2013 Katz, Nevin. All rights reserved.
//



#import "headstart_appViewController.h"

#import "SecScreen.h"

#import "Section.h"

#import "headstart_appAppDelegate.h"

#import "WebSlinger.h"

#import "AboutScreen.h"

@interface headstart_appViewController ()

@end


@implementation headstart_appViewController

@synthesize screenHeight;

@synthesize screenWidth;

@synthesize portraitView;

@synthesize landscapeView;

@synthesize destination;

@synthesize nextListArray;

@synthesize webview;

@synthesize dim;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
   
    
    // set backbar item of next screen
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:nil
                                                                            action:nil];
    // orientation code
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:)name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    
    // declare app delegate
    appDelegate = (headstart_appAppDelegate *)[[UIApplication sharedApplication] delegate];
  
    self.title = @"Health Moments";
    
    [self setGlobals];
    
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        
        [self land];
    }
    else
    {
        [self port];
    }
    
 
}
- (BOOL)shouldAutoRotate {
    return YES;
}
-(void) setGlobals {
    dim = 76;  // make into one variable...
    
    
    images[0]=@"info.png";
    
    images[1]=@"visit.png";
    
    images[2]=@"kitchen.png";
    
    images[3]=@"food.png";
    
    images[4]=@"toiletpaper.png";
    
    images[5]=@"cough.png";
    
   
    
    [self setLabels];
}
-(void) setLabels
{
    
   for (NSUInteger e = 0, n = appDelegate.sections.count; e < n; e++)
    {

        Section* aSection = [appDelegate.sections objectAtIndex:e];
        
        NSString* title = [aSection.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
 
        labels[e] = title;
        
        // if we are not dealing with the info button
        if (e > 0)
        {
            Topic* myTopic = [aSection.topics objectAtIndex:1];
    
            NSString* topic_title = [myTopic.topic_title stringByReplacingOccurrencesOfString:@">" withString:@""];
            
            topic_title = [topic_title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }

    }
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

-(void)setPortraitView
{
    
    // declare main view!
    portraitView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    
    // get screen dimensions
    screenHeight = portraitView.frame.size.height;
    
    screenWidth = portraitView.frame.size.width;
    
    // set main view's background color
    portraitView.backgroundColor = [UIColor whiteColor];
    
    [self portraitButtons];
    
}
-(void)setLandscapeView
{
    // declare main view!
    landscapeView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    
    // get screen dimensions
    screenHeight = landscapeView.frame.size.width;
    
    screenWidth = landscapeView.frame.size.height;
    
    // set main view's background color
    landscapeView.backgroundColor = [UIColor whiteColor];
    
    [self landscapeButtons];
    
}

- (void) portraitButtons
{
    
    float dimConst = 0.5;
    
    float myDim = dim*dimConst;
    
    // define columns
    
    int leftCol = screenWidth*0.25-myDim;
    
    int rightCol = screenWidth*0.75-myDim;
    
    // define rows
    
    /* 0.13, 0.42, 0.71*/
    float mul=0.26;
    
    int firstRow = screenHeight*mul-myDim;
    
    int secRow = screenHeight*(mul+0.29)-myDim;
    
    int thirdRow = screenHeight*(mul+0.58)-myDim;
    
    // set vertical positions for portrait orientation
    
    
    for (int j = 0; j < 6; j++)
    {
        if (j < 2)
            portrait_vertPos[j] = firstRow;
        else if (j < 4)
            portrait_vertPos[j] = secRow;
        else
            portrait_vertPos[j] = thirdRow;
        
    }
    
    // set horiz positions for portrait orientation
    for (int k = 0; k < 6; k++)
    {
        if (k%2==0)
            portrait_horizPos[k] = leftCol;
        else if (k%2==1)
            portrait_horizPos[k] = rightCol;
    }

    // loop through images
    for (int i = 0; i < 6; i++)
    {
        
        NSString* myImage = images[i];
        
        int myY = portrait_vertPos[i];
        
        int myX  = portrait_horizPos[i];
        
        int textWidth = [self convertWidth:i];
        
        // set labels
        int textX = [self convertX:myX andWidth:textWidth];
        
        int textY = [self convertY:myY];
        
        // add button label
        [self addButtonLabel: (int) textX
                        andY: (int) textY
                    andWidth: (int) textWidth
                  withString: (NSString*) labels[i]
                    withView: portraitView];
        // add button
        
        [self addButton:(int)myX
                   andY:(int)myY
              withImage:(NSString*)myImage
                  myTag:(int)i
               withView:(UIView*)portraitView];
    }
}

/*
 *  Landscape
 */

- (void) landscapeButtons
{
    float dimConst = 0.5;
    
    float myDim = dim*dimConst;
    
    // define columns
    
    int leftCol = screenWidth*0.20-myDim;
    
    int rightCol = screenWidth*0.80-myDim;
    
    int midCol = screenWidth*0.5 - myDim;
    
    
    
    
    // define rows
    
    float mul=0.33;
    
    int firstRow = screenHeight*mul-myDim;
    
    int secRow = screenHeight*(mul+0.43)-myDim;
    
    
    
    // set vertical positions for portrait orientation
    
    
    for (int j = 0; j < 6; j++)
    {
        if (j < 3)
        {
            landscape_vertPos[j] = firstRow;
        }
        else
        {
            landscape_vertPos[j] = secRow;
        }
        
    }
    
    // set horiz positions for portrait orientation
    for (int k = 0; k < 6; k++)
    {
        
        if (k%3 == 0)
            landscape_horizPos[k] = leftCol;
        else if (k%3 == 1)
            landscape_horizPos[k] = midCol;
        else if (k%3 == 2)
            landscape_horizPos[k] = rightCol;
        
    }
    
    
    
    
    // loop through images
    for (int i = 0; i < 6; i++)
    {
        
        NSString* myImage = images[i];
        
        int myY = landscape_vertPos[i];
        
        int myX  = landscape_horizPos[i];
        
        // labels
        
        int textWidth = [self convertWidth:i];
        
        int textX = [self convertX:myX andWidth:textWidth];
        
        int textY = [self convertY:myY];
        
    

        
        
        [self addButtonLabel: (int) textX
                        andY: (int) textY
                    andWidth: (int) textWidth
                  withString: (NSString*) labels[i]
                    withView:(UIView*)landscapeView];
        // set buttons
        
        int newTag = i+6;
        [self addButton:(int)myX
                   andY:(int)myY
              withImage:(NSString*)myImage
                  myTag:(int)newTag
               withView:(UIView*)landscapeView];
    }
}

-(int) convertX:(int) input andWidth: (int) textWidth
{
    int output = input + 37 - textWidth/2;
    
    return output;
}
-(int) convertY:(int) input
{
    int output = input + dim - 5;
    
    return output;
}
-(int) convertWidth:(int)index
{
    int mainWidth = dim + 40;
    
    int smallWidth = dim + 20;
    

    int output = (index > 0) ? mainWidth : smallWidth;
    
    return output;
}
/*
 *  Add button labels
 */

-(void) addButtonLabel: (int) myX
                  andY: (int) myY
              andWidth: (int) myWidth
            withString: (NSString*) myLabel
              withView:(UIView*)myView
{
    
    int myHeight = 60;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(myX,myY,myWidth,myHeight)];
    
    label.lineBreakMode = NSLineBreakByWordWrapping;
    
    label.numberOfLines = 0;
    
    label.backgroundColor = [UIColor clearColor];
    
    label.text = myLabel;
    
    label.textColor = [UIColor colorWithRed:0x48/255.0f green:0x68/255.0f blue:0x9d/255.0f alpha:1];
    
    [label setFont:[UIFont fontWithName:@"Arial-BoldMT" size:16]];
    
    label.textAlignment = NSTextAlignmentCenter;
    
    [myView addSubview:label];
    
}

/*
 *  Add buttons
 */

-(void)addButton: (int) myX
            andY: (int) myY
       withImage:(NSString*) myImage
           myTag:(int)index
        withView:(UIView*)myView
{
    UIButton* myButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [myButton setBackgroundImage:[UIImage imageNamed:myImage] forState:UIControlStateNormal];
    
    // set button location & dimensions
    CGRect frame = CGRectMake(myX, myY, dim, dim);
    
    myButton.frame = frame;
    
    myButton.tag = index;
    
    [myView addSubview:myButton];
    
    [myButton addTarget:self action:@selector(switchScreen:)
       forControlEvents:UIControlEventTouchUpInside];
}

-(void) land
{
    
    if (landscapeView.backgroundColor != [UIColor whiteColor])
    {
        [self setLandscapeView];
    }
    self.view = landscapeView;

}

-(void) port
{
    if (portraitView.backgroundColor != [UIColor whiteColor])
    {
        [self setPortraitView];
    }
    self.view = portraitView;
}
- (void)orientationChanged:(NSNotification*)object
{
    UIDeviceOrientation deviceOrientation = [[object object] orientation];
    
    if (deviceOrientation == UIInterfaceOrientationLandscapeLeft || deviceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        [self land];
    }
    else if (deviceOrientation == UIInterfaceOrientationPortrait || deviceOrientation ==  UIInterfaceOrientationPortraitUpsideDown)
    {
        [self port];
        
    }
    
}


/*
 *  Screen switching
 */

-(void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    
    
     Section* aSection = [appDelegate.sections objectAtIndex:destination];
    
    
    
    if (destination > 0)
    {
        SecScreen *controller = (SecScreen*)segue.destinationViewController;
        
        controller.type = destination;
        
        controller.listArray = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < aSection.topics.count; i++)
        {
            // get current topic from array.
            Topic* myTopic = [aSection.topics objectAtIndex:i];
            
            // trim out white space and extra characters.
            NSString* topic_title = myTopic.topic_title; 
            
            
            // add this to next VC's list array.
            [controller.listArray addObject:topic_title];
            
        }
        
     
            controller.title = aSection.screen_title;
        
        
    }
    else
    {
        AboutScreen *controller = (AboutScreen*)segue.destinationViewController;
        
        controller.title = @"Health Moments";
    }
}


// use prepareForSegue to pass information
-(void)switchScreen: (id) sender
{
    destination = [sender tag]%6;
    
    if (destination > 0)
        [self performSegueWithIdentifier:@"HomeToSec" sender:self];
    else
        [self performSegueWithIdentifier:@"HomeToAbout" sender: self];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
