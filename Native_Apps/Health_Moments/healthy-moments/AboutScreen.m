//
//  AboutScreen.m
//  healthy-moments
//
//  Created by Katz, Nevin on 9/14/13.
//  Copyright (c) 2013 Katz, Nevin. All rights reserved.
//

#import "AboutScreen.h"

#import "WebSlinger.h"

#import "Section.h"

#import "Topic.h"

#import "Simbrowser.h"


#import "headstart_appAppDelegate.h"

@interface AboutScreen ()

@end

@implementation AboutScreen

@synthesize linkLoc, portLoc, landLoc;

@synthesize listArray;

@synthesize myCell;

@synthesize appDelegate;

@synthesize aSection;

@synthesize aboutHeight;

@synthesize landHeight;

@synthesize portHeight;

@synthesize contactCell;

@synthesize aboutCell;

@synthesize ackCell;

@synthesize aboutString;

@synthesize aboutWidth;

@synthesize type;

@synthesize frameY, landY, portY;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (headstart_appAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    
    // set grouped format
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    
    // orientation change logic
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:)name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    
    landLoc = CGPointMake(22,485);
    
    portLoc = CGPointMake(-24,700);
    
    landY = -40;
    
    portY = 55;
    
    landHeight = 480;
    
    portHeight = 700;
    
    aboutString = @"Healthy behaviors are one way to help children stay healthy so they can focus on learning. This app demonstrates that handwashing, covering your cough, and washing surfaces are three of the most important behaviors that can help families reduce the spread of illness. It includes scenarios that provide opportunities to discuss these behaviors with families.\r\rAs a home visitor, you have a unique opportunity to provide health information in ways that work for families. You know their individual needs and goals and can share easy-to-understand information. You can help families think through how to include healthy behaviors in their everyday lives. Even a few changes in daily routines can reduce illnesses. But, the first step is finding a good time to bring up these topics and knowing what to say.\r\rThis app was developed by Education Development Center, Inc. for the American Academy of Pediatrics and the Head Start National Center on Health. It was prepared under Grant #90HC0005 for the U.S. Department of Health and Human Services, Administration for Children and Families, Office of Head Start, by the National Center on Health.";
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        linkLoc = landLoc;
        frameY = landY;
        aboutHeight = landHeight;
        aboutWidth = self.view.frame.size.width*0.6;
    }
    else
    {
        linkLoc = portLoc;
        frameY = portY;
        aboutHeight = portHeight;
        aboutWidth = self.view.frame.size.width*0.9;
    }

    // capture section data
    
    aSection = [appDelegate.sections objectAtIndex:0];
    
    self.title = aSection.title;


    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;

 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSString* contact = @"Send Feedback";
    
    NSString* about = @"About this App";
    
    NSString* credit =  @"Acknowledgments";
    
    
    listArray = [[NSMutableArray alloc] initWithObjects:contact, about, credit, nil];
    
   // appDelegate = (headstart_appAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    
    // set grouped format
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    
    //[self.tableView setAutoresizingMask:UIViewContentModeScaleAspectFit];
    
    [self viewWillAppear: YES];

   
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UITableViewCellSeparatorStyle separatorStyle = self.tableView.separatorStyle;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorStyle = separatorStyle;
}

- (BOOL)shouldAutoRotate {
    return YES;
}
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (void)orientationChanged:(NSNotification*)object
{
    UIDeviceOrientation deviceOrientation = [[object object] orientation];
    
    if (deviceOrientation == UIInterfaceOrientationLandscapeLeft || deviceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        frameY = landY;
        aboutHeight = landHeight;
        
        linkLoc =  landLoc;
      
        [self reloadCell];
       
    }
    else if (deviceOrientation == UIInterfaceOrientationPortrait || deviceOrientation ==  UIInterfaceOrientationPortraitUpsideDown)
    {
        frameY = portY;
      
        aboutHeight = portHeight;
        
        linkLoc = portLoc;
       
        [self reloadCell];
      
        
    }
    
}

-(void)reloadCell
{

    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell; //= aboutCell; //[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    switch (indexPath.section)
    {
        case 0:
        cell = contactCell;
            break;
            
        case 1:
            cell = aboutCell;
            break;
            
        /*case 2:
            cell = ackCell;
            break;*/
    }
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }

    
    int margin=25;
  

    
    

    
    
    
    
    if (indexPath.section == 0 || indexPath.section == 2)
    {
       
        
     //  cell.backgroundColor = [UIColor lightTextColor];
        
        // set cell text
        cell.textLabel.text = [listArray objectAtIndex:indexPath.section];
        

        cell.textLabel.backgroundColor = [UIColor clearColor];
        
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
       
    }
    else if (indexPath.section == 1)
    {
        // cell.backgroundColor = [UIColor lightTextColor];
        
       UILabel* myLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,5,320,50)];
        
        myLabel.text = [listArray objectAtIndex:indexPath.section];
        
        myLabel.autoresizingMask  = UIViewAutoresizingFlexibleWidth;
        myLabel.backgroundColor = [UIColor clearColor];
        
        myLabel.textAlignment = NSTextAlignmentCenter;
        
        myLabel.font = [UIFont boldSystemFontOfSize:16];
        
        [cell addSubview:myLabel];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
        
        int myWidth = 280;
        
        UILabel* myText = [[UILabel alloc] initWithFrame:CGRectMake(margin, frameY, myWidth, aboutHeight)];

        
        
                   
        myText.autoresizingMask = UIViewAutoresizingFlexibleWidth; // | UIViewAutoresizingFlexibleHeight;
        
        
   
        myText.text = aboutString;
        
        myText.backgroundColor = [UIColor clearColor];
        
        UIFont* myFont = [UIFont fontWithName:@"Arial" size:16];
        
        [myText setFont:myFont];
        
              
        myText.textAlignment = NSTextAlignmentLeft;
        
        myText.numberOfLines = 0;
           
       
       
         
      
        [cell addSubview:myText];
        
        /*
         *  Footnote link
         */
        
       /* UIButton* textButton = [UIButton buttonWithType:UIButtonTypeCustom];
      
        [textButton setTitle:@"Handwashing: A family activity." forState:UIControlStateNormal];
        
        // -20, 683
        CGRect myFrame = CGRectMake(linkLoc.x,linkLoc.y,320,50);
        
        textButton.frame = myFrame;
        
                [textButton setTitleColor:[UIColor colorWithRed:0/255.0 green:66/255.0 blue:99/255.0 alpha:1] forState:UIControlStateNormal];
        
        textButton.titleLabel.font = myFont;
        
        textButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        
        [textButton addTarget:self action:@selector(visitRef:)
           forControlEvents:UIControlEventTouchUpInside];
        
        [cell addSubview:textButton];*/
        

         [myText sizeToFit];
        
        
        
      
    }
    
    return cell;
}
-(void) visitRef: (id) sender
{
    type = 1;
     [self performSegueWithIdentifier:@"LinksToBrowser" sender:self];
}
-(void)alertView:(UIAlertView*)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) [self actionEmailComposer];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
  
    CGFloat height = 45.0f;
    
  
    
    int selectedIndex = 1;
    
    return indexPath.section == selectedIndex ? aboutHeight : height;
}




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath)
    { //we are in a tableview cell, let the gesture be handled by the view
       // recognizer.cancelsTouchesInView = NO;
        
        
        
        
        if (indexPath.section == 0)
        {
             //[self actionEmailComposer];
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"The Head Start National Center on Health welcomes your comments about this app. Please email us by selecting the contact button to give us your feedback." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Contact",nil];
            
            [alert show];
        }
        else if (indexPath.section == 2)
        {
            type = 0;
            
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                                     style:UIBarButtonItemStyleBordered
                                                                                    target:nil
                                                                                    action:nil];
            
            [self performSegueWithIdentifier:@"AboutToAck" sender:self];
            
     

        }
        
        
    }
    else
    { // anywhere else, do what is needed for your case
        [self.navigationController popViewControllerAnimated:YES];
    }

    [tableView beginUpdates];
    [tableView endUpdates];
    
   
    
   
 
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

/*
 *
 */
- (void)actionEmailComposer {
    
    
    if ([MFMailComposeViewController canSendMail])
    {
        
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        
        mailViewController.mailComposeDelegate = self;
        
        [mailViewController setSubject:@"Feedback on Health Moments"];
        
        [mailViewController setMessageBody:@"Your message goes here." isHTML:NO];
        
     
        
        NSArray* myRecipients = [NSArray arrayWithObjects:@"nchinfo@aap.org", nil];
        
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



-(void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    if (type == 0)
    {
     Topic* aTopic = [aSection.topics objectAtIndex:0];
    
     WebSlinger *mycontroller = (WebSlinger*)segue.destinationViewController;
    
     mycontroller.type = 1;
    
     mycontroller.title = @"Acknowledgments";
    
     mycontroller.webView = aTopic.webView;
    }
    else if (type == 1)
    {
      
    SimBrowser* controller = (SimBrowser*)segue.destinationViewController;
      
    NSString* path = @"http://www.cdc.gov/healthywater/hygiene/hand/handwashing-family.html";
    NSURL* url = [NSURL URLWithString:path];
                
    NSURLRequest* myReq = [NSURLRequest requestWithURL:url];
                
    controller.req = myReq;
                      
            
    }
    
}


@end
