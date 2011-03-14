//
//  NewViewController.h
//  NavigationTest
//
//  Created by Stephen Mayhew on 1/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Student.h"
#import "GenericTableView.h"

@interface LessonViewController : GenericTableView {
	//IBOutlet NSMutableArray *lessons;
	
	//NSManagedObjectContext *managedObjectContext;
	//UIPopoverController *namePopover;	
	//addNameViewController * nameViewController;
	
	//BOOL TeacherMode;
	
	Student * currStudent;
	
}

@property (nonatomic, retain) Student *currStudent;

//@property (nonatomic) BOOL TeacherMode;
//@property (nonatomic, retain) IBOutlet NSMutableArray *lessons;
//@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
//@property (nonatomic, retain) UIBarButtonItem *addButton;
//@property (nonatomic, retain) UIPopoverController *namePopover;
//@property (nonatomic, retain) addNameViewController *nameViewController;


//- (void)addLesson:(NSString *) name;

@end
