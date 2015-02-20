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

@synthesize landscapeView;

@synthesize portraitView;

@synthesize screenWidth;

@synthesize screenHeight;

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
    }

}


-(void)port
{
    if (portraitView.backgroundColor !=[UIColor whiteColor])
    {
        portraitView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
        [self setPortView];
    }
       self.view = portraitView;

}

-(void)land
{
    if (landscapeView.backgroundColor != [UIColor whiteColor])
    {
        landscapeView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
        [self setLandView];
    }
     self.view = landscapeView;
}

-(void) setPortView {

    
      screenHeight = portraitView.frame.size.height;
    
      screenWidth = portraitView.frame.size.width;
    
    portraitView.backgroundColor = [UIColor whiteColor];
    
    [self portraitElements];

}

-(void)setLandView {
    
    screenHeight = landscapeView.frame.size.width;
    
    screenWidth = landscapeView.frame.size.height;
    
    landscapeView.backgroundColor = [UIColor whiteColor];
    
    [self landscapeElements];
    
}

-(void) portraitElements
{
    /*
     *  title
     */
    int titleWidth = screenWidth;
    
    int titleHeight = 40;
    
    int titleX = 0;
    
    int titleY = 10;
    
    int titleCoords[4] = {titleX,titleY,titleWidth,titleHeight};
    
    /*
     *  body
     */
    
    int margin = 10;
    
    int bodyWidth = screenWidth - 2*margin;
    
    int bodyHeight = screenHeight - titleHeight - margin;
    
    int bodyY = titleHeight + margin*2;
    
    int bodyX = (screenWidth - bodyWidth)/2;
    
    
    /*
     * button
     */
    
    int btnWidth = 90;
    
    int btnHeight = 38;
    
    int btnX = (screenWidth - btnWidth)/2;
    
    int btnY = 320;
    
    /*
     *  coords
     */
    
    int bodyCoords[4] = {bodyX,bodyY,bodyWidth,bodyHeight};
    
    int btnCoords[4] = {btnX,btnY,btnWidth,btnHeight};
    
    [self addTitle:titleCoords andView:portraitView];
    
    [self addBody:bodyCoords andView:portraitView];
    
    [self addButton:btnCoords withTag:10 withView:portraitView];
}


-(void)landscapeElements {
    
    
    int titleWidth = screenWidth;
    
    int titleHeight = 40;
    
    int titleX = 0;
    
    int titleY = 10;
    
    /*
     *  body
     */
    
    int margin = 10;
    
    int bodyWidth = screenWidth - 2*margin;
    
    int bodyHeight = screenHeight - titleHeight - margin;
    
    int bodyY = titleHeight + margin*2;
    
    int bodyX = (screenWidth - bodyWidth)/2;
    
    /*
     * button
     */
    
    int btnWidth = 90;
    
    int btnHeight = 38;
    
    int btnX = (screenWidth - btnWidth)/2;
    
    int btnY = 200;
    
    /*
     *  coords
     */
    
    int myCoords[4] = {titleX,titleY,titleWidth,titleHeight};
    
    int bodyCoords[4] = {bodyX,bodyY,bodyWidth,bodyHeight};
    
    int btnCoords[4] = {btnX,btnY,btnWidth,btnHeight};
    
    /*
     * calls
     */
    
    [self addTitle:myCoords andView:landscapeView];
    
    [self addBody:bodyCoords andView:landscapeView];
    
    [self addButton:btnCoords withTag:10 withView:landscapeView];
    
}
-(void)addButton: (int*) coords
         withTag: (int)index
        withView: (UIView*)myView
{
    UIButton* myButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
;
    
    // set button location & dimensions
    CGRect frame = CGRectMake(coords[0],coords[1],coords[2],coords[3]);
    
    myButton.frame = frame;
    
    myButton.tag = index;
    
    [myButton setTitle:@"Email Us" forState:UIControlStateNormal];
    
    [myView addSubview:myButton];
    
    [myButton addTarget:self action:@selector(actionEmailComposer:)
       forControlEvents:UIControlEventTouchUpInside];
}
-(void)addTitle: (int*) coords andView: (UIView*)view
{
    NSString* str = [NSString stringWithFormat:@"Send us Your Feedback!"];
    
    UIFont* titleFont = [UIFont fontWithName:@"Arial-BoldMT" size:20];
    
    UILabel* myLabel = [[UILabel alloc] initWithFrame:CGRectMake(coords[0],coords[1],coords[2],coords[3]) ];
    
    
   
    myLabel.text= str;
    
    myLabel.textAlignment = NSTextAlignmentCenter;
    
    [myLabel setFont:titleFont];
    
    [view addSubview:myLabel];
    
}

-(void)addBody:(int*)coords andView: (UIView*)view
{
    NSString* str = [NSString stringWithFormat:@"We're very interested to hear what you think of the app!  You can reach us at <...> To send us an email, click the button below."];
    
    UIFont* textFont = [UIFont fontWithName:@"Arial" size: 16];
    
    UITextView* myText = [[UITextView alloc] initWithFrame:CGRectMake(coords[0],coords[1],coords[2],coords[3])];
    
    myText.text = str;
    
    myText.editable = NO;
    
    myText.textAlignment = NSTextAlignmentLeft;
    
    [myText setFont:textFont];
    
    [view addSubview:myText];
}

- (BOOL)shouldAutoRotate {
    return YES;
}
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (IBAction)actionEmailComposer:(id)sender {

    
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





-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

/*
 * Orientation
 */
- (void)orientationChanged:(NSNotification*)object
{
    UIDeviceOrientation deviceOrientation = [[object object] orientation];
    
    if (deviceOrientation == UIInterfaceOrientationLandscapeLeft || deviceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        [self land];
    }
    else
    {
        [self port];

    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
