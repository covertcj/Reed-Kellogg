    //
//  TouchViewController.m
//  NavigationTest
//
//  Created by Stephen Mayhew on 1/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TouchViewController.h"
#import "Frame.h"

@implementation TouchViewController

@synthesize words;
@synthesize current;
@synthesize textField;
@synthesize submit;
@synthesize linesView;
@synthesize startingTransform;
@synthesize line1;
@synthesize line2;
@synthesize drawingLine;
@synthesize managedObjectContext;
@synthesize gridSize;

@synthesize TeacherMode;

@synthesize delegate = _delegate;

@synthesize currStudent;
@synthesize currLesson;
@synthesize currSentence;
@synthesize wordPositions;

@synthesize prevButton;
@synthesize nextButton;
@synthesize saveButton;
@synthesize correctButton;
@synthesize incorrectButton;
@synthesize commentButton;
@synthesize correctMark;
@synthesize gridButton;


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
	self.gridSize = 40;
	NSLog(@"Student: %@, Lesson: %@, Sentence: %@", self.currStudent.name, self.currLesson.name, self.currSentence.text);
	self.wordPositions = [[NSMutableArray alloc] initWithCapacity:20];
	
	CustomView *myView = [[[CustomView alloc] init] autorelease];
	self.view = myView;
	self.delegate = myView;
	self.delegate.gridSize = self.gridSize;

	// Create a bottom bar with buttons...
	UIToolbar *toolbar = [[UIToolbar alloc] init];
	toolbar.barStyle = UIBarStyleDefault;
	[toolbar sizeToFit];
	NSLog(@"height %f width %f",self.view.frame.size.height,self.view.frame.size.width);
	int toolBarHeight = 50;
	int screenHeight = [[UIScreen mainScreen] bounds].size.height;
	int screenWidth = [[UIScreen mainScreen] bounds].size.width;
	int navigationBarHeight = self.navigationController.navigationBar.bounds.size.height; // I don't know!
	toolbar.frame = CGRectMake(0, screenHeight-toolBarHeight-navigationBarHeight-20, screenWidth, toolBarHeight);
	
	//Add buttons
	self.nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next"
																   style:UIBarButtonItemStyleBordered
																   target:self
																  action:@selector(pressNext:)];

	
	self.prevButton = [[UIBarButtonItem alloc] initWithTitle:@"Prev"
																   style:UIBarButtonItemStyleBordered
																  target:self
																  action:@selector(pressPrev:)];
	
	self.saveButton = [[UIBarButtonItem alloc]
									initWithBarButtonSystemItem:UIBarButtonSystemItemSave
									target:self action:@selector(pressSave:)];
						
	self.commentButton = [[UIBarButtonItem alloc] initWithTitle:@"Comments"
														  style:UIBarButtonItemStyleBordered
														 target:self
														 action:@selector(pressComment:)];
	commentButton.enabled = NO;
	
	self.correctButton = [[UIBarButtonItem alloc] initWithTitle:@"Mark Correct"
														  style:UIBarButtonItemStyleBordered
														 target:self
														 action:@selector(pressCorrect:)];
	self.correctButton.enabled = NO;
	
	self.incorrectButton = [[UIBarButtonItem alloc] initWithTitle:@"Mark Incorrect"
														  style:UIBarButtonItemStyleBordered
														 target:self
														 action:@selector(pressIncorrect:)];
	self.incorrectButton.enabled = NO;
	
	self.incorrectButton = [[UIBarButtonItem alloc] initWithTitle:@"Mark Incorrect"
															style:UIBarButtonItemStyleBordered
														   target:self
														   action:@selector(pressIncorrect:)];
	
	self.gridButton = [[UIBarButtonItem alloc] initWithTitle:@"Hide Grid"
															style:UIBarButtonItemStyleBordered
														   target:self
														   action:@selector(pressGrid:)];
	
	correctMark = [[UIImageView alloc] initWithFrame:CGRectMake(700, 40, 40, 40)];
	self.correctMark.opaque = YES; 
	[self.view addSubview:self.correctMark];
	
	NSFetchRequest * request = [[[NSFetchRequest alloc] init] autorelease];
	[request setPredicate:[NSPredicate predicateWithFormat:@"creator == %@ AND sentence == %@",currStudent,currSentence]];
	[request setEntity:[NSEntityDescription entityForName:@"Layout" inManagedObjectContext:managedObjectContext]];
	NSError * error;
	NSArray * results = [managedObjectContext executeFetchRequest:request error:&error];
	for(Layout *l in results){
		if ([l.grade boolValue]) {
			[self.correctMark setImage:[UIImage imageNamed:@"correct.png"]]; 
			self.incorrectButton.enabled=YES;
			self.commentButton.enabled = YES;
		}else {
			[self.correctMark setImage:[UIImage imageNamed:@"incorrect.png"]]; 
			self.correctButton.enabled=YES;
			self.commentButton.enabled = YES;
		}
	}
	
	if (TeacherMode) {
		saveButton.enabled = NO;
	}else{
		saveButton.enabled = YES;
	}

	//Use this to put space in between your toolbox buttons
	UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																			  target:nil
																			  action:nil];

	UIBarButtonItem *fixedItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
																			  target:nil
																			  action:nil];
	
	self.drawingLine = NO;
	
	NSArray *items;
	fixedItem.width = 40;	
	if (self.TeacherMode) {
		items = [NSArray arrayWithObjects: prevButton, fixedItem, nextButton, fixedItem, gridButton, flexItem, correctButton,incorrectButton, commentButton, nil];
	}else {
		items = [NSArray arrayWithObjects: prevButton, fixedItem, nextButton, fixedItem, saveButton, fixedItem, gridButton, flexItem, commentButton,nil];
	}

	//release buttons
	[prevButton release];
	[saveButton release];
	[nextButton release];
	[flexItem release];
	[fixedItem release];
	
	//add array of buttons to toolbar
	[toolbar setItems:items animated:NO];	
	[self.view addSubview:toolbar];
	
 
	[self.correctMark release]; 

	
	[self fetchWordsAndSetLayout];
	UIGestureRecognizer *rotrecognizer;
	UIPanGestureRecognizer *panrecognizer;
	rotrecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotationFrom:)];
	panrecognizer = [[UIPanGestureRecognizer alloc]      initWithTarget:self action:@selector(handleTwoFingerDragWith:)];
	panrecognizer.minimumNumberOfTouches = 2;
	panrecognizer.maximumNumberOfTouches = 2;
	[self.view addGestureRecognizer:panrecognizer];
	[self.view addGestureRecognizer:rotrecognizer];
	[rotrecognizer release];
	[panrecognizer release];
}

-(void) fetchWordsAndSetLayout{
	words = [[NSMutableArray alloc] init];
	
	
	NSFetchRequest * request = [[[NSFetchRequest alloc] init] autorelease];
	[request setPredicate:[NSPredicate predicateWithFormat:@"creator == %@ AND sentence == %@",currStudent,currSentence]];
	[request setEntity:[NSEntityDescription entityForName:@"Layout" inManagedObjectContext:managedObjectContext]];
	NSError * error;
	NSArray * results = [managedObjectContext executeFetchRequest:request error:&error];
	
	if(results == nil) {
		NSLog(@"Couldn't fetch; error was %@", error);
		[self setWordLayout:nil];
	} else {
		NSLog(@"Successfully fetched %d layout objects", [results count]);
		if([results count]>0){
			[self setWordLayout:[results objectAtIndex:0]];
		} else {
			[self setWordLayout:nil];
		}
	}	
}

// This method used by pressPrev and pressNext to avoid duplicated code
-(void) goToSentence:(int) direction{
	// Save data first.
	[self pressSave:nil];
	
	// We have access to currLesson, which means we have access to all sentences in this lesson.
	BOOL gotit = NO;
	
	for(Sentence *st in [currLesson sentences]){
		if (st.number == currSentence.number+direction) {
			currSentence = st;
			gotit = YES;
			break;
		}
	}

	if (!gotit) {
		NSLog(@"That was the first or the last sentence in the lesson");
		[self.navigationController popViewControllerAnimated:YES];
		
		return;
	}
	
	for(UIView *v in self.view.subviews){
		if ([v isKindOfClass:[UILabel class]]) {
			[v removeFromSuperview];
		}
	}
	[words removeAllObjects];
	
	[self fetchWordsAndSetLayout];
	
}

- (void) pressPrev:(id)sender{
	NSLog(@"Prev Pressed");
	[self goToSentence:-1];
}

- (void) pressNext:(id)sender{
	NSLog(@"Next Pressed");
	[self goToSentence:1];
}

- (void) pressCorrect:(id)sender{
	NSLog(@"Correct Pressed");
	NSFetchRequest * request = [[[NSFetchRequest alloc] init] autorelease];
	[request setPredicate:[NSPredicate predicateWithFormat:@"creator == %@ AND sentence == %@",currStudent,currSentence]];
	[request setEntity:[NSEntityDescription entityForName:@"Layout" inManagedObjectContext:managedObjectContext]];
	NSError * error;
	NSArray * results = [managedObjectContext executeFetchRequest:request error:&error];
	for(Layout *l in results){
		NSLog(@"Marking correct");
		[self.correctMark setImage:[UIImage imageNamed:@"correct.png"]]; 
		self.correctButton.enabled = NO;
		self.incorrectButton.enabled = YES;
		[l setGrade:[NSNumber numberWithBool: YES]];
	}
	
	//commit changes and handle error if it breaks		
	error = nil;
	if (![managedObjectContext save:&error]) {
		NSLog(@"Error saving...");
		NSLog(@"Operation failed: %@, %@", error, [error userInfo]);
	}
}

- (void) pressIncorrect:(id)sender{
	NSLog(@"Incorrect Pressed");
	NSFetchRequest * request = [[[NSFetchRequest alloc] init] autorelease];
	[request setPredicate:[NSPredicate predicateWithFormat:@"creator == %@ AND sentence == %@",currStudent,currSentence]];
	[request setEntity:[NSEntityDescription entityForName:@"Layout" inManagedObjectContext:managedObjectContext]];
	NSError * error;
	NSArray * results = [managedObjectContext executeFetchRequest:request error:&error];
	for(Layout *l in results){
		[self.correctMark setImage:[UIImage imageNamed:@"incorrect.png"]]; 
		NSLog(@"Marking incorrect");
		self.correctButton.enabled = YES;
		self.incorrectButton.enabled = NO;
		[l setGrade:[NSNumber numberWithBool: NO]];
	}
	
	//commit changes and handle error if it breaks		
	error = nil;
	if (![managedObjectContext save:&error]) {
		NSLog(@"Error saving...");
		NSLog(@"Operation failed: %@, %@", error, [error userInfo]);
	}
	
}

- (void) pressComment:(id)sender{
	CommentViewController *targetViewController = [[CommentViewController alloc] init];
	targetViewController.title = @"Comments";
	targetViewController.managedObjectContext = self.managedObjectContext;
	targetViewController.TeacherMode = self.TeacherMode;
	targetViewController.currLesson = self.currLesson;
	targetViewController.currSentence = self.currSentence;
	targetViewController.currStudent = self.currStudent;
	[[self navigationController] pushViewController:targetViewController animated:YES];
}

- (void) pressSave:(id)sender{
	// move the screen to the origin, so as to properly place words before saving
	CGPoint origin = CGPointMake(0, 0);
	CGPoint tempScreenPosition = CGPointMake([self.delegate getScreenPositionX], [self.delegate getScreenPositionY]);
	self.delegate.screenPosition = origin;
	[self updateWordPositioning];
	
	NSLog(@"Save Pressed");
	// Make sure that we override any previous entries that have the same creator and sentence
	NSFetchRequest * request = [[[NSFetchRequest alloc] init] autorelease];
	[request setPredicate:[NSPredicate predicateWithFormat:@"creator == %@ AND sentence == %@",currStudent,currSentence]];
	[request setEntity:[NSEntityDescription entityForName:@"Layout" inManagedObjectContext:managedObjectContext]];
	NSError * error;
	NSArray * results = [managedObjectContext executeFetchRequest:request error:&error];
	BOOL oldgrade = NO;
	NSString * oldcomments=@"";
	for(Layout *l in results){
		oldcomments = [NSString stringWithString: l.comments];
		oldgrade = [l.grade boolValue];
		NSLog(@"%@ wat", oldcomments);
		[managedObjectContext deleteObject:l];
	}
	
	if (![managedObjectContext save:&error]) {
		NSLog(@"Deletion failed (deletion): %@, %@", error, [error userInfo]);
	}
	
	Layout *layout = (Layout *)[NSEntityDescription insertNewObjectForEntityForName:@"Layout" inManagedObjectContext:managedObjectContext];
	layout.creator = currStudent;
	layout.sentence = currSentence;
	layout.grade = [NSNumber numberWithBool:oldgrade];
	layout.comments = [NSString stringWithString:oldcomments];
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
		NSLog(@"Frame origin x:%@, y:%@", wd.wdx, wd.wdy);
		
		// Rotate words back
		w.transform = origTransform;
		
		wd.wdRotation = [NSNumber numberWithFloat:atan2(w.transform.b, w.transform.a)];
		wd.wdIndex = [NSNumber numberWithInt:i];
		
		// Do something cool
		[layout addWordsDataObject:wd];
	}
	
	// Save lines coordinates
	NSMutableArray *lines = [self.delegate getLineList];
	for(NSArray *line in lines){
		LineData *ld = (LineData *)[NSEntityDescription insertNewObjectForEntityForName:@"LineData" inManagedObjectContext:managedObjectContext];
		NSValue *start = [line objectAtIndex:0];
		NSValue *end = [line objectAtIndex:1];
		
		CGPoint tempStartPoint;
		CGPoint tempEndPoint;
		[start getValue:&tempStartPoint];
		[end getValue:&tempEndPoint];
		
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
	
	// move the screen back to it's proper position
	self.delegate.screenPosition = tempScreenPosition;
	[self updateWordPositioning];
}

- (void) pressGrid:(id)sender{
	if ([self.delegate showGrid]) {
		self.delegate.showGrid = NO;
		[self.delegate setNeedsDisplay];
		self.gridButton.title = @"Show Grid";
	}else {
		self.delegate.showGrid = YES;
		[self.delegate setNeedsDisplay];
		self.gridButton.title = @"Hide Grid";
	}}

- (void) setWordLayout:(Layout *) layout{
	for(UILabel *lab in words){
		[lab removeFromSuperview];
	}
	[self.words removeAllObjects];
	
	NSArray * listItems = [self.currSentence.text componentsSeparatedByString:@" "];
	
	// Display the entire sentence, for reference
	UILabel * wholeSentence = [[UILabel alloc] init];
	wholeSentence.text = self.currSentence.text;
	
	wholeSentence.font = [UIFont italicSystemFontOfSize:20];
	[wholeSentence sizeToFit];
	wholeSentence.opaque = NO;
	wholeSentence.backgroundColor = [UIColor clearColor];
	CGRect newF = wholeSentence.frame;
	newF.origin = CGPointMake(30, 30);
	wholeSentence.frame = newF;
	[self.view addSubview:wholeSentence];
	
	int distFromTop = 90;
	int leftSidePos = 50;
	
	for (int i = 0; i<[listItems count]; i++) {
		NSString * text = [listItems objectAtIndex:i];
		UILabel * aword = [[UILabel alloc] init ];
		aword.text = text;
		aword.font = [UIFont systemFontOfSize:30];
		[aword sizeToFit];
		aword.opaque = NO;
		aword.backgroundColor = [UIColor clearColor];
		aword.textAlignment = UITextAlignmentCenter; 
		aword.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
		
		CGRect newFrame = aword.frame;
		
		newFrame.size.height = aword.bounds.size.height;
		newFrame.size.width += 20;
		newFrame.origin = CGPointMake(leftSidePos, distFromTop);
		
		if(layout) {
			for (WordData *wd in layout.WordsData){
				if([wd.wdIndex intValue] == i){
					//NSLog("Setting word position: %@, %@",[wd.wdx floatValue],[wd.wdy floatValue]);
					
					newFrame.origin.x = [wd.wdx floatValue] - [self.delegate getScreenPositionX];
					newFrame.origin.y = [wd.wdy floatValue] - [self.delegate getScreenPositionY];
					
					aword.frame = newFrame;
					[aword sizeToFit];
					
					NSLog(@"In setword, before rotation, newFrame origin x:%f, y:%f", newFrame.origin.x, newFrame.origin.y);
					aword.transform = CGAffineTransformMakeRotation([wd.wdRotation floatValue]);
					break;
				}
			}
		}else{
			aword.frame = newFrame;
			[aword sizeToFit];
		}
		
		leftSidePos = newFrame.origin.x + newFrame.size.width;
		
		[words addObject:aword];
		CGPoint r = aword.frame.origin;
		Frame * frame = [[Frame alloc] init];
		frame.x = aword.frame.origin.x + aword.frame.size.width/2;
		frame.y = aword.frame.origin.y + aword.frame.size.height/2;
		[wordPositions addObject:frame];
		[self.view addSubview:aword];
		
		
	}
	
	[self.delegate removeAll];
	// Deal with adding lines
	if(layout){
		for(LineData *ld in layout.LinesData){
			[self.delegate addLine:CGPointMake([ld.x1 floatValue], [ld.y1 floatValue]) 
							   end:CGPointMake([ld.x2 floatValue], [ld.y2 floatValue])];
		}
	}
}

// Reset words and lines
- (void)reset:(id) sender{
	//NSLog(@"reset");
	[self setWordLayout:nil];
	
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
	self.words = nil;
	self.current = nil;
	self.textField = nil;
	self.submit = nil;
	self.linesView = nil;
}

- (void)dealloc {
    [super dealloc];
	[words release];
	[current release];
	[submit release];
	[linesView release];
	[textField release];
}

#pragma mark -
#pragma mark Touches

- (void) _handleTouch:(UITouch *) aTouch{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:200];
	CGPoint touchLocation = [aTouch locationInView:self.view];
	if (self.current != nil) {
		current.center = touchLocation;
	}
	[UIView commitAnimations];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	self.line1 = CGPointMake(-1, -1);
	self.drawingLine = false;
	UITouch * aTouch = [touches anyObject];
	CGPoint touchLocation = [aTouch locationInView:self.view];

	if ([touches count] == 1) {
		if (aTouch.tapCount == 2) {
			[self.delegate removeLine:touchLocation];
			return;
		}
		// This finds if the touch is inside a word. 
		CGRect textFrame;
		
		for (UILabel * w in self.words) {
			//NSLog(@"Touches: %d, Position of word %@: (%.0f, %.0f)", [touches count],w.text, w.center.x, w.center.y);
			
			// if touchLocation is inside the frame of that word
			textFrame = [w frame];
			//[self.delegate addLine:CGPointMake(CGRectGetMinX(textFrame), CGRectGetMinY(textFrame)) end:CGPointMake(CGRectGetMaxX(textFrame), CGRectGetMaxY(textFrame))];
			//[self.delegate drawBox: textFrame];
			if(CGRectContainsPoint(textFrame, touchLocation)){
				self.current = w;
				break;
			}
		}
		// if the touch is not inside a word, then use it to draw a line.
		if (self.current == nil) {
			//NSLog(@"First touch of line\n");
			self.drawingLine = YES;
			self.line1  = CGPointMake(touchLocation.x + [self.delegate getScreenPositionX], touchLocation.y + [self.delegate getScreenPositionY]);
			
		}
		
		self.startingTransform = self.current.transform;
		[self _handleTouch:[touches anyObject]];
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	if ([touches count] == 1) {
		if (self.drawingLine) {
			// Assume there is only one touch at a time
			UITouch * aTouch = [touches anyObject];
			CGPoint touchLocation = [aTouch locationInView:self.view];
			
			self.line2  = CGPointMake(touchLocation.x + [self.delegate getScreenPositionX], touchLocation.y + [self.delegate getScreenPositionY]);
			//add touch to final point and call addline
			[self.delegate setTempLine:self.line1 end:self.line2];
		}
		[self _handleTouch:[touches anyObject]];
	} else {
		CGPoint dummy = CGPointMake(-1, -1);
		[self.delegate setTempLine:dummy end:dummy];
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	if ([touches count] == 1) {
		[UIView beginAnimations:nil context:nil];
		if (self.drawingLine) {
			CGPoint dummy = CGPointMake(-1, -1);
			[self.delegate setTempLine:dummy end:dummy];
			
			// Assume there is only one touch at a time 
			UITouch * aTouch = [touches anyObject];
			CGPoint touchLocation = [aTouch locationInView:self.view];
			
			self.line2  = CGPointMake(touchLocation.x + [self.delegate getScreenPositionX], touchLocation.y + [self.delegate getScreenPositionY]);
			//add touch to final point and call addline
			[self.delegate addLine:self.line1 end:self.line2];
		} else if (current != nil) {
			Frame * center = [wordPositions objectAtIndex:[words indexOfObject:current]];
			CGPoint snapcenter = current.center;
			
			double shiftOffsetX = fmodf([self.delegate getScreenPositionX], self.gridSize);
			double shiftOffsetY = fmodf([self.delegate getScreenPositionY], self.gridSize);
			snapcenter.x = roundf((current.center.x)/self.gridSize)*self.gridSize - shiftOffsetX;
			snapcenter.y = floor ((current.center.y)/(self.gridSize))*self.gridSize+self.gridSize/2 - shiftOffsetY;
			/*if ([self.delegate getScreenPositionX] > 0) {
				snapcenter.x += self.gridSize;
			}
			if ([self.delegate getScreenPositionY] > 0) {
				snapcenter.y += self.gridSize;
			}*/
			
			current.center = snapcenter;
			
			center.x = current.center.x + [self.delegate getScreenPositionX];
			center.y = current.center.y + [self.delegate getScreenPositionY];
			
			[wordPositions replaceObjectAtIndex:[words indexOfObject:current] withObject:center];
			
			[current setNeedsDisplay];
			
			self.current = nil;
		}
	}
	else {
		CGPoint dummy = CGPointMake(-1, -1);
		[self.delegate setTempLine:dummy end:dummy];
		[current setNeedsDisplay];
	}
	
	[UIView commitAnimations];
	[self _handleTouch:[touches anyObject]];
	
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
	//touchesEnded
	NSLog(@"Touches cancelled");
	CGPoint dummy = CGPointMake(-1, -1);
	[self.delegate setTempLine:dummy end:dummy];
	[current setNeedsDisplay];
}

- (void ) updateWordPositioning {
	for(int i = 0; i < [words count]; i++) {
		UILabel * word  = [words objectAtIndex:i];
		Frame   * frame = [wordPositions objectAtIndex:i];
		CGPoint cent;
		
		cent.x = frame.x - [self.delegate getScreenPositionX];
		cent.y = frame.y - [self.delegate getScreenPositionY];
		
		word.center = cent;
	}		
}

- (void)handleTwoFingerDragWith:(UIPanGestureRecognizer *)recognizer {
	// set the screen position
	CGPoint vel = [recognizer velocityInView:self.delegate];
	NSLog(@"2 Touches Moved: (%f, %f)", [self.delegate getScreenPositionX], [self.delegate getScreenPositionY]);
	[self.delegate addToScreenPositionX: vel.x * -0.025 andY: vel.y * -0.025];
	
	// move the words
	[self updateWordPositioning];
}

- (void)handleRotationFrom:(UIRotationGestureRecognizer *)recognizer {

	//NSLog(@"Rotation happening, %@", self.current.text);
		
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
	}
	
}

@end
