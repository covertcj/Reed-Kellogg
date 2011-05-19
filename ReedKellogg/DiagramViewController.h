//
//  DiagramViewController.h
//  ReedKellogg
//
//  Created by Christopher J. Covert on 4/14/11.
//  Copyright 2011 Rose-Hulman Institute of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DiagramViewDelegate.h"
#import "CommentViewController.h"

@class DiagramView;
@class Layout, Lesson, Sentence, Student;

@interface DiagramViewController : UIViewController <UIScrollViewDelegate, DiagramViewDelegate> {
	UIBarButtonItem * nextButton;
	UIBarButtonItem * prevButton;
	UIBarButtonItem * viewCommentsButton;
	UIBarButtonItem * showGridButton;
	UIBarButtonItem * infoButton;
	UISegmentedControl * correctButton;
	UISegmentedControl * dashedControl;
	
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
	BOOL set;
	
	CGPoint           lineStart;
	UILabel *         touchedWord;
//	CGAffineTransform startingTransform;
	
	CGPoint previousScrollTouchLoc;
}

@property (nonatomic, retain) IBOutlet UIBarButtonItem * nextButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem * prevButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem * viewCommentsButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem * showGridButton;
@property (nonatomic, retain) IBOutlet UISegmentedControl * correctButton;
@property (nonatomic, retain) IBOutlet UISegmentedControl * dashedControl;
@property (nonatomic, retain) UIBarButtonItem * infoButton;


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
@property (nonatomic) BOOL set;

@property (nonatomic)         CGPoint           lineStart;
@property (nonatomic, retain) UILabel *         touchedWord;
//@property (nonatomic)         CGAffineTransform startingTransform;

@property (nonatomic) CGPoint previousScrollTouchLoc;

- (IBAction) saveDiagram:(id)sender;
- (Layout *) loadLayout;
- (void) setLayout:(Layout *) layout;
- (void) setLayoutWords:(Layout *) layout;
- (void) setLayoutLines:(Layout *) layout;
- (UILabel *) createWord:(NSString *)text withOrigin:(CGPoint)frameOrigin andRotation:(CGAffineTransform)rotation;

- (CGPoint) snapPositionForWord:(UILabel *)word;

- (void) moveTouchedWordToLocation:(CGPoint)location;

//- (IBAction) handlePinchGesture:(UIPinchGestureRecognizer *)sender;
- (IBAction) showComments: (id)sender;
- (IBAction) prevSentence: (id)sender;
- (IBAction) nextSentence: (id)sender;
- (IBAction) toggleGrid:   (id)sender;
- (IBAction) toggleCorrect:(id)sender;
- (IBAction) toggleDashed: (id)sender;
- (IBAction) showInfo:     (id)sender;
@end
