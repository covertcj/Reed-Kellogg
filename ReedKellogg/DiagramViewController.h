//
//  DiagramViewController.h
//  ReedKellogg
//
//  Created by Christopher J. Covert on 4/14/11.
//  Copyright 2011 Rose-Hulman Institute of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DiagramViewDelegate.h"

@class DiagramView;
@class Layout, Lesson, Sentence, Student;

@interface DiagramViewController : UIViewController <UIScrollViewDelegate, DiagramViewDelegate> {
	UIBarButtonItem * nextButton;
	UIBarButtonItem * prevButton;
	UIBarButtonItem * saveButton;
	UIBarButtonItem * viewCommentsButton;
	UIBarButtonItem * markCorrectButton;
	UIBarButtonItem * showGridButton;
	
	UIImageView * correctMark;
	UILabel     * wholeSentence;
	
	Lesson   * selectedLesson;
	Student  * selectedStudent;
	Sentence * selectedSentence;
	NSManagedObjectContext * managedObjectContext;
	
	NSMutableArray * words;
	
	DiagramView * diagramView;
	
	BOOL teacherMode;
	BOOL correct;
	
	CGPoint           lineStart;
	UILabel *         touchedWord;
	CGAffineTransform startingTransform;
	
	CGPoint previousScrollTouchLoc;
}

@property (nonatomic, retain) IBOutlet UIBarButtonItem * nextButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem * prevButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem * saveButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem * viewCommentsButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem * markCorrectButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem * showGridButton;

@property (nonatomic, retain) IBOutlet UIImageView * correctMark;
@property (nonatomic, retain) IBOutlet UILabel     * wholeSentence;

@property (nonatomic, retain) Lesson   * selectedLesson;
@property (nonatomic, retain) Student  * selectedStudent;
@property (nonatomic, retain) Sentence * selectedSentence;
@property (nonatomic, retain) NSManagedObjectContext * managedObjectContext;

@property (nonatomic, retain) NSMutableArray * words;

@property (nonatomic, retain) IBOutlet DiagramView * diagramView;

@property (nonatomic) BOOL teacherMode;
@property (nonatomic) BOOL correct;

@property (nonatomic) CGPoint           lineStart;
@property (nonatomic) UILabel *         touchedWord;
@property (nonatomic) CGAffineTransform startingTransform;

@property (nonatomic) CGPoint previousScrollTouchLoc;

- (Layout *) loadLayout;
- (void) setLayout:(Layout *) layout;
- (void) setLayoutWords:(Layout *) layout;
- (void) setLayoutLines:(Layout *) layout;
- (UILabel *) createWord:(NSString *)text withOrigin:(CGPoint)frameOrigin andRotation:(CGAffineTransform)rotation;

- (void) moveTouchedWordToLocation:(CGPoint)location;

- (IBAction)handlePinchGesture:(UIPinchGestureRecognizer *)sender;

@end
