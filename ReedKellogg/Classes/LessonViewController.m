//
//  LessonViewController.m
//  NavigationTest
//
//  Created by Stephen Mayhew on 1/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LessonViewController.h"
#import "ReedKelloggAppDelegate.h"
#import "SentenceViewController.h"
#import "addNameViewController.h"
#import "Lesson.h"

@implementation LessonViewController

@synthesize currStudent;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	super.popFirstButton = @"Add Lesson";
	super.popSecondButton = @"Edit Lessons";
	
    [super viewDidLoad];
	
	[super fetchDataWithEntityName:@"Lesson"];
}

// This absolutely must be subclassed
-(NSString*) getEntityName {
	// Since the entity in question (being displayed on the table rows)
	// is Lesson, we return Lesson
	return @"Lesson";
}

// This method responds to the edit lessons button...
-(void)popupButton2Pressed{
	NSLog(@"popupButton2Pressed method");
	
	if (self.editing) {
		[self setEditing:NO animated:YES];
		
		// Reset the back button
		self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
	}else{
		// Set editing to true
		[self setEditing:YES animated:YES];
		
		// Overlay the back button with an editbuttonitem (it will say Done)
		UIBarButtonItem *editBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(setEdit:)];
		self.navigationItem.leftBarButtonItem = editBtn;
		[editBtn release];
		
	}	
	
	[namePopover dismissPopoverAnimated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	SentenceViewController *targetViewController = [[SentenceViewController alloc] init];
	Lesson *l = (Lesson *)[super.objectArray objectAtIndex:indexPath.row];
	targetViewController.title = [NSString stringWithFormat:@"Sentences for %@", l.name];
	targetViewController.managedObjectContext = self.managedObjectContext;
	targetViewController.TeacherMode = self.TeacherMode;
	targetViewController.currLesson = l;
	targetViewController.currStudent = self.currStudent;
	
	// Navigation logic may go here. Create and push another view controller.
	[[self navigationController] pushViewController:targetViewController animated:YES];
}

- (void)dealloc {
	[currStudent dealloc];
    [super dealloc];
}


@end
