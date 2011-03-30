//
//  GenericTableView.h
//  NavigationTest
//
//  Created by Stephen Mayhew on 2/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "addNameViewController.h"

// How to make this into a protocol? There are methods in here that need to be implemented
@interface GenericTableView : UITableViewController <addNameViewControllerDelegate> {
	
	NSMutableArray *objectArray;
	NSManagedObjectContext *managedObjectContext;
	
	addNameViewController *nameViewController;
	UIPopoverController *namePopover;
	
	NSString * popFirstButton;
	NSString * popSecondButton;
	
	BOOL TeacherMode;
	
}

@property (nonatomic, retain) NSMutableArray *objectArray;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;


@property (nonatomic, retain) NSString * popFirstButton;
@property (nonatomic, retain) NSString * popSecondButton;

@property (nonatomic) BOOL TeacherMode;
@property (nonatomic, retain) UIBarButtonItem *addButton;
@property (nonatomic, retain) addNameViewController *nameViewController;
@property (nonatomic, retain) UIPopoverController *namePopover;


// To satisfy the addNameViewControllerDelegate
-(void)popupButtonPressed:(NSString *)string;
-(void)popupButton2Pressed;

-(void) fetchDataWithEntityName:(NSString *)entityName;
- (void)addObject:(NSString *) name;
-(NSString*) getEntityName;
-(void) insertIntoTable:(NSObject *) o;


@end
