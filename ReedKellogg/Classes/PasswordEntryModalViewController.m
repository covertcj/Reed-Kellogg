    //
//  PasswordEntryModalViewController.m
//  ReedKellogg
//
//  Created by Christopher J. Covert on 3/16/11.
//  Copyright 2011 Rose-Hulman Institute of Technology. All rights reserved.
//

#import "PasswordEntryModalViewController.h"


@implementation PasswordEntryModalViewController

@synthesize acceptButton, cancelButton, changePasswordButton;
@synthesize passwordTextBox, newPasswordTextBox, newPasswordConfirmTextBox;
@synthesize newPasswordLabel, newPasswordConfirmLabel;
@synthesize delegate;
@synthesize settingNewPassword;


- (id) initWithDelegate: (id <PasswordEntryDelegate>) deleg {
	self.delegate = deleg;
	self.settingNewPassword = NO;
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

- (IBAction) acceptButtonPressed: (id)sender {
	if (self.settingNewPassword) {
		// ensure the new password and it's confirmation match
		if ([self.newPasswordTextBox.text isEqualToString:self.newPasswordConfirmTextBox.text]) {
			// ensure the password is 5 chars
			if ([self.newPasswordTextBox.text length] >= 5) {
				// TODO: Set the new password
				
				NSLog(@"The teacher password has been set to %@. (WARNING: This is not implemented yet!)", self.newPasswordTextBox.text);
				
				[self setChangeFieldsVisibility:NO];
			}
			else {
				NSLog(@"The new password length is too short.");
				UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The password is less than 5 characters." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
				[alert show];
				[alert release];
			}
		}
		else {
			NSLog(@"The new password and its confirmation are different");
			UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The passwords do not match." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}
	else {
		// tell the delegate that the user pressed accept and pass along the password
		NSString * password = [[self passwordTextBox] text];
		self.passwordTextBox.text = @"";
		
		[[self delegate] passwordEntryAcceptPressed: password];
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
