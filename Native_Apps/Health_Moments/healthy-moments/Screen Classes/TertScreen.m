//
//  TertScreen.m
//  healthy-moments
//
//  Created by Katz, Nevin on 9/5/13.
//  Copyright (c) 2013 Katz, Nevin. All rights reserved.
//

#import "TertScreen.h"

#import "WebSlinger.h"

#import "SubTopic.h"

#import "VideoPlayer.h"

#import "VideoList.h"

#import "VideoNode.h"

#import "SimBrowser.h"

@interface TertScreen ()

@end

@implementation TertScreen

@synthesize listArray;

@synthesize pageArray;

@synthesize type;

@synthesize subType;

@synthesize destination;

@synthesize requests;

@synthesize webviews;

@synthesize subtopics;


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
    
    
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    
    [self setBackButtons];
    
    [self viewWillAppear: YES];
    // capture touch gestures
    // UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTableView:)];
    // [self.tableView addGestureRecognizer:tap];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UITableViewCellSeparatorStyle separatorStyle = self.tableView.separatorStyle;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorStyle = separatorStyle;
}
-(void) setBackButtons
{
    NSString* myBtn;
    
    switch (self.subType)
    {
        case 0:
            myBtn = @"Background";
            break;
        case 1:
           
            myBtn = @"Handwashing";
            break;
        case 2:
            
            myBtn = @"Washing";
            break;
        case 3:
            myBtn = @"Covering";
            break;
    }
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:myBtn
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:nil
                                                                            action:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    return listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    
    // set cell text
    cell.textLabel.text = [listArray objectAtIndex:indexPath.row];
    
    return cell;
    
}



-(void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    
    
    NSInteger pageNumber = destination+1;
    
    NSUInteger pageCount = subtopics.count;
    
    NSString* stringTitle = [NSString stringWithFormat:@"%lu of %lu",(unsigned long)pageNumber,(unsigned long)pageCount];
    
    
    
    aSubTopic = [subtopics objectAtIndex:destination];
    
    switch (aSubTopic.type)
    {
        case 0:
        {
            WebSlinger *controller = (WebSlinger*)segue.destinationViewController;
            controller.webView = aSubTopic.webView;
            controller.title = stringTitle;
        }
            
            break;
        case 2:
        {
            WebSlinger *controller = (WebSlinger*)segue.destinationViewController;
            controller.webView = aSubTopic.webView;
            //controller.req = aSubTopic.req;
            controller.title = stringTitle;
        }
            break;
        case 1:
        {
            switch (aSubTopic.videos.count)
            {
                case 1:
                {
                    VideoPlayer* controller = (VideoPlayer*)segue.destinationViewController;
                    
                    VideoNode* node = [aSubTopic.videos objectAtIndex:0];
                    
                    controller.description = node.description;
                    
                    controller.myTitle = node.title;
                    
                    controller.videoPath = node.path;
                    
                    controller.thumbnail = node.thumbnail;
                    
                    controller.title = stringTitle;
                    
                    
                }
                    break;
                    
                default:
                {
                    VideoList* controller = (VideoList*)segue.destinationViewController;
                    
                    NSUInteger max = aSubTopic.videos.count;
                    
                    // populate controller list with videos
                    for (int e = 0; e < max; e++)
                    {
                        VideoNode* myNode = [aSubTopic.videos objectAtIndex:e];
                        
                        [controller.myVideos addObject:myNode];
                    }
                    controller.title = stringTitle;
                }
                    break;
            }
        }
            break;
            
    }
    
    
    
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath)
    { //we are in a tableview cell, let the gesture be handled by the view
        
        
        
        destination = indexPath.row;
        
        aSubTopic = [subtopics objectAtIndex:destination];
        
        switch (aSubTopic.type)
        {
            case 0:
                [self performSegueWithIdentifier:@"TertToInfo" sender:self];
                break;
                
                
            case 1:
                
                switch (aSubTopic.videos.count)
            {
                    
                case 1:
                    [self performSegueWithIdentifier:@"TertToVideo" sender:self];
                    break;
                    
                default:
                    
                    [self performSegueWithIdentifier:@"TertToList" sender:self];
                    break;
                    
            }
                break;
                
            case 2:
                [self performSegueWithIdentifier:@"TertToLinks" sender:self];
                break;
        }
        // go to next screen
        
    } else
    { // anywhere else, do what is needed for your case
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
