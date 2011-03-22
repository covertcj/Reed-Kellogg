    //
//  PasswordEntryModalViewController.m
//  ReedKellogg
//
//  Created by Christopher J. Covert on 3/16/11.
//  Copyright 2011 Rose-Hulman Institute of Technology. All rights reserved.
//

#import "PasswordEntryModalViewController.h"
#import "SFHFKeychainUtils.h"


@implementation PasswordEntryModalViewController

@synthesize acceptButton, cancelButton, changePasswordButton;
@synthesize passwordTextBox, newPasswordTextBox, newPasswordConfirmTextBox;
@synthesize newPasswordLabel, newPasswordConfirmLabel;
@synthesize currentPassword, passwordKeychain;
@synthesize delegate;
@synthesize settingNewPassword;


- (id) initWithDelegate: (id <PasswordEntryDelegate>) deleg {
	self.delegate = deleg;
	self.settingNewPassword = NO;
	
	// retrieve the Teacher's password
	NSError * error = nil;
	self.currentPassword = [SFHFKeychainUtils getPasswordForUsername:@"Teacher" andServiceName:@"ReedKellogg" error:&error];
	
	// initialize the password if there isn't one in the keychain
	if (self.currentPassword == nil) {
		NSLog(@"No password exists. Initializing password to \"\".");
		self.currentPassword = @"pass";
		[SFHFKeychainUtils storeUsername:@"Teacher" andPassword:self.currentPassword forServiceName:@"ReedKellogg" updateExisting:YES error:&error];
	}
	
	NSLog(@"Password Loaded: %@", self.currentPassword);
	
	return self;
}

- (void) setChangeFieldsVisibility:(BOOL)visible {
	NSLog(@"Setting password change visibility");
	
	// show/hide the change password button
	self.changePasswordButton.hidden = visible;
	
	// show/hide the password change textboxes and labels
	self.newPasswordLabel.hidden = !visible;
	self.newPasswordTextBox.hidden = !visible;
	self.newPasswordConfirmLabel.hidden = !visible;
	self.newPasswordConfirmTextBox.hidden = !visible;
	
	// tell the view whether we are in password change mode
	self.settingNewPassword = visible;
	
	// reset the text fields
	self.passwordTextBox.text = @"";
	self.newPasswordTextBox.text = @"";
	self.newPasswordConfirmTextBox.text = @"";
}

- (void) setNewPassword {
	// ensure the new password and it's confirmation match
	if ([self checkNewPassword]) {
		NSString * newPass = self.newPasswordTextBox.text;
		
		// set the new password
		self.currentPassword = newPass;
		
		// save the new teacher password from the password plist file
		NSError * error = nil;
		[SFHFKeychainUtils storeUsername:@"Teacher" andPassword:self.currentPassword forServiceName:@"ReedKellogg" updateExisting:YES error:&error];
		
		NSLog(@"The teacher password has been set to %@.", self.newPasswordTextBox.text);
		
		// change the UI to no longer show the password change fields
		[self setChangeFieldsVisibility:NO];
	}
}

- (BOOL) checkPassword {
	if ([self.passwordTextBox.text isEqualToString:self.currentPassword]) {
		return YES;
	}
	
	// inform the user
	NSLog(@"Incorrect password entered");
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Incorrect password." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
	[alert show];
	[alert release];
	
	return NO;
}

- (BOOL) checkNewPassword {
	NSString * newPass = self.newPasswordTextBox.text;
	NSString * newPassConf = self.newPasswordConfirmTextBox.text;
	
	// make sure the passwords match
	if ([newPass isEqualToString:newPassConf]) {
		// check password length
		if ([newPass length] >= 5) {
			return YES;
		}
		else {
			// the password was too short, alert the user
			NSLog(@"The new password length is too short.");
			UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The password is less than 5 characters." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}
	
	// warn the user
	NSLog(@"The new password and its confirmation are different");
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The passwords do not match." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
	[alert show];
	[alert release];
	
	return NO;
}

- (IBAction) acceptButtonPressed: (id)sender {
	if (self.settingNewPassword) {
		[self setNewPassword];
	}
	else if ([self checkPassword]) {
		self.passwordTextBox.text = @"";
		
		[[self delegate] passwordEnteredProperly];
		[self dismissModalViewControllerAnimated:YES];
	}
}

- (IBAction) cancelButtonPressed: (id)sender {
	if (self.settingNewPassword) {
		[self setChangeFieldsVisibility:NO];
	}
	else {
		[self dismissModalViewControllerAnimated:YES];
	}
	
	self.passwordTextBox.text = @"";
	self.newPasswordTextBox.text = @"";
	self.newPasswordConfirmTextBox.text = @"";
}

- (IBAction) changePasswordButtonPressed: (id)sender {
	NSLog(@"Entering password change mode.");
	[self setChangeFieldsVisibility:YES];
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSLog(@"Loaded the PasswordEntryModalViewController");
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
