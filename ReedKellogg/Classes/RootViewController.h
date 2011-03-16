//
//  RootViewController.h
//  NavigationTest
//
//  Created by Stephen Mayhew on 1/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericTableView.h"


@class addNameViewController;

@interface RootViewController : GenericTableView <UITextFieldDelegate, UIAlertViewDelegate> {

	
	//NSMutableArray *studentArray;
	//NSManagedObjectContext *managedObjectContext;

	//addNameViewController *nameViewController;
	//UIPopoverController *namePopover;

}

- (BOOL) verifyPassword:(NSString *)password;
- (void) promptForPassword;

//@property (nonatomic, retain) NSMutableArray *studentArray;
//@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) UIBarButtonItem *teacherLoginButton;
//@property (nonatomic, retain) UIBarButtonItem *addButton;
//@property (nonatomic, retain) addNameViewController *nameViewController;
//@property (nonatomic, retain) UIPopoverController *namePopover;

@end
