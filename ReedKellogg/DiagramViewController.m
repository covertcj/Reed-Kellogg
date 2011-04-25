    //
//  DiagramViewController.m
//  ReedKellogg
//
//  Created by Christopher J. Covert on 4/14/11.
//  Copyright 2011 Rose-Hulman Institute of Technology. All rights reserved.
//

#import "DiagramViewController.h"
#import "DiagramView.h"

#import "Layout.h"
#import "Line.h"
#import "LineData.h"
#import "Sentence.h"
#import "WordData.h"

@implementation DiagramViewController

@synthesize selectedLesson, selectedStudent, selectedSentence, managedObjectContext;
@synthesize markCorrectButton;
@synthesize correctMark, wholeSentence;
@synthesize diagramView;
@synthesize words;
@synthesize teacherMode, correct;
@synthesize lineStart, touchedWord, startingTransform;
@synthesize previousScale, previousOffset, previousLocation, location;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	// load the layout
	self.words = [[NSMutableArray alloc] init];
	[self setLayout:[self loadLayout]];
	
	[self.diagramView setupView];
	
	UIPanGestureRecognizer * singleDragRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleDragFrom:)];
	singleDragRecognizer.minimumNumberOfTouches   = 1;
	singleDragRecognizer.maximumNumberOfTouches   = 1;
	singleDragRecognizer.cancelsTouchesInView     = YES;
	[self.diagramView addGestureRecognizer:singleDragRecognizer];
	[singleDragRecognizer release];
	
	UIPanGestureRecognizer * doubleDragRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleDragFrom:)];
	doubleDragRecognizer.minimumNumberOfTouches   = 2;
	doubleDragRecognizer.maximumNumberOfTouches   = 2;
	doubleDragRecognizer.cancelsTouchesInView     = YES;
	[self.diagramView addGestureRecognizer:doubleDragRecognizer];
	[doubleDragRecognizer release];
	
	UITapGestureRecognizer * singleTapRecognizer  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapFrom:)];
	singleTapRecognizer.numberOfTapsRequired      = 1;
	singleTapRecognizer.cancelsTouchesInView      = YES;
	[self.diagramView addGestureRecognizer:singleTapRecognizer];
	[singleTapRecognizer release];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	self.nextButton           = nil;
	self.prevButton           = nil;
	self.saveButton           = nil;
	self.viewCommentsButton   = nil;
	self.markCorrectButton    = nil;
	self.showGridButton       = nil;
	self.correctMark          = nil;
	self.wholeSentence        = nil;
	self.selectedLesson       = nil;
	self.selectedStudent      = nil;
	self.selectedSentence     = nil;
	self.managedObjectContext = nil;
	self.words                = nil;
	self.diagramView          = nil;

	[self.nextButton         release];
	[self.prevButton         release];
	[self.saveButton         release];
	[self.viewCommentsButton release];
	[self.markCorrectButton  release];
	[self.showGridButton     release];
	[self.correctMark        release];
	[self.wholeSentence      release];
	[self.words              release];
	[self.diagramView        release];
	
    [super dealloc];
}

- (Layout *) loadLayout {
	// create the core data request
	NSFetchRequest * request = [[[NSFetchRequest alloc] init] autorelease];
	[request setPredicate:[NSPredicate predicateWithFormat:@"creator == %@ AND sentence == %@", self.selectedStudent, selectedSentence]];
	[request setEntity:[NSEntityDescription entityForName:@"Layout" inManagedObjectContext:managedObjectContext]];
	
	// send the core data request
	NSError * error;
	NSArray * results = [managedObjectContext executeFetchRequest:request error:&error];
	[request release];
	
	return ([results count] > 0) ? (Layout *)[results objectAtIndex:0] : nil;
}

- (void) setLayout:(Layout *)layout {
	// setup the correctness marking for all request results
	if ([layout.grade boolValue]) {
		[self.correctMark setImage:[UIImage imageNamed:@"correct.png"]];
		self.markCorrectButton.title = @"Mark Incorrect";
		self.correct = YES;
	}
	else {
		[self.correctMark setImage:[UIImage imageNamed:@"incorrect.png"]];
		self.markCorrectButton.title = @"Mark Correct";
		self.correct = NO;
	}
	
	// setup the words and lines
	[self setLayoutWords:layout];
	[self setLayoutLines:layout];
}

- (void) setLayoutWords:(Layout *) layout {
	// remove all current words from the view
	for (UILabel * lab in words) {
		[lab removeFromSuperview];
	}
	[self.words removeAllObjects];
	
	// separate the word's text into an array
	NSArray * wordTextArray = [self.selectedSentence.text componentsSeparatedByString:@" "];
	
	// display the sentence to the user
	self.wholeSentence.text = self.selectedSentence.text;
	[wholeSentence sizeToFit];
	
	// parameters to decide the location of words
	int distFromTop  = 90;
	int distFromLeft = 50;
	
	// create the word objects
	for (int i = 0; i < [wordTextArray count]; i++) {
		// setup the word's parameters
		NSString * wordText   = [wordTextArray objectAtIndex:i];
		CGPoint    wordOrigin = CGPointMake(distFromLeft, distFromTop);
		CGAffineTransform wordRotation = CGAffineTransformMakeRotation(0.0f);
		
		// if the words are created already, set the params accordingly
		if (layout) {
			for (WordData * wd in layout.WordsData) {
				// if the index matches the current word
				if ([wd.wdIndex intValue] == i) {
					// set to the current word's parameters
					wordOrigin   = CGPointMake([wd.wdx floatValue], [wd.wdy floatValue]);
					wordRotation = CGAffineTransformMakeRotation([wd.wdRotation floatValue]);
					break;
				}
			}
		}
		
		// actually create the word
		UILabel * word   = [self createWord:wordText withOrigin:wordOrigin andRotation:wordRotation];
		CGRect wordFrame = word.frame;
		
		// increment the distance from the left side of the screen
		distFromLeft = word.frame.origin.x + word.frame.size.width;
		
		[self.words addObject:word];
		[self.diagramView addSubview:word];
	}
}

- (void) setLayoutLines:(Layout *) layout {
	[self.diagramView removeAllLines];
	
	// if save data exists
	if (layout) {
		// add in all lines
		for (LineData * lineData in layout.LinesData) {
			Line * line = [[Line alloc] init];
			line.start  = CGPointMake([lineData.x1 floatValue], [lineData.y1 floatValue]);
			line.end    = CGPointMake([lineData.x2 floatValue], [lineData.y2 floatValue]);
			[self.diagramView addLine:line];
		}
	}
}

- (UILabel *) createWord:(NSString *)text withOrigin:(CGPoint)frameOrigin andRotation:(CGAffineTransform)rotation {
	// create and setup the word parameters
	UILabel * word          = [[UILabel alloc] init];
	word.font               = [UIFont systemFontOfSize:30];
	word.textAlignment      = UITextAlignmentCenter;
	word.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
	word.opaque             = NO;
	word.backgroundColor    = [UIColor clearColor];
	
	// set the word text
	word.text               = text;
	
	// autosize the word's frame
	[word sizeToFit];
	
	// resize the word's frame
	CGRect wordFrame        = word.frame;
	wordFrame.size.width   += 20;
	wordFrame.size.height   = word.bounds.size.height;
	
	// set the word's screen position
	wordFrame.origin        = frameOrigin;
	
	// set the words frame
	word.frame              = wordFrame;
	
	// set the word's rotation
	word.transform          = rotation;
	
	// auto-resize again
	[word sizeToFit];
	
	return word;
}

- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return self.diagramView;
}

#pragma mark -
#pragma mark Touches

- (void) moveTouchedWordToLocation:(CGPoint)location {
	[UIView beginAnimations:nil context:nil];
	self.touchedWord.center = location;
	[self.touchedWord setNeedsDisplay];
	[UIView commitAnimations];
}

/*- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	// find all touches, not just the single touch that just started
	NSSet * allTouches = [touches setByAddingObjectsFromSet:[event touchesForView:self]];
	// set the start of the line to a dummy locaton that is out of bounds
	self.lineStart   = CGPointMake(-1, -1);
	// 2 touches should pass through to the scroll view
	if ([allTouches count] == 1) {
		// extract the touch and its location
		UITouch * touch    = [touches anyObject];
		CGPoint   touchLoc = [touch locationInView:self.diagramView];
		
		if (touch.tapCount == 2) {
			// TODO: Implement line removal
		}
		
		// check if the touch is in a word
		for (UILabel * word in self.words) {
			CGRect wordFrame = word.frame;
			// if a word is touched, set is as moving
			
			if (CGRectContainsPoint(wordFrame, touchLoc)) {
				self.touchedWord = word;
				return;
			}
		}
		
		// if not inside a word, start drawing a line
		self.lineStart = CGPointMake(touchLoc.x, touchLoc.y);
		
		self.startingTransform = self.touchedWord.transform;
		
	}
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	// ensure that the two touches can just fall through
	if ([touches count] == 1) {
		// grab the touch and its location
		UITouch * touch  = [touches anyObject];
		CGPoint touchLoc = [touch locationInView:self.diagramView];
		
		if (self.lineStart.x != -1) {
			// find the end point of the line being drawn (a temp line)
			CGPoint lineEnd = CGPointMake(touchLoc.x, touchLoc.y);
			Line * line     = [[Line alloc] init];
			line.start      = self.lineStart;
			line.end        = lineEnd;
			
			// add the touch as the endpoint of a temp
			[self.diagramView setTemp:line];
			
			[line release];
		}
		else if (self.touchedWord != nil) {
			[self moveTouchedWordToLocation:touchLoc];
		}
	}
	else {
		[self.diagramView setTemp:nil];
	}
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	// clear the animations so that snapping may animate
	[UIView beginAnimations:nil context:nil];
	NSLog(@"Touches: %d", [touches count]);
	if ([touches count] == 1) {
		// if we are drawing a line
		if (self.lineStart.x != -1) {
			// remove the dummy line
			CGPoint dummyLinePoint = CGPointMake(-1, -1);
			Line * dummyLine = [[Line alloc] init];
			dummyLine.start  = dummyLinePoint;
			dummyLine.end    = dummyLinePoint;
			[self.diagramView setTempLine:dummyLine];
			[dummyLine release];
			
			// find the information about this touch
			UITouch * touch    = [touches anyObject];
			CGPoint   touchLoc = [touch locationInView:self.diagramView];
			
			// create the endpoint for the drawn line
			CGPoint   lineEnd  = CGPointMake(touchLoc.x, touchLoc.y);
			
			// create the final line and pass to the view
			Line * line        = [[Line alloc] init];
			line.start         = self.lineStart;
			line.end           = lineEnd;
			[self.diagramView addLine:line];
			[line release];
		}
		else {
			// snap a word that is being moved
			CGPoint snapTo   = self.touchedWord.center;
			CGFloat gridSize = self.diagramView.gridSize;
			snapTo.x         = roundf(snapTo.x / gridSize) * gridSize;
			snapTo.y         =  floor(snapTo.y / gridSize) * gridSize + gridSize / 2;
			
			// push the data back into the word label
			self.touchedWord.center = snapTo;
			
			// force a refresh
			[self.touchedWord setNeedsDisplay];
		}
		
		// tell the animations to start
		[UIView commitAnimations];
		self.touchedWord = nil;
	}
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	// do nothing
	NSLog(@"Touches Cancelled");
}*/

- (void) handleSingleDragFrom:(UIPanGestureRecognizer *)recognizer {
	CGPoint touchLoc = CGPointMake([recognizer locationInView:self.diagramView].x, [recognizer locationInView:self.diagramView].y);
	
	if (recognizer.state      == UIGestureRecognizerStateBegan) {
		// check if the touch is in a word
		for (UILabel * word in self.words) {
			CGRect wordFrame = word.frame;
			// if a word is touched, set is as moving
			
			if (CGRectContainsPoint(wordFrame, touchLoc)) {
				self.touchedWord = word;
				return;
			}
		}
		
		// otherwise set the start point of the temporary line
		self.lineStart  = touchLoc;
	}
	else if (recognizer.state == UIGestureRecognizerStateChanged) {
		if (touchedWord != nil) {
			[self moveTouchedWordToLocation: touchLoc];
		}
		else {
			// create a temporary line to be drawn
			Line * line     = [[Line alloc] init];
			line.start      = self.lineStart;
			line.end        = touchLoc;

			[self.diagramView setTemp:line];
			
			[line release];
		}
	}
	else if (recognizer.state == UIGestureRecognizerStateEnded) {
		if (self.touchedWord != nil) {
			CGPoint snapTo   = self.touchedWord.center;
			CGFloat gridSize = self.diagramView.gridSize;
			snapTo.y         =  floor(snapTo.y / gridSize) * gridSize + gridSize / 2;
			
			[self moveTouchedWordToLocation:snapTo];
			
			self.touchedWord = nil;
		}
		else {
			// remove the temp line
			CGPoint endPoint = self.diagramView.tempLine.end;
			[self.diagramView setTemp:nil];
			
			// create a permenant line
			Line * line     = [[Line alloc] init];
			line.start      = self.lineStart;

			line.end        = endPoint;
			[self.diagramView addLine:line];
			
			[line release];
		}
	}
	else {
		NSLog(@"handleSingleDrag: Unknown Gesture State");
		if (self.touchedWord == nil) {
			CGPoint snapTo   = self.touchedWord.center;
			CGFloat gridSize = self.diagramView.gridSize;
			snapTo.y         =  floor(snapTo.y / gridSize) * gridSize + gridSize / 2;
			
			[self moveTouchedWordToLocation:snapTo];
			
			self.touchedWord = nil;
		}
		[self.diagramView setTemp: nil];
	}
}

- (void) handleDoubleDragFrom:(UIPanGestureRecognizer *)recognizer {
	NSLog(@"handleDoubleDrag");
	CGPoint touchLoc = [recognizer locationInView:self.diagramView];
	
	self.diagramView.contentOffset = touchLoc;
}

- (void) handleSingleTapFrom:(UITapGestureRecognizer *)recognizer {
	CGPoint touchLoc = [recognizer locationInView:self.diagramView];
	
	// check if the touch is in a word
	for (UILabel * word in self.words) {
		CGRect wordFrame = word.frame;
		// if a word is touched, set is as moving
		
		if (CGRectContainsPoint(wordFrame, touchLoc)) {
			self.touchedWord = word;
			
			float angle = atan2(self.touchedWord.transform.b, self.touchedWord.transform.a);
			angle = angle + M_PI/4.0;
			self.touchedWord.transform = CGAffineTransformMakeRotation(rintf(angle));
			
			return;
		}
	}
	
/*	//NSLog(@"Rotation happening, %@", self.current.text);
	
	self.current.transform = CGAffineTransformRotate(self.startingTransform, [recognizer rotation]);
	
	// Handle rotation snap. NOTE: if you want to see continuous rotation, and THEN snap, 
	// put the following block of code into the if(recognizer.state == ...) block. 
	float angle = atan2(self.current.transform.b, self.current.transform.a);
	float angleStep = M_PI/4.0;
	float factor = angle/angleStep;
	self.current.transform = CGAffineTransformMakeRotation(rintf(factor)*angleStep);
	
	// Turns out that touchesEnded isn't called after this. hmm.
	if (recognizer.state == UIGestureRecognizerStateEnded) {
		//NSLog(@"Finished rotation");
		
		self.current = nil;
	}*/
}

#pragma mark -
#pragma mark UI Event Response

@end