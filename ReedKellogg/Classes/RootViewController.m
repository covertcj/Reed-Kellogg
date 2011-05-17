// This code was basically copied from somewhere, and now it has been modified by me. 


#import "RootViewController.h"
#import "LessonViewController.h"
#import "Student.h"
#import "PasswordEntryModalViewController.h"
#import "PasswordEntryDelegate.h"

@implementation RootViewController
@synthesize teacherLoginButton, passwordEntryModal;
@synthesize teacherLogoutButton;
@synthesize doneButton;

- (void)viewDidLoad {
	self.passwordEntryModal = [[PasswordEntryModalViewController alloc] initWithDelegate:self];
	passwordEntryModal.managedObjectContext = self.managedObjectContext;
	//self.passwordEntryModal.modalPresentationStyle = UIModalPresentationFormSheet;

	
	super.TeacherMode = NO;
	super.popFirstButton = @"Add Student";
	super.popSecondButton = @"Remove Student Mode";
	
	super.addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																		target:self action:@selector(showPopover)];
	
	self.teacherLoginButton = [[UIBarButtonItem alloc] initWithTitle:@"Login as Teacher"
																   style:UIBarButtonItemStyleBordered
																  target:self
																  action:@selector(promptForPassword:)];
	
	self.teacherLogoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout"
															   style:UIBarButtonItemStyleBordered
															  target:self
															  action:@selector(logoutOfTeacher:)];
	
	self.doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
																style:UIBarButtonItemStyleBordered
															   target:self
															   action:@selector(doneRemoving:)];
	
	self.navigationItem.leftBarButtonItem = self.teacherLoginButton;
	
	//set the title of the main view
	self.title = @"Pick a Student";
	[super fetchDataWithEntityName:@"Student"];
}

// This absolutely must be subclassed
-(NSString*) getEntityName {
	// Since the entity in question (being displayed on the table rows)
	// is Student, we return Student
	return @"Student";
} 

- (BOOL) verifyPassword:(NSString *)password {
	NSLog(@"Verifying the password: %@", password);
	return [password isEqualToString:@"pass"];
}

-(void)promptForPassword:(id)sender {
	UINavigationController * nvc = [[[UINavigationController alloc] initWithRootViewController:self.passwordEntryModal] autorelease];
	nvc.modalPresentationStyle = UIModalPresentationFormSheet;
	//self.passwordEntryModal.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	nvc.view.backgroundColor = [UIColor whiteColor];
	[self presentModalViewController:nvc animated:YES];
}

-(void)logoutOfTeacher:(id)sender {
	super.TeacherMode= NO;
	self.navigationItem.rightBarButtonItem = NULL;
	self.navigationItem.leftBarButtonItem = self.teacherLoginButton;
	[super.namePopover dismissPopoverAnimated:YES];
}

- (void) passwordEnteredProperly {
	self.TeacherMode = YES;
	// set the buttons to what they should be in teacher mode
	self.navigationItem.leftBarButtonItem = self.teacherLogoutButton;
	self.navigationItem.rightBarButtonItem = self.addButton;
}

-(void)doneRemoving:(id)sender {
	[self setEditing:NO animated:YES];
	self.navigationItem.rightBarButtonItem = self.addButton;
}

-(void)popupButton2Pressed{
	[self setEditing:YES animated:YES];
	[super.namePopover dismissPopoverAnimated:YES];
	self.navigationItem.rightBarButtonItem = self.doneButton;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Student * student = (Student *)[super.objectArray objectAtIndex:[indexPath row]];
	
	LessonViewController *newController = [[LessonViewController alloc] init];
	newController.managedObjectContext = self.managedObjectContext;
	newController.title = [NSString stringWithFormat: @"%@'s Lessons", student.name];  
	newController.currStudent = student;
	if (super.TeacherMode) {
		newController.TeacherMode=YES;
	}
	
    // Navigation logic may go here. Create and push another view controller.
	//UIViewController *targetViewController = [[views objectAtIndex:indexPath.row] objectForKey:@"controller"];
	[[self navigationController] pushViewController:newController animated:YES];
}

@end
