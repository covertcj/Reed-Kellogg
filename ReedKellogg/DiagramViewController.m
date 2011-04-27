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
@synthesize lineStart, touchedWord;
@synthesize previousScrollTouchLoc;

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
	NSLog(@"viewDidLoad");
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
	
	UITapGestureRecognizer * doubleTapRecognizer  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapFrom:)];
	doubleTapRecognizer.numberOfTapsRequired      = 2;
	doubleTapRecognizer.cancelsTouchesInView      = YES;
	[self.diagramView addGestureRecognizer:doubleTapRecognizer];
	
	UITapGestureRecognizer * singleTapRecognizer  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapFrom:)];
	singleTapRecognizer.numberOfTapsRequired      = 1;
	singleTapRecognizer.cancelsTouchesInView      = YES;
	[self.diagramView addGestureRecognizer:singleTapRecognizer];
	[singleTapRecognizer release];
	[doubleTapRecognizer release];
	NSLog(@"viewDidLoad: end");
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
	NSLog(@"loadLayout");
	
	// create the core data request
	NSFetchRequest * request = [[[NSFetchRequest alloc] init] autorelease];
	[request setPredicate:[NSPredicate predicateWithFormat:@"creator == %@ AND sentence == %@", self.selectedStudent, selectedSentence]];
	[request setEntity:[NSEntityDescription entityForName:@"Layout" inManagedObjectContext:managedObjectContext]];
	
	// send the core data request
	NSError * error;
	NSArray * results = [managedObjectContext executeFetchRequest:request error:&error];
	
	NSLog(@"loadLayout: end");
	return ([results count] > 0) ? (Layout *)[results objectAtIndex:0] : nil;
}

- (void) setLayout:(Layout *)layout {
	NSLog(@"setLayout");
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
	NSLog(@"setLayout: end");
}

- (void) setLayoutWords:(Layout *) layout {
	NSLog(@"setLayoutWords");
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
	NSLog(@"setLayoutWords: end");
}

- (void) setLayoutLines:(Layout *) layout {
	NSLog(@"setLayoutLines");
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
	NSLog(@"setLayoutLines: end");
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

- (void) handleSingleDragFrom:(UIPanGestureRecognizer *)recognizer {
	NSLog(@"handleSingleDragFrom");
	CGPoint vel      = CGPointMake([recognizer velocityInView:self.diagramView].x * 0.025, [recognizer velocityInView:self.diagramView].y * 0.025);
	CGPoint touchLoc = CGPointMake([recognizer locationInView:self.diagramView].x, [recognizer locationInView:self.diagramView].y);
	
	if (recognizer.state      == UIGestureRecognizerStateBegan) {
		touchLoc = CGPointMake(touchLoc.x - vel.x, touchLoc.y - vel.y);
		
		// check if the touch is in a word
		for (UILabel * word in self.words) {
			CGRect wordFrame = word.frame;
			// if a word is touched, set is as moving
			
			if (CGRectContainsPoint(wordFrame, touchLoc)) {
				self.touchedWord = word;
				self.diagramView.touchedLine = nil;
				return;
			}
		}
		
		// if we have a line selected
		if (self.diagramView.touchedLine != nil) {
			int offset = 20;
			
			// and we touched the first point
			if (touchLoc.x > self.diagramView.touchedLine.start.x - offset &&
				touchLoc.x < self.diagramView.touchedLine.start.x + offset &&
				touchLoc.y > self.diagramView.touchedLine.start.y - offset &&
				touchLoc.y < self.diagramView.touchedLine.start.y + offset) {
				self.lineStart = self.diagramView.touchedLine.end;
				[self.diagramView removeLine:self.diagramView.touchedLine];
				return;
			}
			
			// and we touched the second point
			else if (touchLoc.x > self.diagramView.touchedLine.end.x - offset &&
					 touchLoc.x < self.diagramView.touchedLine.end.x + offset &&
					 touchLoc.y > self.diagramView.touchedLine.end.y - offset &&
					 touchLoc.y < self.diagramView.touchedLine.end.y + offset) {
				self.lineStart = self.diagramView.touchedLine.start;
				[self.diagramView removeLine:self.diagramView.touchedLine];
				return;
			}
		}
		
		
		self.diagramView.touchedLine = nil;
		
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
	NSLog(@"handleDoubleDragFrom");
	CGPoint touchLoc = CGPointMake([recognizer locationInView:self.diagramView].x, 
								   [recognizer locationInView:self.diagramView].y);
	float speedCoeff = 1;
	
	if (recognizer.state == UIGestureRecognizerStateBegan) {
		self.previousScrollTouchLoc     = touchLoc;
	}
	else if (recognizer.state == UIGestureRecognizerStateChanged) {
		NSLog(@"ScrollX's: (%f, %f)", self.previousScrollTouchLoc.x, touchLoc.x);
		NSLog(@"ScrollDeltas: (%f, %f)", (self.previousScrollTouchLoc.x - touchLoc.x) , (self.previousScrollTouchLoc.y - touchLoc.y) );
		CGRect rect = CGRectMake((self.previousScrollTouchLoc.x - touchLoc.x) + self.diagramView.contentOffset.x,
		                         (self.previousScrollTouchLoc.y - touchLoc.y) + self.diagramView.contentOffset.y,
								 self.diagramView.frame.size.width, 
								 self.diagramView.frame.size.height);
		
		[self.diagramView scrollRectToVisible:rect animated:NO];
	}
	
	[self.diagramView setNeedsDisplay];
}

- (void) handleSingleTapFrom:(UITapGestureRecognizer *)recognizer {
	NSLog(@"handleSingleTapFrom");
	CGPoint touchLoc = [recognizer locationInView:self.diagramView];
	self.diagramView.touchedLine = nil;
	
	// check if the touch is in a word
	for (UILabel * word in self.words) {
		CGRect wordFrame = word.frame;
		
		// if the word is touched, rotate it
		if (CGRectContainsPoint(wordFrame, touchLoc)) {
			self.touchedWord = word;
			
			float angle = atan2(self.touchedWord.transform.b, self.touchedWord.transform.a);
			if (angle > 0.77f && angle < 0.79f) {
				angle = -M_PI / 4.0f;
			}	
			else {
				angle = angle + M_PI / 4.0f;
			}
			
			self.touchedWord.transform = CGAffineTransformMakeRotation(angle);
			self.touchedWord = nil;
			
			return;
		}
	}
	
	// otherwise check if we are selecting a line
	for (Line * line in self.diagramView.lines) {
		if ([self.diagramView touch:touchLoc nearLine:line]) {
			self.diagramView.touchedLine = line;
			[self.diagramView setNeedsDisplay];
			return;
		}
	}
}

- (void) handleDoubleTapFrom:(UITapGestureRecognizer *)recognizer {
	NSLog(@"handleDoubleTapFrom");
	CGPoint touchLoc = CGPointMake([recognizer locationInView:self.diagramView].x, 
								   [recognizer locationInView:self.diagramView].y);
	
	Line * toRemove = nil;
	
	NSLog(@"double tap");
	for (Line * line in self.diagramView.lines) {
		NSLog(@"double tap - check line: (%f, %f) to (%f, %f) against (%f, %f)", line.start.x, line.start.y, line.end.x, line.end.y, touchLoc.x, touchLoc.y);
		if ([self.diagramView touch:touchLoc nearLine:(Line *)line]) {
			toRemove = line;
		}
	}
	
	if (toRemove != nil) {
		[self.diagramView removeLine:toRemove];
	}
}

#pragma mark -
#pragma mark UI Event Response

@end
