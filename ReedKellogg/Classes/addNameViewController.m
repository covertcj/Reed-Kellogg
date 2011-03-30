    //
//  addNameViewController.m
//  Locations
//
//  Created by Stephen Mayhew on 1/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "addNameViewController.h"


@implementation addNameViewController
@synthesize delegate;
@synthesize nameField;
@synthesize button;
@synthesize submitButton;
@synthesize btnTitle;
@synthesize submitBtnTitle;

- (void)viewDidLoad {
	NSLog(@"Loaded. Title: @%", btnTitle);
	[button setTitle:btnTitle forState:UIControlStateNormal];
	[submitButton setTitle:submitBtnTitle forState:UIControlStateNormal];
	
}


-(IBAction)buttonPressed:(id)sender{
	NSLog(@"buttonPressed");
	
	// Should lower the keyboard.
	[nameField resignFirstResponder];
	
	NSString * name = self.nameField.text;
	
	if ([name isEqualToString:@""]) {
		NSLog(@"String can't be the empty string");
		return;
	}
	
	[self.delegate popupButtonPressed:name];
	[self.nameField setText:@""];
}

-(IBAction)teacherPressed:(id)sender{
	
	[self.delegate popupButton2Pressed];
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
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


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
	[delegate dealloc];
	[nameField dealloc];
    [super dealloc];
}


@end
