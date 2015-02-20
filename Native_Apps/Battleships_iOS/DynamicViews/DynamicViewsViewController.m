//
//  DynamicViewsViewController.m
//  DynamicViews
//
//  Created by nkatz on 3/20/13.
//  Copyright (c) 2013 nkatz. All rights reserved.
//

#import "DynamicViewsViewController.h"

#import "Tile.h"

#import "AudioToolbox/AudioToolbox.h"

#import "AVFoundation/AVFoundation.h"


@interface DynamicViewsViewController ()

@end

@implementation DynamicViewsViewController

@synthesize boardDim = _boardDim;

@synthesize enteredBoardNumber;

@synthesize Level = _Level;

@synthesize xmlParser = _xmlParser;

@synthesize getData;

@synthesize rowCounter;

@synthesize tileDim = _tileDim;

@synthesize isSomethingEnabled;

@synthesize gridView;

@synthesize mainView;

@synthesize shipTilesFound = _shipTilesFound;

@synthesize actualShipTiles = _actualShipTiles;

@synthesize boardPosY = _boardPosY;

@synthesize boardPosX = _boardPosX;

@synthesize time;

@synthesize player;

@synthesize screenWidth;

@synthesize screenHeight;


- (void)viewDidLoad
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    [self setGlobals];
    
    // add initial values to level
    [self initLevel];
    
    // add ship locations based on text file
    [self parseText];

    // for some reason we need this
    [super viewDidLoad];
 
	mainView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    
    self.view = mainView;
    
   
    screenHeight = mainView.frame.size.height;
    
    screenWidth = mainView.frame.size.width;
    
    _boardPosY = screenHeight*0.23;
    
     _boardPosX = 0;
    
    gridView = [self addGrid];
    
    // add background color
    mainView.backgroundColor = [UIColor whiteColor];
    
     // add status
    [self addText: mainView
            withX: 0
             andY: screenHeight*0.177
         andWidth: screenWidth
           andTag: 9000
          andText:@""
          aligned:NSTextAlignmentCenter];
    
    [self addText: mainView
            withX: 0
             andY: screenHeight*0.114
         andWidth: screenWidth
           andTag: 3000
          andText:@"Time Elapsed - 0:00"
          aligned:NSTextAlignmentCenter];
    
    // add the control buttons
    [self addToolbars];
    
    //[self addButtons];
    
    
    // add all the tiles to the gridView.
    [self populateMap: gridView];
    
    // add axes that hint to ship locations
    [self addAxes: gridView withY: _boardPosY];
    
    // start the timer
    [self startTimer];
    
  

}
- (BOOL)prefersStatusBarHidden
{
    return YES;
}
-(void) startTimer
{
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(displayTime:)
                                   userInfo:nil
                                    repeats:YES];
}
-(void) displayTime:(NSTimer*)timer;
{
    time++;
    
    NSString* baseTime = [self updateTime];
    
    NSString* timeString = [NSString stringWithFormat:@"Time Elapsed - %@", baseTime];
    
    UILabel* timeDisplay = (UILabel *)[mainView viewWithTag:3000];
    
    [timeDisplay setText:timeString];
    
     [self toSeconds: baseTime];
    
    //NSLog(@"time: %i",myTime);
    
    
}
-(NSString*) getBestTime
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* myTime = [defaults objectForKey:@"bestTime"];
    
    return myTime;
}
-(int) toSeconds:(NSString*) timeString;
{
    
    NSString* minuteString;
    NSString* secondString;
    
    // if minutes are less than 10 and string is 4 characters long (x:xx)
    if (timeString.length == 4)
    {
     
        minuteString = [timeString substringWithRange:NSMakeRange(0, 1)];
        secondString = [timeString substringWithRange:NSMakeRange(2,2)];
    }
    else
    {
        minuteString = [timeString substringWithRange:NSMakeRange(0,2)];
        minuteString = [timeString substringWithRange:NSMakeRange(3,2)];
    }
    
    // seconds without minutes
    int loneSeconds = [secondString intValue];
    
    
    int minutes = [minuteString intValue];
    
    int seconds = minutes*60 + loneSeconds;
    
    return seconds;
}
-(NSString*) updateTime
{
    
        
    int gameMin = floor(time  / 60);
        
    int gameSec = time % 60;
        
    NSString* secString;
    
    if (gameSec < 10)
        secString = [NSString stringWithFormat:@"0%i", gameSec];
    else
        secString = [NSString stringWithFormat:@"%i",gameSec];
    
   
    NSString* min_sec = [NSString stringWithFormat:@"%i:%@", gameMin, secString];
      
        
              
    return min_sec;
    
    
}

-(void) setGlobals
{
    _shipTilesFound = 0;
    
    _actualShipTiles = 0;
    
    getData = NO;
    
    rowCounter = 0;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) tileDim = 54;
    else tileDim = 27;
}

// initialize level by setting all values to zero
-(void) initLevel
{
    for (int i = 0; i < _boardDim; i++)
    {
        for (int j = 0; j < _boardDim; j++)
        {
            Level[i][j] = 1; // set default to water
            // //NSLog(@"%d",Level[i][j]);
        }
    }
}


-(UIView*) addGrid
{
 
    int dim = (_boardDim+1)*tileDim;
    
    int maxWidth;
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) maxWidth = screenWidth;
    
    else maxWidth = screenWidth*0.92;
    
    _boardPosX = (maxWidth- dim)/2;
    
    CGRect viewRect = CGRectMake(_boardPosX, _boardPosY, dim, dim);
    UIView* gridview = [[UIView alloc] initWithFrame:viewRect];
    
    [mainView addSubview: gridview];
    
    return gridview;
}

/*
 * Parsing Code Starts Here.
 */
-(void)parseText
{
    // go to the file
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"myLevels" withExtension:@"txt"];
    
    // get the data
   NSData* fileData = [[NSData alloc] initWithData:[NSData dataWithContentsOfURL:(url)]];

    // convert data to file contents
    NSString* fileContents = [[NSString alloc] initWithData:fileData
                                              encoding:NSUTF8StringEncoding] ;
    
    // break into individual levels
    NSArray *levels = [fileContents componentsSeparatedByString:@"Board"];
  
   
    
   
    NSLog(@"declare myLevel");
    
    // get the correct level
    NSArray *myLevel = [self getLevel:levels];
    
    NSLog(@"myLevel.count: %lu", myLevel.count);
    
    for (unsigned long i = 2, n=myLevel.count-1; i < n; i++)
    {
        NSArray* keyValuePair = [myLevel[i] componentsSeparatedByString:@":"];
        
        NSString* key = [keyValuePair objectAtIndex:0];

        NSString* value = [keyValuePair objectAtIndex:1];
        
        NSArray* myCoords = [value componentsSeparatedByString:@","];
        
        if ([key isEqualToString:@"hint"])
        {
            NSLog(@"hint");
            [self parseHint:myCoords];
        }
        else
        {
      
            // add in the number of ship tiles to the total number of tiles found.
            int shipTiles = [key intValue];
            
            NSLog(@"plot ship %i", shipTiles);
            _actualShipTiles += shipTiles;
            
            [self plotShip:myCoords];

        }
    }
    NSLog(@"done with loop");
 
}
-(void) parseHint: (NSArray*)myCoords
{
    NSLog(@"parseHint");
    int x1 = [myCoords[0] intValue]-1;
    
    int y1 = [myCoords[1] intValue]-1;
    
    // if this is a ship tile, let's declare that the tiles have been found.
    
    if (Level[y1][x1]==2) _shipTilesFound++;
    // change a 1 to a 3, and a 2 to a 4
    Level[y1][x1] +=2;
    
    // 3 = hint water
    // 4 = hint ship
}
-(void) plotShip:(NSArray*)myCoords
{
    int x1 = [myCoords[0] intValue]-1;
    
    int y1 = [myCoords[1] intValue]-1;
    
    int x2 = [myCoords[2] intValue]-1;
    
    int y2 = [myCoords[3] intValue]-1;
    
    // //NSLog(@"coords: %i,%i,%i,%i", x1,y1,x2,y2);
    
    
    
    if (x1 == x2 && y1==y2)
    {
        Level[y1][x1]=2;
    }
    else if (x1 == x2) // ship is vertical
    {
        for (int i = y1, n=y2+1; i < n; i++)
        {
            Level[i][x1] = 2;
        
        }
    }
    
    
    else if (y1 == y2) // ship is horizontal
    {
        
        for (int k = x1, n = x2+1; k < n; k++)
        {
            Level[y1][k]=2;
        }
        
    }
    
    // now, check for hints

}
// finds the correct level in the array. 
-(NSArray*)getLevel: (NSArray*)levels
{
    int counter = 0;
    
    // declare the level content array.
    NSArray* levelContent;
    
    for (int i = 1; i < levels.count; i++)
    {
        levelContent = [[levels objectAtIndex:i] componentsSeparatedByString:@"\n\n"];
        
        // get the board size of the level we aer examining.
        NSString* boardSize = [levelContent objectAtIndex:1];
        
        //change the board size to an integer value.
        int bSize = [boardSize intValue];
        
        // if we've reached the right board dimension, start counting levels.
        if (bSize == _boardDim) counter++;
        
        // if we've hit the right level, return the level content.
        if (counter == enteredBoardNumber)
            break;

    }
    return levelContent;
    
}
/*
-(void)parseXML
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"levels" withExtension:@"xml"];
    
    
    NSXMLParser *myParser = [[NSXMLParser alloc] initWithData:[NSData dataWithContentsOfURL:(url)]];
    
    [myParser setDelegate: self];
    
    [myParser parse];
}*/

-(void)parser:(NSXMLParser *)parser
        didStartElement:(NSString *)elementName
        namespaceURI:(NSString *)namespaceURI
        qualifiedName:(NSString *)qName
        attributes:(NSDictionary *)attributeDict
{
   
    
    if([elementName isEqualToString:@"row"])
    {
        getData = YES; // getData is a bool which is NO initialy
       
    }
    
}


-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    
    if(getData)
    {
   
        // // //NSLog(@" board dim: %i", _boardDim);
        // // //NSLog(@" data: %@",string);
        
        for (int i = 0; i < _boardDim; i++)
        {
            NSString* fragment = [string substringWithRange:NSMakeRange(i, 1)];
        
          //  // // //NSLog(@"fragment: %@", fragment);
            
            Level[rowCounter][i]= [fragment intValue]+1;
        }
        
        rowCounter++;
 
    }
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    
    if([elementName isEqualToString:@"row"]){
        getData = NO;
    }
}

/*
 *  These are functions that populate the game UI.
 */

-(void) addText: (UIView*) view
          withX:(int)x
           andY:(int)y
       andWidth:(int)width
         andTag:(int)Tag
        andText:(NSString*)text
        aligned:(NSTextAlignment)align


{
    int fontSize;
    
    CGRect frame = CGRectMake(x, y, width, 20);
    
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    
    label.textAlignment = align;
   
    label.backgroundColor = [UIColor clearColor];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        fontSize = 24;
    else
        fontSize = 18;
        
    label.font = [UIFont fontWithName:@"Verdana" size:fontSize];
    
    label.text=text;
    
 
    [self.view addSubview:label];
    
    label.tag = Tag;
    
    //NSLog(@"tag: %i", label.tag);
    

}
-(void) addAxes: (UIView*) view withY: (int) boardPosY
{
 
    // this will ultimately take data from the level array.
    
    int yAxisPos = _boardDim*tileDim;
    // vertical axis
    for (int i = 0; i < _boardDim; i++) // change max number to variable
    {
        int value = [self totalShips: i withDir: 0]; // 0 = vert is constant pos, get horiz [pos][k]
        
        int x;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) x = -15;
            else x = 2;
        
        int y = tileDim*i;
    
        [self addNumber:view withX: x andY: y andVal: value];
    }
    
    // horizontal axis
    for (int j = 0; j < _boardDim; j++)
    {
        int value = [self totalShips: j withDir: 1]; // 1 = get vert
        
        int x = 30 + tileDim*j;
        
        int y = yAxisPos;
        
        [self addNumber: view withX: x andY: y andVal: value];
    }


}
/*
 *  Finds the total number of hidden ships in the rows and columns.
 */
-(int) totalShips: (int) pos withDir: (int) dir
{
    int shipCounter = 0;
    
    for (int k = 0; k < _boardDim; k++)
    {
        int tileID;
        
        if (dir == 0) // adding a number on the vertical axis, so get ships in a horiz row
            tileID = Level[pos][k]; // the vertical position should stay fixed; iterate horizontally
        else
            tileID = Level[k][pos]; // the horizontal position is fixed; iterate vertically
        
        if (tileID == 2 || tileID == 4) shipCounter++; // 2 is a hidden ship, 4 is a hint ship
        
        
    }
    return shipCounter;
    
}
-(void) addNumber: (UIView*) view withX: (int) x andY: (int) y andVal: (int) value
{
    CGRect frame = CGRectMake(x, y, tileDim, tileDim);
    
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    
    label.textAlignment = NSTextAlignmentCenter;
    
    label.backgroundColor = [UIColor clearColor];
    
    label.font = [UIFont fontWithName:@"Verdana" size:15];
    
    [label setText: [NSString stringWithFormat: @"%i", value]];

    
    label.tag = 1000*x + y;
    
    [view addSubview:label];
}


-(void)addToolbars
{
    UIToolbar *top = [[UIToolbar alloc] init];
    
    UIToolbar *bot = [[UIToolbar alloc] init];
    
 
    int locY = screenHeight - 45;
    
    top.frame = CGRectMake(0,0, screenWidth, 45);
    bot.frame = CGRectMake(0,locY,screenWidth, 45);
    
    NSMutableArray *topItems = [[NSMutableArray alloc] initWithCapacity:2];
    NSMutableArray *botItems = [[NSMutableArray alloc] initWithCapacity:2];
    
    UIBarButtonItem *settingsBtn =[[UIBarButtonItem alloc] initWithTitle:@"Settings"
                                                                style:UIBarButtonItemStyleBordered
                                                               target:self
                                                               action: @selector(returnToSettings:)];
    
    UIBarButtonItem *quitBtn =[[UIBarButtonItem alloc] initWithTitle:@"Quit"
                                                                style:UIBarButtonItemStyleBordered
                                                               target:self
                                                               action: @selector(homeScreen:)];

    
    UIBarButtonItem *checkBtn =[[UIBarButtonItem alloc] initWithTitle:@"Check"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action: @selector(checkMap:)];
    
    UIBarButtonItem *clearBtn =[[UIBarButtonItem alloc] initWithTitle:@"Clear"
                                                                style:UIBarButtonItemStyleBordered
                                                              target:self
                                                              action: @selector(resetBoard:)];

 
    
    UIBarButtonItem *BtnSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    // top
    [topItems addObject:checkBtn];
    
    [topItems addObject:BtnSpace];
    
   // [topItems addObject:itemLabel];
    
   // [topItems addObject:BtnSpace];
    
    [topItems addObject:clearBtn];
    
    // bot
    
    [botItems addObject:settingsBtn];
    
    [botItems addObject:BtnSpace];
    
    [botItems addObject:quitBtn];
    
    [top setItems:topItems animated:NO];
    
    [bot setItems:botItems animated:NO];
    
    [mainView addSubview:top];
    
    [mainView addSubview:bot];
    
    
    
}

-(IBAction) homeScreen:(id) sender
{
   // [self dismissViewControllerAnimated:YES completion:nil];
    
     [self performSegueWithIdentifier:@"gameToHome" sender:self];
}

-(void)addButtons
{
    NSMutableArray* labels = [NSMutableArray arrayWithCapacity:3];
    
    
    [labels addObject:@"Check"];
    [labels addObject:@"Clear"];
  
    
    for (int i = 0; i < 2; i++)
    {
        int x = 10 + i*220;
        
        int y = 10;
        
        int myTag = (i+4)*1000;
        
        NSString *label = [labels objectAtIndex:i];
        
        //NSLog(@"%@", label);
        
        [self controlButton: mainView
                    withTag: myTag
                   withText: label
                      withX: x
                       andY: y];
    }
}
-(void)controlButton: (UIView*) view
             withTag: (int) myTag
            withText: (NSString*) myLabel
               withX: (int) x
                andY: (int) y
{
      CGRect frame =  CGRectMake(x, y, 75, 36);
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    button.frame = frame;
    
    [button setTitle:myLabel forState:UIControlStateNormal];
    
    button.backgroundColor = [UIColor clearColor];
    button.tag = myTag;
    
    switch(myTag)
    {
        case 4000:
            [button addTarget:self
                       action:@selector(checkMap:)
             forControlEvents:UIControlEventTouchUpInside];
            break;
            
        case 5000:
            [button addTarget:self
                       action:@selector(resetBoard:)
             forControlEvents:UIControlEventTouchUpInside];
            break;
            
       /* case 6000:
            [button addTarget:self
                       action:@selector(returnToSettings:)
             forControlEvents:UIControlEventTouchUpInside];
            break;*/
    }
    
    [view addSubview:button];

}

-(IBAction)returnToSettings:(id)sender
{
    //NSLog(@"quit!");
    //[self.navigationController popToRootViewControllerAnimated:YES];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}



// populates map with tiles
-(void) populateMap: (UIView*) gridview
{
  
    int axisSpace = 27;
    
    for (int row = 0; row < _boardDim; row++)
    {
        for (int col = 0; col < _boardDim; col++)
        {
            [self addTile: (gridview) withRow: (row) andCol:(col) andX: (axisSpace)];
        }
    }
    
    

    
}
// clears the X's from the board when you focus on a point. 
-(void) clearXs
{
    for (int row = 0; row < _boardDim; row++)
    {
        for (int col = 0; col < _boardDim; col++)
        {
            int myTag = [self coordToTag:(row) withCol:(col)];
            
            Tile* Btn = (Tile *)[self.view viewWithTag:myTag];
            
           
            [Btn setImage:[UIImage imageNamed:nil]forState:UIControlStateNormal];
           
        }
    }

}
-(void) refreshButtons
{
    for (int row = 0; row < _boardDim; row++)
    {
        for (int col = 0; col < _boardDim; col++)
        {
            int myTag = [self coordToTag:(row) withCol:(col)];
            
            Tile* Btn = (Tile *)[self.view viewWithTag:myTag];
            
            
            Btn.changed = NO;
        }
    }
}
-(IBAction) checkMap: (id) sender
{
    int errors = 0;
    for (int row = 0; row < _boardDim; row++)
    {
        for (int col = 0; col < _boardDim; col++)
        {
              int myTag = [self coordToTag:(row) withCol:(col)];
            
              Tile* Btn = (Tile *)[self.view viewWithTag:myTag];
            
            
              if (Btn.myType != Btn.trueType && Btn.myType != 0)
              {
                  errors++;
            
                  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                  {
                      if (Btn.tooClose == NO)
                          [Btn setImage:[UIImage imageNamed:@"error-54px.png"]forState:UIControlStateNormal];
                      else
                          [Btn setImage:[UIImage imageNamed:@"error-white-54px.png"]forState:UIControlStateNormal];
                  }
                  else
                  {
                      if (Btn.tooClose == NO)
                          [Btn setImage:[UIImage imageNamed:@"error.png"]forState:UIControlStateNormal];
                      else
                          [Btn setImage:[UIImage imageNamed:@"white_error.png"]forState:UIControlStateNormal];
                  }
               
              }
              else
              {
                  [Btn setImage:[UIImage imageNamed:nil]forState:UIControlStateNormal];
              }
         
        }
    }
    NSString* errorWord = @"errors";
    
    if (errors == 1) errorWord = @"error";
    
    //NSLog(@"You have %i %@.", errors, errorWord);
    
    NSString* message = [NSString stringWithFormat:@"You have %i %@.", errors, errorWord];
    
    [self printMessage: message];
}
-(void) printMessage: (NSString*) message
{
    UILabel* myTextBox = (UILabel *)[mainView viewWithTag:9000];
    
    
    myTextBox.text = message;
    
  
}
-(void) addTile:(UIView*) view
          withRow:(int) row
           andCol:(int) col
             andX:(int) axisSpace

{

    // dimensions - width and height (depends on screen ultimately)
    int dim = tileDim;
    
    
    int xPos = axisSpace + col*dim;
    
    int yPos = row*dim;
    
    CGRect frame = CGRectMake(xPos, yPos, dim, dim);
    
    // new button
    Tile *button = [Tile buttonWithType:UIButtonTypeCustom];
    
    // its starting type is an empty grid tile
    button.myType = 0;
    
    button.clicked = NO;
    
    // set frame equal to frame2
    button.frame = frame;
    
    // set background color for the button.
    button.backgroundColor = [UIColor colorWithRed:0.521569 green:0.768627 blue:0.254902 alpha:1];
    
    
    // set a unique tag; this should be with the loop. 
    button.tag = row*100 + col + 1;
    
    button.tooClose = NO;
    
    // default state is that this is not a hint.
   
 
    button.trueType = Level[row][col]; // this will be determined by an array
    
 
    CGPoint myPoint;
    
    myPoint.x = col; // this will be determined by the array
    myPoint.y = row;
    
 
    button.myLoc = myPoint;
    
    // check for whether button is a hint.
    if (button.trueType == 3) // water hint
    {
        button.trueType = 1;
        button.isHint = YES;
        button.myType = 1;
        button.hintImage = @"water.png";
        [button setBackgroundImage:[UIImage imageNamed:@"water.png"]
                          forState:UIControlStateNormal];
    }
    else if (button.trueType == 4) // ship hint
    {
        button.trueType = 2; // reset the button's true type so it corresponds to an actual ship.
        button.isHint = YES;
        
        button.hintImage = [self findHintShape:row withCol: col];
        
        NSString* hintImage = button.hintImage;
        
        // set the visible type to be 2.  important for setting other ships.
        button.myType = 2;
        
        [button setBackgroundImage:[UIImage imageNamed:hintImage]
                          forState:UIControlStateNormal];
    }
    else
    {
        button.isHint = NO;
        [button setBackgroundImage:[UIImage imageNamed:@"grid_tile.png"]
                          forState:UIControlStateNormal];
        
        [self addListeners:button];
    }
   
    
    
    

     
    [view addSubview:button];

}
-(NSString*) findHintShape:(int)row withCol:(int)col
{
    int nodeAbove = 1;
    int nodeBelow = 1;
    int nodeLeft = 1;
    int nodeRight = 1;
    
    //NSLog(@"nodebelow: %i", Level[row+1][col]);
                             
                             
    int maxIndex = _boardDim - 1;
    
    if (row > 0) nodeAbove = Level[row-1][col]; 
    
    if (row <  maxIndex) nodeBelow = Level[row+1][col];
    
    if (col > 0)  nodeLeft = Level[row][col-1];
    
    if (col <  maxIndex) nodeRight = Level[row][col+1];
    
    //NSLog(@"left: %i right: %i top: %i bot: %i", nodeLeft, nodeRight, nodeAbove, nodeBelow);
    // figure out surrounding tiles using modulos, since some could be 3 (hint water) or 4 (hint ship).
    // all water
    if (nodeAbove%2 == 1 && nodeBelow%2 == 1 && nodeLeft%2 == 1 && nodeRight%2 ==1 )
    {
        return @"lone_ship.png";
    }
    
    // ship left & ship right OR ship up & ship down
    else if ((nodeAbove%2 == 0 && nodeBelow%2 == 0) || (nodeLeft%2 == 0 && nodeRight%2 == 0))
    {
        return @"ship_mid.png";
    }
    else if (nodeAbove%2 == 0) return @"ship_bot.png";
    
    else if (nodeBelow%2 == 0) return @"ship_top.png";
    
    else if (nodeRight%2 == 0) return @"ship_left.png";
    
    else if (nodeLeft%2 == 0) return @"ship_right.png";
    
    return @"grey_ship.png";
}

        
    
    

-(void) addListeners:(UIButton*) button
{
    [button addTarget:self
               action:@selector(pushCheck:) // alt
     forControlEvents:UIControlEventTouchDown];
    
    [button addTarget:self
               action:@selector(refresh:) // alt
     forControlEvents:UIControlEventTouchUpInside];
    
    [button addTarget:self
               action:@selector(dragAround:withEvent:)
     forControlEvents:UIControlEventTouchDragInside];
    
    
   [button addTarget:self
               action:@selector(dragAround:withEvent:)
     forControlEvents:UIControlEventTouchDragEnter];
    
    [button addTarget:self
               action:@selector(refresh:)
     forControlEvents:UIControlEventTouchDragExit];
    
   [button addTarget:self
               action:@selector(dragAround:withEvent:)
     forControlEvents:UIControlEventTouchDragOutside];
}

-(IBAction) refresh: (id) sender
{
    [self clearXs];
    [self refreshButtons];
}
-(IBAction) dragAround: (id) sender withEvent: (UIEvent*) event
{
    UITouch *touch = [[event allTouches] anyObject];
    
    CGPoint touchPoint = [touch locationInView:self.view];
        
    int myTag = [self coordToTile:touchPoint.x andY: touchPoint.y];
    
    Tile *btn = (Tile *)[self.view viewWithTag:myTag];
    
    if (btn) if (!btn.changed && !btn.isHint)[self switchImage:btn];
}
-(IBAction)pushCheck: (id) sender
{
    NSInteger myTag = [sender tag];
    
    Tile *btn = (Tile *)[self.view viewWithTag:myTag];
    
    if (!btn.changed && !btn.isHint)[self switchImage:btn];
}
-(IBAction)becomeChangeable: (id) sender
{
    NSInteger myTag = [sender tag];
    
    Tile *btn = (Tile *)[self.view viewWithTag:myTag];
    
    if (btn) if (!btn.isHint)btn.changed = NO;
}
-(int) coordToTile: (int) x andY: (int) y
{
   
    int row = (int) (y-_boardPosY)/tileDim;
    
    int col = (int) (x-_boardPosX)/tileDim;
    
    int tag = row*100 + col;
    return tag;
}
-(IBAction) imageChange: (id) sender
{
    
    [self refreshButtons];
    
    [self printMessage:@""];

 
    [self clearXs];
    // get the tag from teh button that was clicked. 
    NSInteger myTag = [sender tag];
    
     // //NSLog(@"tag: %d", myTag);
    // create temp variable for the button
    Tile *btn = (Tile *)[self.view viewWithTag:myTag];
    
    [self switchImage: btn];
}
-(void)switchImage: (Tile*) btn;
{
    btn.changed = YES;
    
    btn.clicked = YES;
    // create variable for the type of button - what is the picture currently? 
    int Type = btn.myType;
    
    // // //NSLog(@"button change");
    // change the look of the button.
    switch (Type)
    {
        case 0: // to water
            [btn setBackgroundImage:[UIImage imageNamed:@"water.png"]
                           forState:UIControlStateNormal];
            
            btn.tooClose = NO;
            btn.myType = 1;
            
            // check for surrounding ship
            [self checkForShip: btn];
            
            //NSLog(@"found: %i actual: %i", _shipTilesFound, _actualShipTiles);
            if (_shipTilesFound == _actualShipTiles) [self declareWin];
            break;
            
        case 1: // to ship
            
            if (btn.trueType == 2) _shipTilesFound++;
            
            //NSLog(@"shipe tiles found: %i", _shipTilesFound);
            
            // in case we need to change a ship state - either back from red or give a specific shape. 
            [self shipType: btn];
            
            if (_shipTilesFound == _actualShipTiles) [self declareWin];
            
            
            break;
            
        case 2: // back to empty grid.
            
            // if this was a ship, you had found it and now you lost it. 
            if (btn.trueType == 2) _shipTilesFound--;
            
            [btn setBackgroundImage:[UIImage imageNamed:@"grid_tile.png"]
                           forState:UIControlStateNormal];
            
            btn.tooClose = NO;
            btn.myType = 0;
            
            // in case we need to change ships back from red
            [self checkForShip: btn];
            break;
            
    }
    

}
-(int)coordToTag: (int)row withCol: (int) col
{
    int myTag = row*100 + col + 1;
    return myTag;
}
-(void) checkForShip: (Tile*) btn
{
 
    // // //NSLog(@"check for ship");
    int lastTile = _boardDim - 1;
    int row = btn.myLoc.y;
    
    int col = btn.myLoc.x;
    
    // the default is that our tile is not at an extreme end of the board.
    bool farLeft = NO;
    bool farRight = NO;
    bool atTop = NO;
    bool atBot = NO;
    
    // check on whether current tile is on edge
    if (row <= 0)
    {
        // // //NSLog(@"at top");
        atTop = YES;
    }
    if (row == lastTile) atBot = YES;
    
    if (col <= 0)
    {
         // // //NSLog(@"far left");
        farLeft = YES;
    }
    if (col == lastTile) farRight = YES;
    
         // // //NSLog(@"declaring tags...");
    // establish tags for neighboring tiles
    
    int aboveTag = [self coordToTag:(row-1) withCol:(col)];
    
    int leftTag = [self coordToTag:(row) withCol:(col-1)];
    
    int rightTag = [self coordToTag:(row) withCol:(col+1)];
    
    int belowTag = [self coordToTag:(row+1) withCol:(col)];
    
    // up left
    int alTag = [self coordToTag:(row-1) withCol:(col-1)];
    
    int arTag = [self coordToTag:(row-1) withCol:(col+1)];
    
    int blTag = [self coordToTag:(row+1) withCol:(col-1)];
    
    int brTag = [self coordToTag:(row+1) withCol:(col+1)];
    
     // // //NSLog(@"declaring states...");
    
    // default state for neighboring tiles is 0.
    int aboveState = 0;
    int belowState = 0;
    int rightState = 0;
    int leftState = 0;
    
    int alState = 0;
    int arState = 0;
    int blState = 0;
    int brState = 0;
    
    Tile *aboveBtn;
    Tile *belowBtn;
    Tile *rightBtn;
    Tile *leftBtn;
    
    Tile *arBtn;
    Tile *alBtn;
    Tile *brBtn;
    Tile *blBtn;
    
    // implement diagonals and reds next.
    // // //NSLog(@"checking for edges...");
    
    // if neighboring tiles exist, find out their identity; otherwise, neighbor state remains at 0.
    if (!atTop)
    {
        aboveBtn = (Tile *)[self.view viewWithTag:aboveTag];
        aboveState = aboveBtn.myType;
    }
    if (!atBot)
    {
        belowBtn = (Tile*) [self.view viewWithTag:belowTag];
        belowState = belowBtn.myType;
    }
    if (!farRight)
    {
        rightBtn = (Tile*) [self.view viewWithTag:rightTag];
        rightState = rightBtn.myType;
    }
    if (!farLeft)
    {
        leftBtn = (Tile*) [self.view viewWithTag:leftTag];
        leftState = leftBtn.myType;
    }
    
    // // //NSLog(@"water setting diagonal states..");
    // get tags of diagonally neighboring tiles, if they exist; otherwise, use 0 as the default state
    if (!atTop && !farLeft)
    {
        alBtn = (Tile*)[self.view viewWithTag:alTag];
        alState = alBtn.myType;
    }
    if (!atTop && !farRight)
    {
        arBtn = (Tile*)[self.view viewWithTag:arTag];
        arState = arBtn.myType;
    }
    if (!atBot && !farLeft)
    {
        blBtn = (Tile*)[self.view viewWithTag:blTag];
        blState = blBtn.myType;
    }
    if (!atBot && !farRight)
    {
        brBtn = (Tile*)[self.view viewWithTag:brTag];
        brState = brBtn.myType;
    }
    
    
    // if a neighboring tile is a ship, check its shape and change if necessary.
    if (aboveState == 2)  [self shipType: aboveBtn];
    
    if (belowState == 2) [self shipType: belowBtn];
    
    if (rightState == 2) [self shipType: rightBtn];
    
    if (leftState == 2) [self shipType: leftBtn];
    
    // diagonals
    
    if (arState == 2) [self shipType: arBtn];
    
    if (brState == 2) [self shipType: brBtn];
    
    if (blState == 2) [self shipType: blBtn];
    
    if (alState == 2) [self shipType: alBtn];
    
    // check surrounding tiles - no need to go red, though.
    
    // if that tile is a ship, call shipType on it.
    
    btn.clicked = NO;
}

// NEXT UP:

// water logic

// add x overlays and red tiles

// save this version (because it could get HAIRY!) and then add red tiles

-(IBAction)resetBoard: (id) sender
{
    for (int row = 0; row < _boardDim; row++)
    {
        for (int col = 0; col < _boardDim; col++)
        {
            int myTag = [self coordToTag:row withCol:col];
            
          Tile* myTile = (Tile*) [self.view viewWithTag:myTag];
            
            myTile.myType = 0;
            
            if (!myTile.isHint)[self setButton:myTile withImage:@"grid_tile.png"];
            else
            {
                NSString* myImage = myTile.hintImage;
                [self setButton:myTile withImage:myImage];
            }
            
            _shipTilesFound = 0;
            
           
        }
    }
    [self clearXs];
    
    [self printMessage:@""];
    
    
    
    
}
-(void) saveData
{
 
    NSString* timeString = [self updateTime];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:timeString forKey:@"bestTime"];
    
    [defaults synchronize];
    //NSLog(@"Data saved.");
}
-(bool)declareWin
{
   
     for (int row = 0; row < _boardDim; row++)
    {
        for (int col = 0; col < _boardDim; col++)
        {
           
            int myTag = [self coordToTag:row withCol: col];
            
            Tile* myButton = (Tile*)[self.view viewWithTag: myTag];
            
            if ((myButton.trueType != myButton.myType) && myButton.myType !=0)
                
            return NO;
            
        }
    }
    
    [self checkTime];
    
    [self playSound];
    
    return YES;
}
-(void) checkTime
{
    NSString* bestTime = [self getBestTime];
    
    int bestTimeInt = [self toSeconds:bestTime];
    
  
    if (time < bestTimeInt)
    {
        [self saveData];
        [self printMessage:@"You win!  New Record!"];
    }
    else
        [self printMessage: @"You Win!"];
}
-(void)playSound
{
    NSString *soundFilePath = [NSString stringWithFormat:@"%@/victory_sound.mp3", [[NSBundle mainBundle] resourcePath]];
    
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
    
    
    [player play];
    
}
-(void)showError
{
    //NSLog(@"error");
}
-(void) shipType: (Tile*) btn
{
   
    // // //NSLog(@"starting...");
    btn.myType = 2;
    
    // last tile in row or column
    int lastTile = _boardDim - 1;
    // get tile above
    int row = btn.myLoc.y;
    
    int col = btn.myLoc.x;
    
    // the default is that our tile is not at an extreme end of the board.
    bool farLeft = NO;
    bool farRight = NO;
    bool atTop = NO;
    bool atBot = NO;
    
    
    
    // default state for neighboring tiles is 0.
    int aboveState = 0;
    int belowState = 0;
    int rightState = 0;
    int leftState = 0;
    
    
    // // //NSLog(@"setting diagonal variables..");
   // default states for diagonal tiles
    
    int alState = 0;
    int arState = 0;
    int blState = 0;
    int brState = 0;
    
    
    // check on whether current tile is on edge
    if (row <= 0)
    {
        atTop = YES;
        aboveState = 1;
    }
    if (row == lastTile)
    {
        atBot = YES;
        belowState = 1;
    }
    
    if (col <= 0)
    {
        farLeft = YES;
        leftState = 1;
    }
    if (col == lastTile)
    {
        farRight = YES;
        rightState = 1;
    }


    // establish tags for neighboring tiles
    
    // // //NSLog(@"setting tags...");

    int aboveTag = [self coordToTag:(row-1) withCol:(col)];
    
    int leftTag = [self coordToTag:(row) withCol:(col-1)];
    
    int rightTag = [self coordToTag:(row) withCol:(col+1)];
    
    int belowTag = [self coordToTag:(row+1) withCol:(col)];
    
    // diagonals
    int alTag = [self coordToTag:(row-1) withCol:(col-1)];
    
    int arTag = [self coordToTag:(row-1) withCol:(col+1)];
    
    int blTag = [self coordToTag:(row+1) withCol:(col-1)];
    
    int brTag = [self coordToTag:(row+1) withCol:(col+1)];
    
    // // //NSLog(@"declaring button variables...");
    Tile *aboveBtn;
    Tile *belowBtn;
    Tile *rightBtn;
    Tile *leftBtn;
    
    Tile *arBtn;
    Tile *alBtn;
    Tile *brBtn;
    Tile *blBtn;
    
    // // //NSLog(@"equating state variables to button states..");
    // get tags of diagonally neighboring tiles, if they exist; otherwise, use 0 as the default state
    if (!atTop && !farLeft)
    {
        // // //NSLog(@"checking up left");
        alBtn = (Tile*)[self.view viewWithTag:alTag];
        alState = alBtn.myType;
        
        
    }
    if (!atTop && !farRight)
    {
        arBtn = (Tile*)[self.view viewWithTag:arTag];
        arState = arBtn.myType;
        
           }
    if (!atBot && !farLeft)
    {
        blBtn = (Tile*)[self.view viewWithTag:blTag];
        blState = blBtn.myType;
        
        
    }
    if (!atBot && !farRight)
    {
        brBtn = (Tile*)[self.view viewWithTag:brTag];
        brState = brBtn.myType;
        
    
    }
    
 
    
    // if neighboring tiles exist, find out their identity; otherwise, neighbor state remains at 0.
    if (!atTop)
    {
         aboveBtn = (Tile *)[self.view viewWithTag:aboveTag];
         aboveState = aboveBtn.myType;
        
        
    }
    if (!atBot)
    {
        belowBtn = (Tile*) [self.view viewWithTag:belowTag];
        belowState = belowBtn.myType;
        
        
    }
    if (!farRight)
    {
        rightBtn = (Tile*) [self.view viewWithTag:rightTag];
        rightState = rightBtn.myType;
        
        
    }
    if (!farLeft)
    {
        leftBtn = (Tile*) [self.view viewWithTag:leftTag];
        leftState = leftBtn.myType;
        
      
    }
    

    
   
    // a diagonal tile is a ship, turn red and turn the neighboring tile red. 
   
  
    if (blState == 2 || arState == 2 || alState == 2 || brState == 2)
    {
        if (!btn.isHint)
            [self setButton: (Tile*) btn withImage: (@"red_box.png")];
        else
            [self setButton: (Tile*) btn withImage: btn.hintImage];
    
    if (alState == 2)
    {
        [self setButton: (Tile*) alBtn withImage: (@"red_box.png")];
    }
    if (arState == 2)
    {
        [self setButton: (Tile*) arBtn withImage: (@"red_box.png")];
    }
    if (blState == 2)
    {
        [self setButton: (Tile*) blBtn withImage: (@"red_box.png")];
    }
    if (brState == 2)
    {
        [self setButton: (Tile*) brBtn withImage: (@"red_box.png")];
    }
    
    }
    
    // this set of conditionals determines the shape of the tile if it is not red and not a hint iamge.
    
    // if surrounded by water. 
    else if (leftState == 1 && rightState == 1 && aboveState == 1 && belowState == 1)
    {
        [self setButton: (Tile*) btn withImage: (@"lone_ship.png")];
       
    }
    //  if (ship only below) ship top
    else if (leftState == 1 && rightState == 1 && aboveState == 1 && belowState ==2)
    {
        // change this ship
        [self setButton: (Tile*) btn withImage: (@"ship_top.png")];
        
        // change ship below
        if (btn.clicked)[self shipType: belowBtn];
    }
    
    // if (ship only on right) ship left
    else if (leftState == 1 && rightState == 2 && aboveState == 1 && belowState ==1)
    {
        // change this ship
        [self setButton: (Tile*) btn withImage: (@"ship_left.png")];
        
        // change ship on right
        if (btn.clicked)[self shipType: rightBtn];
    }
        
    // if (ship only on left) ship right
     else if (leftState == 2 && rightState == 1 && aboveState == 1 && belowState ==1)
     {
         // change this ship
         [self setButton: (Tile*) btn withImage:(@"ship_right.png")];
         
         // change ship on left
         if (btn.clicked) [self shipType: leftBtn];
     }

    // if (ship only above) ship bot
    else if (leftState == 1 && rightState == 1 && aboveState == 2 && belowState == 1)
    {
        [self setButton: (Tile*) btn withImage:(@"ship_bot.png")];
        
        // change button below
        if (btn.clicked)[self shipType: aboveBtn];
    }
    
    
    // if water left & right, ship above & below
    else if (leftState == 1 && rightState == 1 && aboveState == 2 && belowState ==2)
    {
        [self setButton: (Tile*) btn withImage: (@"ship_mid.png")];
        
        // no loops
        if (btn.clicked)
        {
            [self shipType: aboveBtn];
        
            [self shipType: belowBtn];
        }
    }
        
    // if ship left & right, water above & below
    else if (leftState == 2 && rightState == 2 && aboveState == 1 && belowState == 1)
    {
        [self setButton: (Tile*) btn withImage: (@"ship_mid.png")];
        
        // to prevent infinite loop, only change neighboring ships if this is the button that was clicked. 
        if (btn.clicked)
        {
            [self shipType: leftBtn];
        
            [self shipType: rightBtn];
        }
    }
        
        
        
    
    else
    {
        [self setButton: (Tile*) btn withImage: (@"ship_grey.png")];
        
        if (btn.clicked)
        {
            // if neighboring buttons are ships, we may need to change their state. 
            if (leftState == 2) [self shipType: leftBtn];
            
            if (rightState == 2) [self shipType: rightBtn];
            
            if (aboveState == 2) [self shipType: aboveBtn];
            
            if (belowState == 2) [self shipType: belowBtn];
           
        }
    }
    
    
    btn.clicked = NO;
}
-(void) setButton: (Tile*) btn withImage: (NSString*)image
{
    [btn setBackgroundImage:[UIImage imageNamed:image]
                   forState:UIControlStateNormal];
    
    // if button is too close
    if ([image  isEqual: @"red_box.png"]) btn.tooClose = YES; else btn.tooClose = NO;
}

-(IBAction) buttonClicked: (id) sender
{
    UIAlertView *alert =
    [[UIAlertView alloc]initWithTitle:@"Action invoked!"
                              message:@"Button clicked!"
                             delegate:self
                    cancelButtonTitle:@"OK"
                    otherButtonTitles:nil];
    
    [alert show];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

/*

 
1) Add reset button, add tabbed views, More Levels, Timer, Dimension settings, sound, save score
 
 ***
 
 ****
 Create a two dimensional array for a given level.
    -hard coded
    -then XML
    -or random
 It will be an array of zero's and ones
 ****
 
 ARRAYS
 
 trueTypes: store true identities of the obejcts in 2D arrays at the outset
 
 chosenTypes: chosen identities are in a 2D array, starting out with all zeroes
 
 these will be changed to water or ship as you go along.
 
 ****
 
 Create helper functions that find the values of the four neighboring tiles
 
 ***
 
 ***
 POSITION LOGIC
 
 if (just water above and below) neutral tile)
 
 if (water above, left, right && ship below) ship top
 
 if (ship above & below, water left & right) ship mid
 
 if (water above & below, ship left & right) ship mid
 
 if (water below, left, right, && ship above) ship bottom

 ***
 
 Load in a level
 
 Create resizeability - hence random generation
 
 Add button logic that determines how to create the ship. 
 
 FINISH ASSIGNMENT 2!!!!
 */
  