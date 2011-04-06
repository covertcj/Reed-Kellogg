//
//  TouchViewController.h
//  NavigationTest
//
//  Created by Stephen Mayhew on 1/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomView.h"
#import "UpdateCustomView.h"
#import "Student.h"
#import "Lesson.h"
#import "Sentence.h"
#import "CommentViewController.h"
#import "ReedKelloggAppDelegate.h"
#import "CustomView.h"
#import "Layout.h"
#import "WordData.h"
#import "LineData.h"

@interface TouchViewController : UIViewController {
	NSMutableArray * words;
	UILabel * current;
	UITextField * textField;
	UIButton * submit;
	CGAffineTransform startingTransform;
	
	NSManagedObjectContext *managedObjectContext;

	CustomView * linesView;
	
	CGPoint line1;
	CGPoint line2;
	
	CGFloat gridSize;
	
	// State variables
	Student *currStudent;
	Lesson *currLesson;
	Sentence *currSentence;
@private
	id<UpdateCustomView> _delegate;
	
}
@property (nonatomic, retain) UIBarButtonItem *nextButton;
@property (nonatomic, retain) UIBarButtonItem *prevButton;
@property (nonatomic, retain) UIBarButtonItem *saveButton;
@property (nonatomic, retain) UIBarButtonItem *commentButton;
@property (nonatomic, retain) UIBarButtonItem *correctButton;
@property (nonatomic, retain) UIBarButtonItem *incorrectButton;
@property (nonatomic, retain) UIBarButtonItem *gridButton;
@property (nonatomic, retain) UIImageView *correctMark;



@property (nonatomic) BOOL TeacherMode;

@property (nonatomic, retain) Student *currStudent;
@property (nonatomic, retain) Lesson *currLesson;
@property (nonatomic, retain) Sentence *currSentence;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSMutableArray * words;
@property (nonatomic, retain) UILabel * current;
@property (nonatomic) CGPoint line1;
@property (nonatomic) CGPoint line2;
@property (nonatomic) CGFloat gridSize;
@property (nonatomic) CGAffineTransform startingTransform;
@property (nonatomic, retain) IBOutlet CustomView * linesView;
@property (nonatomic, retain) IBOutlet UITextField * textField;
@property (nonatomic, retain) IBOutlet UIButton * submit;

@property (nonatomic, assign) id<UpdateCustomView> delegate;

-(void) setWordLayout:Layout;


@end
