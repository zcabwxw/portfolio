//
//  ContactScreen.m
//  healthy-moments
//
//  Created by Katz, Nevin on 9/13/13.
//  Copyright (c) 2013 Katz, Nevin. All rights reserved.
//

#import "ContactScreen.h"

@interface ContactScreen ()



@end

@implementation ContactScreen

@synthesize portraitView;

@synthesize landscapeView;

@synthesize screenWidth, screenHeight;
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
    [super viewDidLoad];
 /*
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:)name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    
    // get orientation
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
   
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        [self land];
       
    }
    else
    {
        [self port];
    }*/

}

-(void)port
{
    if (portraitView.backgroundColor !=[UIColor whiteColor])
    {
        [self setView:portraitView];
    }
 //   self.view = portraitView;
}

-(void)land
{
    if (landscapeView.backgroundColor != [UIColor whiteColor])
    {
        [self setView:landscapeView];
    }
   // self.view = landscapeView;
}


- (BOOL)shouldAutoRotate {
    return YES;
}
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}
-(void)setView:(UIView*)myView
{
    

    
    // get screen dimensions
    screenHeight = myView.frame.size.height;
    
    screenWidth = myView.frame.size.width;
    
    // set main view's background color
    myView.backgroundColor = [UIColor whiteColor];
    
    int view = (myView = portraitView) ? 0 : 1;
    
    switch (view)
    {
        case 0:
            [self portraitElements];
        break;
            
        case 1:
            [self landscapeElements];
        break;
    }
  
    
}
-(void) portraitElements
{
    int titleCoords[4] = {screenWidth/2,10,200,40};
    
    int bodyCoords[4] = {0,0,0,0};
    
    int btnCoords[4] = {0,0,0,0};
    
    [self addTitle:titleCoords andView:portraitView];
   
}
-(void) landscapeElements
{
    int titleCoords[4] = {screenWidth/2,10,200,40};
    
    int bodyCoords[4] = {0,0,0,0};
    
    int btnCoords[4] = {0,0,0,0};
    
    [self addTitle:titleCoords andView:landscapeView];
}
-(void)addTitle: (int*) coords andView: (UIView*)view
{
    NSString* str = [NSString stringWithFormat:@"Send us Your Feedback!"];
    
    UILabel* myLabel = [[UILabel alloc] initWithFrame:CGRectMake(coords[0],coords[1],coords[2],coords[3]) ];
    
    myLabel.text= str;
    
    [view addSubview:myLabel];
    
    
}

-(void) addButton: (int*) coords andView: (UIView*)view
{
    
}

-(void)addBodyText
{
    NSString* str = @"We would love to hear from you and what you think of the app!  To send us a message, click the button below.";
}

- (void)actionEmailComposer:(id)sender {

    
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        
        mailViewController.mailComposeDelegate = self;
        
        [mailViewController setSubject:@"Subject Goes Here."];
        
        [mailViewController setMessageBody:@"Your message goes here." isHTML:NO];
        
        
        NSArray* myRecipients = [NSArray arrayWithObjects:@"nevkatz@gmail.com",@"nkatz@edc.org", nil];
        [mailViewController setToRecipients:myRecipients];
        
        [self presentViewController:mailViewController animated:YES completion:nil];
        
    }
    else
    {
        NSLog(@"Device is unable to send email in its current state");
    }
}





- (void)orientationChanged:(NSNotification*)object
{
    UIDeviceOrientation deviceOrientation = [[object object] orientation];
    
    if (deviceOrientation == UIInterfaceOrientationLandscapeLeft || deviceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        [self port];
    }
    else
    {
      
        [self land];
        
    }
    
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
