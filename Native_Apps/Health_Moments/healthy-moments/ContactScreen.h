//
//  ContactScreen.h
//  healthy-moments
//
//  Created by Katz, Nevin on 9/13/13.
//  Copyright (c) 2013 Katz, Nevin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface ContactScreen : UIViewController
<MFMailComposeViewControllerDelegate>
{
    
    UIView* portraitView;
    
    UIView* landscapeView;
    
    int screenWidth, screenHeight;
}
-(IBAction)actionEmailComposer:(id)sender;

@property UIView* portraitView;

@property UIView* landscapeView;

@property int screenWidth, screenHeight;

@end
