//
//  PasswordEntryModalViewController.h
//  ReedKellogg
//
//  Created by Christopher J. Covert on 3/16/11.
//  Copyright 2011 Rose-Hulman Institute of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PasswordEntryDelegate.h"

@interface PasswordEntryModalViewController : UIViewController {
	UIButton * acceptButton;
	UIButton * cancelButton; 
	UIButton * changePasswordButton;			
	
	UITextField * passwordTextBox;
	UITextField * newPasswordTextBox;
	UITextField * newPasswordConfirmTextBox;
	
	UILabel * newPasswordLabel;
	UILabel * newPasswordConfirmLabel;
	
	BOOL settingNewPassword;
	
	id <PasswordEntryDelegate> delegate;
}

@property (nonatomic, retain) IBOutlet UIButton * acceptButton;
@property (nonatomic, retain) IBOutlet UIButton * cancelButton;
@property (nonatomic, retain) IBOutlet UIButton * changePasswordButton;

@property (nonatomic, retain) IBOutlet UITextField * passwordTextBox;
@property (nonatomic, retain) IBOutlet UITextField * newPasswordTextBox;
@property (nonatomic, retain) IBOutlet UITextField * newPasswordConfirmTextBox;

@property (nonatomic, retain) IBOutlet UILabel * newPasswordLabel;
@property (nonatomic, retain) IBOutlet UILabel * newPasswordConfirmLabel;

@property (nonatomic, retain) IBOutlet id <PasswordEntryDelegate> delegate;
@property BOOL settingNewPassword;

- (IBAction) acceptButtonPressed: (id)sender;
- (IBAction) cancelButtonPressed: (id)sender;
- (IBAction) changePasswordButtonPressed: (id)sender;

- (id) initWithDelegate: (id <PasswordEntryDelegate>) delegate;

@end
