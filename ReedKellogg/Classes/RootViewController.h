//
//  RootViewController.h
//  NavigationTest
//
//  Created by Stephen Mayhew on 1/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericTableView.h"
#import "PasswordEntryDelegate.h"

@class addNameViewController;
@class PasswordEntryModalViewController;

@interface RootViewController : GenericTableView <PasswordEntryDelegate> {

	
	//NSMutableArray *studentArray;
	//NSManagedObjectContext *managedObjectContext;

	//addNameViewController *nameViewController;
	//UIPopoverController *namePopover;

	PasswordEntryModalViewController * passwordEntryModal;
}

- (BOOL) verifyPassword:(NSString *)password;
- (void) promptForPassword:(id) sender;

//@property (nonatomic, retain) NSMutableArray *studentArray;
//@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) UIBarButtonItem *teacherLoginButton;

@property (nonatomic, retain) PasswordEntryModalViewController * passwordEntryModal;

@property (nonatomic, retain) UIBarButtonItem *teacherLogoutButton;
@property (nonatomic, retain) UIBarButtonItem *doneButton;
//@property (nonatomic, retain) UIBarButtonItem *addButton;
//@property (nonatomic, retain) addNameViewController *nameViewController;
//@property (nonatomic, retain) UIPopoverController *namePopover;

@end
