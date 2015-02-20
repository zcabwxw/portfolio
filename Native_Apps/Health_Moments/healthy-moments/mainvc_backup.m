//
//  headstart_appViewController.m
//  healthy-moments
//
//  Created by Katz, Nevin on 9/4/13.
//  Copyright (c) 2013 Katz, Nevin. All rights reserved.
//

/*
 NEXT UP -- THURSDAY
 
1) Add orientation sensititivity to a) WebSlinger and b) VideoScreen.
 
2) Add list view for videos
 
3) Make links to back after they have been clicked...may require a special view for links.

 
4) Create view intro screen
        Add XML and XMLParser logic
        Change class to WebSlinger in storyboard
        In appVC, change the logic so you are setting the webview.
 
5) Add rest of content
 
6) Add sharper icon images.
 
7) Start Feedback form

8) Icon & Launch Screen

9) Extras: Add Images to pages
 
10) Distribution Certificate
 
 **FEEDBACK FORM (Wednesday, Thursday
 
 Do this after content is loaded and background is worked out.... prob. on Wednesday and Thursday.
 
 **FINE TUNING
 
 Make sharper images, app icon, launch screen
 
 Darken the background
 
 Add images to some pages.
 
 */

#import "headstart_appViewController.h"

#import "SecScreen.h"

#import "Section.h"

#import "headstart_appAppDelegate.h"


@interface headstart_appViewController ()

@end


/*
 NEXT UP
 
 Set up new .m & .h files for secondary screen that prints the screen type (Kitchen, etc.)
 
 Capture button identity using tags
 
 Add prepareForSegue listener
 
 Add menu background with options
 
 */





@implementation headstart_appViewController

@synthesize screenHeight;

@synthesize screenWidth;

@synthesize portraitView;

@synthesize landscapeView;

@synthesize destination;

@synthesize nextListArray;

@synthesize webview;

@synthesize btnWidth, btnHeight;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:nil
                                                                            action:nil];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:)name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    
    
    webview = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"family_handwashing_germs" ofType:@"html"]];
    
    
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    [webview loadRequest:req];
    
    
    
    
    NSURLRequest *req2 = [NSURLRequest requestWithURL:url];
    
    [webview loadRequest:req2];
    
	// Do any additional setup after loading the view, typically from a nib.
    
    appDelegate = (headstart_appAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    Section *aSection = [appDelegate.sections objectAtIndex:1];
    
    NSLog(@"WE FOUND THIS TITLE: %@", aSection.title);
    
    
    
    self.title = @"Healthy Moments";
    
    [self setGlobals];
    
    
    
    
    
    
}
- (BOOL)shouldAutoRotate {
    return YES;
}
-(void) setGlobals {
    btnWidth = 90;
    
    btnHeight = 76;
    
    infoDim = 30;
    
    images[0]=@"visit.png";
    
    images[1]=@"kitchen.png";
    
    images[2]=@"food.png";
    
    images[3]=@"toiletpaper.png";
    
    images[4]=@"cough.png";
    
    images[5]=@"info.png";
    
    [self setLabels];
}
-(void) setLabels
{
    for (int e = 0; e < appDelegate.sections.count; e++)
    {
        
        Section* aSection = [appDelegate.sections objectAtIndex:e];
        
        NSString* title = [aSection.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        Topic* myTopic = [aSection.topics objectAtIndex:1];
        
        
        
        NSString* topic_title = [myTopic.topic_title stringByReplacingOccurrencesOfString:@">" withString:@""];
        
        topic_title = [topic_title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        
        
        labels[e] = title;
    }
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}
-(void)setPortraitView
{
    NSLog(@"set portrait view");
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
    
    
    NSLog(@"portrait positions");
    // define columns
    
    int leftCol = screenWidth*0.25-btnWidth*0.5;
    
    int rightCol = screenWidth*0.75-btnWidth*0.5;
    
    int midCol = screenWidth*0.5 - btnWidth*0.5;
    
    int pCorner = screenWidth*0.89 - infoDim*0.5;
    
    
    
    // define rows
    
    int firstRow = screenHeight*0.14-btnHeight*0.5;
    
    int secRow = screenHeight*0.44-btnHeight*0.5;
    
    int thirdRow = screenHeight*0.72-btnHeight*0.5;
    
    int botRow = screenHeight*0.85-infoDim*0.5;
    
    
    // set vertical positions for portrait orientation
    
    
    for (int j = 0; j < 6; j++)
    {
        if (j < 2)
            portrait_vertPos[j] = firstRow;
        else if (j < 4)
            portrait_vertPos[j] = secRow;
        else if (j == 4)
            portrait_vertPos[j] = thirdRow;
        else
            portrait_vertPos[j] = botRow;
    }
    
    // set horiz positions for portrait orientation
    for (int k = 0; k < 6; k++)
    {
        if (k==5)
            portrait_horizPos[k] = pCorner;
        else if (k == 4)
            portrait_horizPos[k] = midCol;
        else if (k%2==0)
            portrait_horizPos[k] = leftCol;
        else if (k%2==1)
            portrait_horizPos[k] = rightCol;
    }
    
    
    
    
    // set images
    for (int i = 0; i < 6; i++)
    {
        
        NSString* myImage = images[i];
        
        int myY = portrait_vertPos[i];
        
        int myX  = portrait_horizPos[i];
        
        
        if (i < 5)
        {
            int textX = myX - 15;
            
            int textY = myY + btnHeight-5;
            
            int textWidth = btnWidth+30;
            
            
            [self addButtonLabel: (int) textX
                            andY: (int) textY
                        andWidth: (int) textWidth
                      withString: (NSString*) labels[i]
                        withView: portraitView];
        }
        
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
    // define columns
    
    int leftCol = screenWidth*0.20-btnWidth*0.5;
    
    int rightCol = screenWidth*0.80-btnWidth*0.5;
    
    int midCol = screenWidth*0.5 - btnWidth*0.5;
    
    int lCorner = screenWidth*0.9 - infoDim*0.5;
    
    
    
    // define rows
    
    int firstRow = screenHeight*0.17-btnHeight*0.5;
    
    int secRow = screenHeight*0.6-btnHeight*0.5;
    
    int botRow = screenHeight*0.8-infoDim*0.5;
    
    
    // set vertical positions for portrait orientation
    
    
    for (int j = 0; j < 6; j++)
    {
        if (j < 3)
        {
            landscape_vertPos[j] = firstRow;  
        }
        else if (j < 5)
        {
            landscape_vertPos[j] = secRow;
        }
        else
        {
            landscape_vertPos[j] = botRow;
        }
    }
    
    // set horiz positions for portrait orientation
    for (int k = 0; k < 6; k++)
    {

        if (k == 0 || k == 3)
            landscape_horizPos[k] = leftCol;
        else if (k == 1 || k == 4)
            landscape_horizPos[k] = midCol;
        else if (k == 2)
            landscape_horizPos[k] = rightCol;
        else if (k == 5)
            landscape_horizPos[k] = lCorner;
    }
    
    
    
    
    // set images
    for (int i = 0; i < 6; i++)
    {
        
        NSString* myImage = images[i];
        
        int myY = landscape_vertPos[i];
        
        int myX  = landscape_horizPos[i];
        
        // labels
        if (i < 5)
        {
            int textX = myX - 15;
            
            int textY = myY + btnHeight-5;
            
            int textWidth = btnWidth+30;
            
            
            [self addButtonLabel: (int) textX
                            andY: (int) textY
                        andWidth: (int) textWidth
                      withString: (NSString*) labels[i]
                        withView:(UIView*)landscapeView];
        }
        
        int newTag = i+6;
        [self addButton:(int)myX
                   andY:(int)myY
              withImage:(NSString*)myImage
                  myTag:(int)newTag
               withView:(UIView*)landscapeView];
    }
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
    
    
    
    int myWidth = (index%6 < 5) ? btnWidth : infoDim;
    
    int myHeight = (index%6 < 5) ? btnHeight: infoDim;
    
    CGRect frame = CGRectMake(myX, myY, myWidth, myHeight);
    
    
    
    myButton.frame = frame;
    
    myButton.tag = index;
    
    [myView addSubview:myButton];
    
    [myButton addTarget:self action:@selector(switchScreen:)
       forControlEvents:UIControlEventTouchUpInside];
}




- (void)orientationChanged:(NSNotification*)object
{
    
    UIDeviceOrientation deviceOrientation = [[object object] orientation];
    
    //if(deviceOrientation == UIInterfaceOrientationPortrait
   //    || deviceOrientation == UIInterfaceOrientationPortraitUpsideDown)

  if (deviceOrientation == UIInterfaceOrientationLandscapeLeft || deviceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        if (landscapeView.backgroundColor != [UIColor whiteColor])
        {
            [self setLandscapeView];
        }
        self.view = landscapeView;
    }
    else
    {
            if (portraitView.backgroundColor != [UIColor whiteColor])
            {
                [self setPortraitView];
            }
            self.view = portraitView;

    }
    
}
-(void)repositionButtons:(int*)horizArray andVert:(int*)vertArray
{
    for (int j = 0; j < 6; j++)
    {
        int myX = horizArray[j];
        
        int myY = vertArray[j];
        
        int myWidth = (j < 5) ? btnWidth : infoDim;
        
        int myHeight = (j < 5) ? btnHeight: infoDim;
        
        CGRect myFrame = CGRectMake(myX, myY, myWidth, myHeight);
        
        UIButton* Btn = (UIButton *)[self.view viewWithTag:j];
        
        Btn.frame = myFrame;
        
    }
}









/*
 *  Screen switching
 */

-(void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    
    
    
    
    if (destination < 5)
    {
        SecScreen *controller = (SecScreen*)segue.destinationViewController;
        
        NSLog(@"setting type");
        controller.type = destination;
        
        controller.listArray = [[NSMutableArray alloc] init];
        
        NSLog(@"setting section");
        Section* aSection = [appDelegate.sections objectAtIndex:destination];
        
        
        
        for (int i = 0; i < aSection.topics.count; i++)
        {
            // get current topic from array.
            Topic* myTopic = [aSection.topics objectAtIndex:i];
            
            // trim out white space and extra characters.
            NSString* topic_title = myTopic.topic_title; //[self refineString: (NSString*) myTopic.topic_title];
            
            
            // add this to next VC's list array.
            [controller.listArray addObject:topic_title];
            
        }
        
        
        
    }
}


// use prepareForSegue to pass information
-(void)switchScreen: (id) sender
{
    destination = [sender tag]%6;
    
    if (destination < 5)
        [self performSegueWithIdentifier:@"HomeToSec" sender:self];
    else
        [self performSegueWithIdentifier:@"HomeToInfo" sender: self];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
