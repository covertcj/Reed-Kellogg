    //
//  PasswordEntryModalViewController.m
//  ReedKellogg
//
//  Created by Christopher J. Covert on 3/16/11.
//  Copyright 2011 Rose-Hulman Institute of Technology. All rights reserved.
//

#import "PasswordEntryModalViewController.h"


@implementation PasswordEntryModalViewController
@synthesize acceptButton, cancelButton, passwordTextBox, delegate;

- (id) initWithDelegate: (id <PasswordEntryDelegate>) delegate {
	self.delegate = delegate;
	return self;
}

- (IBAction) acceptButtonPressed: (id)sender {
	// tell the delegate that the user pressed accept and pass along the password
	NSString * password = [[self passwordTextBox] text];
	self.passwordTextBox.text = @"";
	
	[[self delegate] passwordEntryAcceptPressed: password];
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction) cancelButtonPressed: (id)sender {
	// do nothing
	self.passwordTextBox.text = @"";
	[self dismissModalViewControllerAnimated:YES];
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
