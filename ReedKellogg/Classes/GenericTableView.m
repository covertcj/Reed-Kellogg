//
//  GenericTableView.m
//  NavigationTest
//
//  Created by Stephen Mayhew on 2/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GenericTableView.h"
#import "Student.h"
#import "Sentence.h"
#import "Lesson.h"

@implementation GenericTableView

@synthesize addButton;
@synthesize nameViewController;
@synthesize namePopover;
@synthesize objectArray;
@synthesize managedObjectContext;
@synthesize TeacherMode;
@synthesize popFirstButton;
@synthesize popSecondButton;

// Run when the view loads
- (void)viewDidLoad {
	// Set up the buttons.
	if (TeacherMode) {
		addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
															  target:self action:@selector(showPopover)];
		addButton.enabled = YES;	
		self.navigationItem.rightBarButtonItem = addButton;
	}

		
	
}

// The two addNameViewControllerDelegate methods
-(void)popupButtonPressed:(NSString *)string{
	[self addObject:string];
	
	[self.namePopover dismissPopoverAnimated:YES];
}

// This either enables begins Teacher mode (pushes a 
// ViewController with TeacherMode = YES, or 
// sets the editing mode to YES
-(void)popupButton2Pressed{
	// Perhaps will be a part of a protocol? IE, every subclass must implement this
}

// This can be either Student, Lesson, or Sentence
- (void)addObject:(NSString *) name {
	
	NSString *type = [self getEntityName];
	
	NSObject *o;
	if ([type isEqualToString:@"Student"]) {
		o = [NSEntityDescription insertNewObjectForEntityForName:@"Student" inManagedObjectContext:self.managedObjectContext];	
		Student * s = (Student *)o;
		[s setName:name];
	}else if ([type isEqualToString:@"Lesson"]) {
		o = [NSEntityDescription insertNewObjectForEntityForName:@"Lesson" inManagedObjectContext:self.managedObjectContext];	
		Lesson * l = (Lesson *) o;
		[l setName:name];
	}else if ([type isEqualToString:@"Sentence"]) {
		o = (Sentence *)[NSEntityDescription insertNewObjectForEntityForName:@"Sentence" inManagedObjectContext:self.managedObjectContext];	
		Sentence *s = (Sentence *) o;
		[s setText:name];
		[s setNumber:[NSNumber numberWithInt:[self.objectArray count]+1]];

	}else {
		NSLog(@"type of object in addObject is not correct...it should be Student, Lesson or Sentence, but instead it is: %@",type);
	}

	
	NSError *error = nil;
	
	if (![self.managedObjectContext save:&error]) {
		
		// Handle the error.
		
	}

	[self insertIntoTable:o];
		
}

-(void) insertIntoTable:(NSObject *) o{
	[self.objectArray insertObject:o atIndex:[self.objectArray count]];
	NSLog(@"inserted object in Array; object is %@, new count is %d",self.objectArray, [self.objectArray count]);
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.objectArray count]-1 inSection:0];	
	[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]	 
						  withRowAnimation:UITableViewRowAnimationFade];	
	//[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}
	

// This absolutely must be subclassed
-(NSString*) getEntityName {
	return @"error";
}

-(void)setEdit:(id) sender{
	[self popupButton2Pressed];
}

// The popover on the righthand side
// that usually involves adding and removing 
// items
-(void)showPopover{
	if (self.nameViewController == nil) {
		self.nameViewController = [[[addNameViewController alloc] init] autorelease];
		self.nameViewController.delegate = self;
		
		// This will need to be changed so it can tell what screen it is displaying for.
		self.nameViewController.btnTitle = self.popSecondButton;
		self.nameViewController.submitBtnTitle = self.popFirstButton;

	}
	
	if(self.namePopover == nil){
		UIPopoverController * newPopover = [[UIPopoverController alloc] initWithContentViewController:self.nameViewController];
		self.namePopover = newPopover;
		[newPopover release];
	}
	
	CGRect viewFrame = self.view.frame;
	self.namePopover.popoverContentSize = CGSizeMake(viewFrame.size.width, 250);
	
	// Present the Popover
	[self.namePopover presentPopoverFromBarButtonItem:addButton
							 permittedArrowDirections:UIPopoverArrowDirectionAny
											 animated:YES];
	
}

// Given an entity name, this fetches the corresponding
// data and stores it in a mutablearray called objectArray
-(void) fetchDataWithEntityName:(NSString *)entityName{
	NSFetchRequest * request = [[[NSFetchRequest alloc] init] autorelease];
	[request setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext]];
	NSError * error;
	NSArray * results = [managedObjectContext executeFetchRequest:request error:&error];
	if(results == nil) {
		NSLog(@"Couldn't fetch; error was %@", error);
		self.objectArray = [[[NSMutableArray alloc] initWithCapacity:10] autorelease];
	} else {
		NSLog(@"Successfully fetched %d %@ objects", [results count], entityName);
		self.objectArray = [results mutableCopy];
	}
	
	if ([entityName isEqualToString:@"Sentences"]) 
	{
		NSLog(self.objectArray);
	}
}



#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [objectArray count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *CellIdentifier = @"Cell";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
	
    // Set up the cell...
	// These next lines will need to be added on a case-by-case basis
	NSObject * o = [self.objectArray objectAtIndex:[indexPath row]];
	cell.textLabel.text = o.description;
	
    return cell;
}

// This method is run when a row in the table is selected. IndexPath.row refers to the index
// of the row selected.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// This will also be implemented on a case by case basis.
}

// This is used to remove the delete-by-swipe capability
- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Detemine if it's in editing mode
    if (self.editing) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}


// This is what is called when the delete button (comes with the table) is pressed in the Table View.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (editingStyle == UITableViewCellEditingStyleDelete) {	
		
        // Delete the managed object at the given index path.		
        NSManagedObject *objectToDelete = [objectArray objectAtIndex:indexPath.row];		
        [managedObjectContext deleteObject:objectToDelete];
		
        // Update the array and table view.		
        [objectArray removeObjectAtIndex:indexPath.row];		
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
		
        // Commit the change.		
        NSError *error = nil;		
        if (![managedObjectContext save:&error]) {			
            // Handle the error.		
        }		
    }	
}

// Releases the view if it doesn't have a superview
// Release anything that's not essential, such as cached data
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; 
}

- (void)dealloc {
	[objectArray dealloc];
	[managedObjectContext dealloc];
	[addButton dealloc];
	[namePopover dealloc];
	[nameViewController dealloc];
	[popFirstButton dealloc];
	[popSecondButton dealloc];
    [super dealloc];
}

	
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return YES;
}

@end
