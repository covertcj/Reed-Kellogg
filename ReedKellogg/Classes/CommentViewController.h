//
//  CommentViewController.h
//  ReedKellogg
//
//  Created by Prodvend04 on 3/24/11.
//  Copyright 2011 RHIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Student.h"
#import "Lesson.h"
#import "Sentence.h"
#import "Layout.h"

@interface CommentViewController : UIViewController {
	
	BOOL TeacherMode;
	UIBarButtonItem *saveButton;
	UITextView *commentBox;
	
	Student *currStudent;
	Lesson *currLesson;
	Sentence *currSentence;
}

@property (nonatomic) BOOL TeacherMode;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *saveButton;
@property (nonatomic, retain) IBOutlet UITextView *commentBox;
@property (nonatomic, retain) Student *currStudent;
@property (nonatomic, retain) Lesson *currLesson;
@property (nonatomic, retain) Sentence *currSentence;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
-(IBAction)pressSave:(id)sender;

@end
