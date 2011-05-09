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

#import "SentenceFileReader.h"

@implementation DiagramViewController

@synthesize selectedLesson, selectedStudent, selectedSentence, managedObjectContext;
@synthesize correctMark, wholeSentence;
@synthesize diagramView;
@synthesize words;
@synthesize teacherMode, correct, set;
@synthesize lineStart, touchedWord;
@synthesize previousScrollTouchLoc;
@synthesize showGridButton, correctButton;

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
	
	self.set = NO;
	
	// load the layout
	[self.diagramView setupView];
	self.words = [[NSMutableArray alloc] init];
	[self setLayout:[self loadLayout]];
	
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
	
	if (!teacherMode) {
		correctButton.enabled = FALSE;
	}
	
	[singleTapRecognizer release];
	[doubleTapRecognizer release];
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
	self.viewCommentsButton   = nil;
	self.showGridButton       = nil;
	self.correctMark          = nil;
	self.wholeSentence        = nil;
	self.selectedLesson       = nil;
	self.selectedStudent      = nil;
	self.selectedSentence     = nil;
	self.managedObjectContext = nil;
	self.words                = nil;
	self.diagramView          = nil;
	self.correctButton        = nil;

	[self.nextButton         release];
	[self.prevButton         release];
	[self.viewCommentsButton release];
	[self.showGridButton     release];
	[self.correctMark        release];
	[self.wholeSentence      release];
	[self.words              release];
	[self.diagramView        release];
	[self.correctButton      release];
	
    [super dealloc];
}

- (Layout *) loadLayout {
	
	// create the core data request
	NSFetchRequest * request = [[[NSFetchRequest alloc] init] autorelease];
	[request setPredicate:[NSPredicate predicateWithFormat:@"creator == %@ AND sentence == %@", self.selectedStudent, self.selectedSentence]];
	[request setEntity:[NSEntityDescription entityForName:@"Layout" inManagedObjectContext:managedObjectContext]];
	
	// send the core data request
	NSError * error;
	NSArray * results = [managedObjectContext executeFetchRequest:request error:&error];
	
	return ([results count] > 0) ? (Layout *)[results objectAtIndex:0] : nil;
}

- (void) setLayout:(Layout *)layout {
	//boolean noting if done setting. It's needed to handle when the UISegmentedControl gets triggered.
	self.set = NO; 
	// setup the correctness marking for all request results
	if ([layout.grade boolValue]) {
		[self.correctMark setImage:[UIImage imageNamed:@"correct.png"]];
		self.correct = YES;
		[correctButton setSelectedSegmentIndex:0];
	}
	else {
		[self.correctMark setImage:[UIImage imageNamed:@"incorrect.png"]];
		self.correct = NO;
		[correctButton setSelectedSegmentIndex:1];
	}
	
	// setup the words and lines
	[self setLayoutWords:layout];
	[self setLayoutLines:layout];
	self.set = YES;
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
			CGFloat x1 = [lineData.x1 floatValue];
			CGFloat y1 = [lineData.y1 floatValue];
			CGFloat x2 = [lineData.x2 floatValue];
			CGFloat y2 = [lineData.y2 floatValue];
			
			line.start  = CGPointMake(x1, y1);
			line.end    = CGPointMake(x2, y2);
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
	//wordFrame.size.width   += 20;
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

- (CGPoint) snapPositionForWord:(UILabel *)word {
	CGPoint snapTo   = word.center;
	CGFloat gridSize = self.diagramView.gridSize;
	
	float angle = atan2(word.transform.b, word.transform.a);
	if (angle > 0.77f && angle < 0.79f) {
		float k = fmodf(gridSize - fmodf(snapTo.y - snapTo.x, gridSize),gridSize);
		//move to line
		snapTo.y = snapTo.y + k/2;
		snapTo.x = snapTo.x - k/2;
		//move off of line
		snapTo.y = snapTo.y - gridSize/4;
		snapTo.x = snapTo.x + gridSize/4;
	} 
	else if (angle < -0.77f && angle > -0.79) {
		float k = fmodf(gridSize - fmodf(snapTo.y + snapTo.x, gridSize),gridSize);
		//move to line
		snapTo.y = snapTo.y + k/2;
		snapTo.x = snapTo.x + k/2;
		//move off of line
		snapTo.y = snapTo.y - gridSize/4;
		snapTo.x = snapTo.x - gridSize/4;
	}
	else {
		snapTo.y         =  floor(snapTo.y / gridSize) * gridSize + gridSize / 2;
	}
	
	return snapTo;
}

- (void) handleSingleDragFrom:(UIPanGestureRecognizer *)recognizer {
	CGPoint vel      = CGPointMake([recognizer velocityInView:self.diagramView].x * 0.025, [recognizer velocityInView:self.diagramView].y * 0.025);
	CGPoint touchLoc = CGPointMake([recognizer locationInView:self.diagramView].x, [recognizer locationInView:self.diagramView].y);
	
	if (recognizer.state      == UIGestureRecognizerStateBegan) {
		touchLoc = CGPointMake(touchLoc.x - vel.x, touchLoc.y - vel.y);
		
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
			CGPoint snapTo   = [self snapPositionForWord:self.touchedWord];
			
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
		if (self.touchedWord == nil) {
			CGPoint snapTo   = [self snapPositionForWord:self.touchedWord];
			
			[self moveTouchedWordToLocation:snapTo];
			
			self.touchedWord = nil;
		}
		[self.diagramView setTemp: nil];
	}
}

- (void) handleDoubleDragFrom:(UIPanGestureRecognizer *)recognizer {
	CGPoint touchLoc = CGPointMake([recognizer locationInView:self.diagramView].x, 
								   [recognizer locationInView:self.diagramView].y);
	float speedCoeff = 1;
	
	if (recognizer.state == UIGestureRecognizerStateBegan) {
		self.previousScrollTouchLoc     = touchLoc;
	}
	else if (recognizer.state == UIGestureRecognizerStateChanged) {
		CGRect rect = CGRectMake((self.previousScrollTouchLoc.x - touchLoc.x) + self.diagramView.contentOffset.x,
		                         (self.previousScrollTouchLoc.y - touchLoc.y) + self.diagramView.contentOffset.y,
								 self.diagramView.frame.size.width, 
								 self.diagramView.frame.size.height);
		
		[self.diagramView scrollRectToVisible:rect animated:NO];
	}
	
	[self.diagramView setNeedsDisplay];
}

- (void) handleSingleTapFrom:(UITapGestureRecognizer *)recognizer {
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
	
	[self.diagramView setNeedsDisplay];
}

- (void) handleDoubleTapFrom:(UITapGestureRecognizer *)recognizer {
	CGPoint touchLoc = CGPointMake([recognizer locationInView:self.diagramView].x, 
								   [recognizer locationInView:self.diagramView].y);
	
	Line * toRemove = nil;
	
	for (Line * line in self.diagramView.lines) {
		if ([self.diagramView touch:touchLoc nearLine:(Line *)line]) {
			toRemove = line;
		}
	}
	
	if (toRemove != nil) {
		[self.diagramView removeLine:toRemove];
	}
}

- (void) goToSentence:(int) direction{
	// Save data first.
	[self saveDiagram:nil];
	
	// We have access to currLesson, which means we have access to all sentences in this lesson.
	BOOL recieved = NO;
	
	for(Sentence *st in [selectedLesson sentences]){
		if (st.number == selectedSentence.number+direction) {
			selectedSentence = st;
			recieved = YES;
			break;
		}
	}
	
	//No result so move up a screen
	if (!recieved) {
		[self.navigationController popViewControllerAnimated:YES];
		return;
	}
	
	//remove previous label
	for(UIView *v in self.view.subviews){
		if ([v isKindOfClass:[UILabel class]]) {
			[v removeFromSuperview];
		}
	}
	[self setLayout:[self loadLayout]];
	[diagramView setNeedsDisplay];
}

- (void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:TRUE];
	[self saveDiagram:nil];
}

- (IBAction) saveDiagram:(id)sender{
	// Make sure that we override any previous entries that have the same creator and sentence
	NSFetchRequest * request = [[[NSFetchRequest alloc] init] autorelease];
	[request setPredicate:[NSPredicate predicateWithFormat:@"creator == %@ AND sentence == %@",selectedStudent,selectedSentence]];
	[request setEntity:[NSEntityDescription entityForName:@"Layout" inManagedObjectContext:managedObjectContext]];
	NSError * error;
	NSArray * results = [managedObjectContext executeFetchRequest:request error:&error];
	
	//retrieve old comments stored in coredata. Store them in a local variable because the coredata entry will be deleted.
	NSString * comments=@"";
	for(Layout *l in results){
		comments = [NSString stringWithString: l.comments];
		[managedObjectContext deleteObject:l];
	}
	
	if (![managedObjectContext save:&error]) {
		NSLog(@"Deletion failed (deletion): %@, %@", error, [error userInfo]);
	}
	
	Layout *layout = (Layout *)[NSEntityDescription insertNewObjectForEntityForName:@"Layout" inManagedObjectContext:managedObjectContext];
	layout.creator = selectedStudent;
	layout.sentence = selectedSentence;
	layout.grade = [[NSNumber alloc] initWithBool:self.correct];
	layout.comments = [NSString stringWithString:comments];
	// Save words coordinates, and rotation
	for(int i = 0; i < [words count]; i++){
		UILabel *w = [words objectAtIndex:i];
		
		//Rotate word to 0
		CGAffineTransform origTransform = w.transform;
		w.transform = CGAffineTransformMakeRotation(0);
		
		WordData *wd = (WordData *)[NSEntityDescription insertNewObjectForEntityForName:@"WordData" inManagedObjectContext:managedObjectContext];
		//NSLog(@"Frame origin x:%f, y:%f", w.frame.origin.x, w.frame.origin.y);
		wd.wdx = [NSNumber numberWithFloat:w.frame.origin.x];
		wd.wdy = [NSNumber numberWithFloat:w.frame.origin.y];
		
		// Rotate words back
		w.transform = origTransform;
		
		wd.wdRotation = [NSNumber numberWithFloat:atan2(w.transform.b, w.transform.a)];
		wd.wdIndex = [NSNumber numberWithInt:i];
		
		// Do something cool
		[layout addWordsDataObject:wd];
	}
	
	// Save lines coordinates
	NSMutableArray *lines = [diagramView lines];
	for(Line *line in lines){
		LineData *ld = (LineData *)[NSEntityDescription insertNewObjectForEntityForName:@"LineData" inManagedObjectContext:managedObjectContext];
		/*
		 NSValue *start = [line objectAtIndex:0];
		NSValue *end = [line objectAtIndex:1];
		*/
		CGPoint tempStartPoint = line.start;
		CGPoint tempEndPoint = line.end;
		
		ld.x1 = [NSNumber numberWithFloat:tempStartPoint.x];
		ld.y1 = [NSNumber numberWithFloat:tempStartPoint.y];
		ld.x2 = [NSNumber numberWithFloat:tempEndPoint.x];
		ld.y2 = [NSNumber numberWithFloat:tempEndPoint.y];
		[layout addLinesDataObject:ld];
		// Do more cool stuff
	}
	
	//commit changes and handle error if it breaks
	if (![managedObjectContext save:&error]) {
		NSLog(@"Error saving...");
		NSLog(@"Operation failed: %@, %@", error, [error userInfo]);
	}
}

- (IBAction) showComments:(id)sender{
	[self saveDiagram:nil];
	CommentViewController *targetViewController = [[CommentViewController alloc] init];
	targetViewController.title = @"Comments";
	targetViewController.managedObjectContext = self.managedObjectContext;
	targetViewController.TeacherMode = self.teacherMode;
	targetViewController.currLesson = self.selectedLesson;
	targetViewController.currSentence = self.selectedSentence;
	targetViewController.currStudent = self.selectedStudent;
	[[self navigationController] pushViewController:targetViewController animated:YES];
}

- (IBAction) prevSentence:(id)sender{
	NSLog(@"Prev Pressed");
	[self goToSentence:-1];
}

- (IBAction) nextSentence:(id)sender{
	NSLog(@"Next Pressed");
	[self goToSentence:1];
}

- (IBAction) toggleGrid:(id)sender{
	if (diagramView.showGrid) {
		[self.showGridButton setTitle:@"Show Grid"];
		diagramView.showGrid = NO;
		[diagramView setNeedsDisplay];
	} else {
		[self.showGridButton setTitle:@"Hide Grid"];
		diagramView.showGrid = YES;
		[diagramView setNeedsDisplay];
	}

}

- (IBAction) toggleCorrect:(id)sender{
	if (set) {
		NSLog(@"toggleCorrect");
		if (correct) {
			self.correct = NO;
			[self.correctMark setImage:[UIImage imageNamed:@"incorrect.png"]];
			[self.correctMark setNeedsDisplay];
		}else {
			self.correct = YES; 
			[self.correctMark setImage:[UIImage imageNamed:@"correct.png"]];
			[self.correctMark setNeedsDisplay];
		}
	}
}

#pragma mark -
#pragma mark UI Event Response

@end
