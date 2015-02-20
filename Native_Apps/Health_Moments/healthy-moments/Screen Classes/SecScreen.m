//
//  SecScreen.m
//  healthy-moments
//
//  Created by Katz, Nevin on 9/5/13.
//  Copyright (c) 2013 Katz, Nevin. All rights reserved.
//

#import "SecScreen.h"

#import "TertScreen.h"

#import "Section.h"

#import "Topic.h"

#import "SubTopic.h"

#import "headstart_appAppDelegate.h"

#import "WebSlinger.h"

@interface SecScreen ()

@end

@implementation SecScreen

@synthesize myList;

@synthesize type;

@synthesize listArray;

@synthesize destination;

@synthesize appDelegate;



@synthesize aSection;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
        // UITableView *myTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (headstart_appAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    
    // set grouped format
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    
    
    aSection = [appDelegate.sections objectAtIndex:type];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:aSection.back_title
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:nil
                                                                            action:nil];
    
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self viewWillAppear: YES];
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UITableViewCellSeparatorStyle separatorStyle = self.tableView.separatorStyle;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorStyle = separatorStyle;
}

-(void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    
    
    Topic* aTopic = [aSection.topics objectAtIndex:destination];
    
    
    if (destination == 0)
    {
        

        
        WebSlinger *mycontroller = (WebSlinger*)segue.destinationViewController;
        
        mycontroller.webView = aTopic.webView;
    }
    else
    {
        TertScreen *controller = (TertScreen*)segue.destinationViewController;
        
        controller.type = type;
        
        controller.subType = destination;
        
        
        controller.listArray = [[NSMutableArray alloc] init];
        
        controller.subtopics = [[NSMutableArray alloc] init];
        
        controller.title = aTopic.topic_title;
        
        
        for (int i = 0; i < aTopic.subtopics.count; i++)
        {
            
            // add subtopics to next VC.
            
            SubTopic* mySubTopic = [aTopic.subtopics objectAtIndex:i];
            
            [controller.subtopics addObject:mySubTopic];
            
            // add title to listArray.  these provide the titles that show up on the list.
            
            NSString* subtopic_title = mySubTopic.subtopic_title;
            
            [controller.listArray addObject:subtopic_title];
            
            // add title to pageArray.  these provide the links to the pages.
            
            //NSString* myPage = mySubTopic.page;
            
            
            //[controller.pageArray addObject:myPage];
            
        }
    }
    
    
}


/*
 *  Memory, TableView, etc.
 */
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
    
    
    
    return listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    //  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTableView:)];
    //  cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    //  tap.cancelsTouchesInView = NO;
    
    //  cell.userInteractionEnabled = YES;
    
    // cell.backgroundColor = [UIColor grayColor];
    
    // [self.tableView addGestureRecognizer:tap];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    
    // set cell text
    cell.textLabel.text = [listArray objectAtIndex:indexPath.row];
    
    
    return cell;
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
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        
        
        destination = indexPath.row;
        
        if (destination == 0)
        {
            [self performSegueWithIdentifier:@"SecToBg" sender:self];
        }
        else
        {
            [self performSegueWithIdentifier:@"SecToTert" sender:self];
        }
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
