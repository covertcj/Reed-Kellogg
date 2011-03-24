//
//  CommentViewController.h
//  ReedKellogg
//
//  Created by Prodvend04 on 3/24/11.
//  Copyright 2011 RHIT. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CommentViewController : UIViewController {
	
	UIBarButtonItem *saveButton;
}

@property (nonatomic, retain) IBOutlet UIBarButtonItem *saveButton;
-(IBAction)savePressed:(id)sender;

@end
