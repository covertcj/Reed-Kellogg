// This code was basically copied from somewhere, and now it has been modified by me. 


#import "RootViewController.h"
#import "LessonViewController.h"
#import "Student.h"

@implementation RootViewController
@synthesize teacherLoginButton;

- (void)viewDidLoad {
	super.TeacherMode = NO;
	super.popFirstButton = @"Add Student";
	super.popSecondButton = @"Logout";
	super.addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																		target:self action:@selector(showPopover)];
	super.addButton.enabled = YES;	
	self.teacherLoginButton = [[UIBarButtonItem alloc] initWithTitle:@"Login as Teacher"
																   style:UIBarButtonItemStyleBordered
																  target:self
																  action:@selector(pushTeacher:)];
	self.teacherLoginButton.enabled = YES;
	self.navigationItem.rightBarButtonItem = self.teacherLoginButton;
	
	
       // create a custom navigation bar button and set it to always say "Back"
       UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
       temporaryBarButtonItem.title = @"Back";
       self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
       [temporaryBarButtonItem release];
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

-(void)pushTeacher:(id)sender {
	[super.namePopover dismissPopoverAnimated:YES];
	if (super.TeacherMode) {
		super.TeacherMode= NO;
		self.navigationItem.leftBarButtonItem = NULL;
		self.navigationItem.rightBarButtonItem = self.teacherLoginButton;
	}else {
		self.navigationItem;
		super.TeacherMode= YES;
		self.navigationItem.leftBarButtonItem = self.editButtonItem;
		self.navigationItem.rightBarButtonItem = self.addButton;
	}

	
	/*
	LessonViewController *newController = [[LessonViewController alloc] init];
	newController.title = [NSString stringWithFormat: @"Teacher Screen - All Lessons"];  
	newController.managedObjectContext = super.managedObjectContext;
	newController.TeacherMode = YES;
	*/
    // Navigation logic may go here. Create and push another view controller.
	//[[self navigationController] pushViewController:newController animated:YES];
	
}

-(void)pushTeacher{
	
	super.TeacherMode= NO;
	self.navigationItem.leftBarButtonItem = NULL;
	self.navigationItem.rightBarButtonItem = self.teacherLoginButton;
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
