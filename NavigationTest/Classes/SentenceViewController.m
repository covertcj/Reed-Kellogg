//
//  SentenceViewController.m
//  NavigationTest
//
//  Created by Stephen Mayhew on 1/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SentenceViewController.h"
#import "NavigationTestAppDelegate.h"
#import "SentenceViewController.h"
#import "addNameViewController.h"
#import "TouchViewController.h"
#import "Sentence.h"

@implementation SentenceViewController

// State variables
@synthesize currStudent;
@synthesize currLesson;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	super.popFirstButton = @"Add sentence";
	super.popSecondButton = @"Edit sentences";
	
    [super viewDidLoad];

	NSArray * sortMe = [[self.currLesson.sentences allObjects] mutableCopy];
	
	// Sort the array based on number
	NSSortDescriptor *sortDescriptor;
	sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"number"
												  ascending:YES] autorelease];
	NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
	NSArray *sortedArray;
	sortedArray = [sortMe sortedArrayUsingDescriptors:sortDescriptors];
	
	super.objectArray = [sortedArray mutableCopy];
	
}

// This absolutely must be subclassed
-(NSString*) getEntityName {
	// Since the entity in question (being displayed on the table rows)
	// is Student, we return Student
	return @"Sentence";
}

// This overrides the superclass method of the same name
- (void)addObject:(NSString *) name {
	
	Sentence *s = [NSEntityDescription insertNewObjectForEntityForName:@"Sentence" inManagedObjectContext:self.managedObjectContext];	
	[s setText:name];
	[s setNumber:[NSNumber numberWithInt:[self.objectArray count]+1]];
	
	[self.currLesson addSentencesObject:s];
	
	NSError *error = nil;
	
	if (![self.managedObjectContext save:&error]) {
		
		// Handle the error.
		
	}
	
	[super insertIntoTable:s];
	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	TouchViewController *targetViewController = [[TouchViewController alloc] init];
	
	targetViewController.managedObjectContext = self.managedObjectContext;
	Sentence *s =[super.objectArray objectAtIndex:indexPath.row];
	targetViewController.currLesson = self.currLesson;
	targetViewController.currSentence = s;
	targetViewController.currStudent = self.currStudent;
	targetViewController.TeacherMode = self.TeacherMode;
	
	// Navigation logic may go here. Create and push another view controller.
	[[self navigationController] pushViewController:targetViewController animated:YES];
}

//----------------------------------------------------------------------------------------------
// TAKE NOTE: THIS FUNCTION NEEDS TO BE HERE. IT HAS FUNCTIONALITY
// THAT IS SPECIFIC TO THIS CLASS
//-----------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (editingStyle == UITableViewCellEditingStyleDelete) {	
		
        // Delete the managed object at the given index path.		
        Sentence *eventToDelete = [self.objectArray objectAtIndex:indexPath.row];
		// This may be superfluous? maybe not
        [managedObjectContext deleteObject:eventToDelete];
		[self.currLesson removeSentencesObject:eventToDelete];
        // Update the array and table view.		
        [super.objectArray removeObjectAtIndex:indexPath.row];		
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
		
		
        // Commit the change.		
        NSError *error = nil;		
        if (![managedObjectContext save:&error]) {			
            // Handle the error.		
        }		
    }	
}


- (void)dealloc {
	[currStudent dealloc];
	[currLesson dealloc];
    [super dealloc];
}


@end
