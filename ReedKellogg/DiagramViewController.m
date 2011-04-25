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
	
	// set the size of the window
	CGRect viewFrame       = self.view.frame;
	viewFrame.size.width  *= 3.0f;
	viewFrame.size.height *= 1.5f;
//	self.view.frame        = viewFrame;
	((UIScrollView *)(self.view)).contentSize = CGSizeMake(viewFrame.size.width, viewFrame.size.height);
	
	// set the grid size
	((DiagramView *)(self.view)).gridSize     = 40;
	((DiagramView *)(self.view)).showGrid     = YES;
	
	// load the layout
	self.words = [[NSMutableArray alloc] init];
	[self setLayout:[self loadLayout]];
	
	// allow only two finger scrolling
	for (UIGestureRecognizer *gestureRecognizer in self.view.gestureRecognizers) {     
		if ([gestureRecognizer  isKindOfClass:[UIPanGestureRecognizer class]])
		{
			UIPanGestureRecognizer * panGR = (UIPanGestureRecognizer *) gestureRecognizer;
			panGR.minimumNumberOfTouches   = 2;
			panGR.maximumNumberOfTouches   = 2;
			panGR.enabled = YES;
		}
    }
	
	[self.view setNeedsDisplay];
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
		[self.view addSubview:word];
	}
}

- (void) setLayoutLines:(Layout *) layout {
	[self.view removeAllLines];
	
	// if save data exists
	if (layout) {
		// add in all lines
		for (LineData * lineData in layout.LinesData) {
			Line * line = [[Line alloc] init];
			line.start  = CGPointMake([lineData.x1 floatValue], [lineData.y1 floatValue]);
			line.end    = CGPointMake([lineData.x2 floatValue], [lineData.y2 floatValue]);
			[self.view addLine:line];
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
	return self.view;
}

#pragma mark -
#pragma mark Touches

- (void) moveTouchedWordToLocation:(CGPoint)location {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:200];
	self.touchedWord.center = location;
	[UIView commitAnimations];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	// find all touches, not just the single touch that just started
	NSSet * allTouches = [touches setByAddingObjectsFromSet:[event touchesForView:self]];
	// set the start of the line to a dummy locaton that is out of bounds
	self.lineStart   = CGPointMake(-1, -1);
	// 2 touches should pass through to the scroll view
	if ([allTouches count] == 1) {
		// extract the touch and its location
		UITouch * touch    = [touches anyObject];
		CGPoint   touchLoc = [touch locationInView:self.view];
		
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
		CGPoint touchLoc = [touch locationInView:self.view];
		
		if (self.lineStart.x != -1) {
			// find the end point of the line being drawn (a temp line)
			CGPoint lineEnd = CGPointMake(touchLoc.x, touchLoc.y);
			Line * line     = [[Line alloc] init];
			line.start      = self.lineStart;
			line.end        = lineEnd;
			
			// add the touch as the endpoint of a temp
			[self.view setTemp:line];
			
			[line release];
		}
		else if (self.touchedWord != nil) {
			[self moveTouchedWordToLocation:touchLoc];
		}
	}
	else {
		[self.view setTemp:nil];
	}
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	// clear the animations so that snapping may animate
	[UIView beginAnimations:nil context:nil];
	
	if ([touches count] == 1) {
		// if we are drawing a line
		if (self.lineStart.x != -1) {
			// remove the dummy line
			CGPoint dummyLinePoint = CGPointMake(-1, -1);
			Line * dummyLine = [[Line alloc] init];
			dummyLine.start  = dummyLinePoint;
			dummyLine.end    = dummyLinePoint;
			[self.view setTempLine:dummyLine];
			[dummyLine release];
			
			// find the information about this touch
			UITouch * touch    = [touches anyObject];
			CGPoint   touchLoc = [touch locationInView:self.view];
			
			// create the endpoint for the drawn line
			CGPoint   lineEnd  = CGPointMake(touchLoc.x, touchLoc.y);
			
			// create the final line and pass to the view
			Line * line        = [[Line alloc] init];
			line.start         = self.lineStart;
			line.end           = lineEnd;
			[self.view addLine:line];
			[line release];
		}
		else {
			// snap a word that is being moved
			CGPoint snapTo  = self.touchedWord.center;
			CGFloat gridSize = ((DiagramView *)(self.view)).gridSize;
			snapTo.x        = roundf(snapTo.x / gridSize) * gridSize;
			snapTo.y        =  floor(snapTo.y / gridSize) * gridSize + gridSize / 2;
			
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
}

#pragma mark -
#pragma mark UI Event Response

@end
