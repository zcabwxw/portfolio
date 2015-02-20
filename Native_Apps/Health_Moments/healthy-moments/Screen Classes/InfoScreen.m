//
//  InfoScreen.m
//  healthy-moments
//
//  Created by Katz, Nevin on 9/5/13.
//  Copyright (c) 2013 Katz, Nevin. All rights reserved.
//

#import "InfoScreen.h"

@interface InfoScreen ()

@end

@implementation InfoScreen

@synthesize mainView;

@synthesize section;

@synthesize topic;

@synthesize subtopic;

@synthesize infoList;

@synthesize infoType;

@synthesize screenWidth;

@synthesize screenHeight;

@synthesize myLabel;


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
	// Do any additional setup after loading the view.
    
    // get screen dimension

    
    mainView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    
    mainView.backgroundColor = [UIColor whiteColor];
    
    mainView.bouncesZoom = YES;
    
    mainView.delaysContentTouches = NO;
    
  
    
    // assign main view to self view
    self.view = mainView;
    
    screenHeight = mainView.frame.size.height;
    
    screenWidth = mainView.frame.size.width;
    
    [self addText];

}
-(void)addText
{
     int margin = 10;
    
    UIFont* textFont = [UIFont fontWithName:@"Arial" size:16];
    
    UIFont* titleFont = [UIFont fontWithName:@"Arial-BoldMT" size:16];
    
    NSString* bgTitle = @"Background";
    
    // initialize string for main text
    
    NSString* str = @"";
    
    // concatenate list items from background section
    for (int i = 0; i < infoList.count; i++)
    {
        
        str = [NSString stringWithFormat:@"%@\r\r%@",str, [infoList objectAtIndex:i]];
    }
    
    CGSize textviewSize = [str sizeWithFont:textFont constrainedToSize:CGSizeMake(screenWidth-2*margin, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
   
    int displayHeight = textviewSize.height + 10*infoList.count;
    
    int myX = 0;
    int myY = 0;
 
    
    
    
    UITextView *myText = [[UITextView alloc] initWithFrame:CGRectMake(myX,myY,textviewSize.width,displayHeight)];
    
    myLabel = [[UITextView alloc] initWithFrame:CGRectMake(0, 10, screenWidth,displayHeight)];

    myText.text = str;
    
    myLabel.text = bgTitle;

    [myLabel setScrollEnabled:YES];

        // color 
        myText.textColor = [UIColor blackColor];
    
        myLabel.textColor = [UIColor blackColor];
    
    myLabel.backgroundColor = [UIColor clearColor];
    
    myText.backgroundColor = [UIColor clearColor];
    
        [myText setFont:textFont];
    
        [myLabel setFont:titleFont];
    
        myText.textAlignment = NSTextAlignmentLeft;
    
    myLabel.textAlignment = NSTextAlignmentCenter;
    
    
      // [myLabel sizeToFit];
    
     CGSize containerSize = CGSizeMake(screenWidth, displayHeight);
    
    UIView* myContainer = [[UIView alloc] initWithFrame: (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=
        containerSize}];
    
    [mainView addSubview:myContainer];
    
  
    
    [myContainer addSubview:myText];
    
   [myContainer addSubview:myLabel];
    
    mainView.contentSize = containerSize;

    

   
    
    
        
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
