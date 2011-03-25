    //
//  CommentViewController.m
//  ReedKellogg
//
//  Created by Prodvend04 on 3/24/11.
//  Copyright 2011 RHIT. All rights reserved.
//

#import "CommentViewController.h"


@implementation CommentViewController
@synthesize TeacherMode;
@synthesize saveButton;
@synthesize commentBox;
@synthesize currStudent;
@synthesize currLesson;
@synthesize currSentence;
@synthesize managedObjectContext;
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	commentBox.font = [UIFont systemFontOfSize:30];
	if (!self.TeacherMode) {
		self.saveButton.enabled = NO;
		self.commentBox.editable = NO;
	}
	NSFetchRequest * request = [[[NSFetchRequest alloc] init] autorelease];
	[request setPredicate:[NSPredicate predicateWithFormat:@"creator == %@ AND sentence == %@",currStudent,currSentence]];
	[request setEntity:[NSEntityDescription entityForName:@"Layout" inManagedObjectContext:managedObjectContext]];
	NSError * error;
	NSArray * results = [managedObjectContext executeFetchRequest:request error:&error];
	
	self.commentBox.text = @"testing";
	for(Layout *l in results){
		self.commentBox.text = l.comments;
	}
	
}

- (void) pressSave:(id)sender{
	NSLog(@"Save Pressed");
	NSFetchRequest * request = [[[NSFetchRequest alloc] init] autorelease];
	[request setPredicate:[NSPredicate predicateWithFormat:@"creator == %@ AND sentence == %@",currStudent,currSentence]];
	[request setEntity:[NSEntityDescription entityForName:@"Layout" inManagedObjectContext:managedObjectContext]];
	NSError * error;
	NSArray * results = [managedObjectContext executeFetchRequest:request error:&error];
	for(Layout *l in results){
		NSLog(@"Setting comments to %@", self.commentBox.text);
		l.comments = self.commentBox.text;
		//[l setComments:self.commentBox.text];
	}
	
	//commit changes and handle error if it breaks		
	error = nil;
	if (![managedObjectContext save:&error]) {
		NSLog(@"Error saving...");
		NSLog(@"Operation failed: %@, %@", error, [error userInfo]);
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
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
