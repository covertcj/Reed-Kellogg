    //
//  TouchViewController.m
//  NavigationTest
//
//  Created by Stephen Mayhew on 1/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TouchViewController.h"
#import "NavigationTestAppDelegate.h"
#import "CustomView.h"
#import "Layout.h"
#import "WordData.h"
#import "LineData.h"

@implementation TouchViewController

@synthesize words;
@synthesize current;
@synthesize biasX;
@synthesize biasY;
@synthesize textField;
@synthesize submit;
@synthesize linesView;
@synthesize startingTransform;
@synthesize line1;
@synthesize line2;
@synthesize managedObjectContext;

@synthesize TeacherMode;

@synthesize delegate = _delegate;

@synthesize currStudent;
@synthesize currLesson;
@synthesize currSentence;


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
	
	NSLog(@"Student: %@, Lesson: %@, Sentence: %@", self.currStudent.name, self.currLesson.name, self.currSentence.text);
	
	CustomView *myView = [[[CustomView alloc] init] autorelease];
	self.view = myView;
	self.delegate = myView;

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
	UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next"
																   style:UIBarButtonItemStylePlain
																   target:self
																  action:@selector(pressNext:)];

	
	UIBarButtonItem *prevButton = [[UIBarButtonItem alloc] initWithTitle:@"Prev"
																   style:UIBarButtonItemStylePlain
																  target:self
																  action:@selector(pressPrev:)];
	
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
									initWithBarButtonSystemItem:UIBarButtonSystemItemSave
									target:self action:@selector(pressSave:)];
	
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
	fixedItem.width = 50;	
	
	//Add buttons to the array
	NSArray *items = [NSArray arrayWithObjects: flexItem, prevButton, fixedItem, saveButton, fixedItem, nextButton, flexItem, nil];
	
	//release buttons
	[prevButton release];
	[saveButton release];
	[nextButton release];
	[flexItem release];
	[fixedItem release];
	
	//add array of buttons to toolbar
	[toolbar setItems:items animated:NO];
	
	[self.view addSubview:toolbar];
	
	
	[self fetchWordsAndSetLayout];
	
	
	
	UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Reset"
															style:UIBarButtonItemStyleBordered
														   target:self
														   action:@selector(reset:)]; 
		
	self.navigationItem.rightBarButtonItem = temporaryBarButtonItem;
	
	[temporaryBarButtonItem release];	
	
	//NSLog(@"self.words has %@ objects in it.", words);
	
	UIGestureRecognizer *recognizer;
	
	recognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotationFrom:)];
	[self.view addGestureRecognizer:recognizer];
	[recognizer release];
}

-(void) fetchWordsAndSetLayout
{
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
- (void) pressSave:(id)sender{
	NSLog(@"Save Pressed");
	// Make sure that we override any previous entries that have the same creator and sentence
	NSFetchRequest * request = [[[NSFetchRequest alloc] init] autorelease];
	[request setPredicate:[NSPredicate predicateWithFormat:@"creator == %@ AND sentence == %@",currStudent,currSentence]];
	[request setEntity:[NSEntityDescription entityForName:@"Layout" inManagedObjectContext:managedObjectContext]];
	NSError * error;
	NSArray * results = [managedObjectContext executeFetchRequest:request error:&error];
	for(Layout *l in results){
		[managedObjectContext deleteObject:l];
	}	
	
	error = nil;
	
	if (![managedObjectContext save:&error]) {
		NSLog(@"Deletion failed (deletion): %@, %@", error, [error userInfo]);		
	}
	
	
	Layout *layout = (Layout *)[NSEntityDescription insertNewObjectForEntityForName:@"Layout" inManagedObjectContext:managedObjectContext];
	layout.creator = currStudent;
	layout.sentence = currSentence;
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
	
	error = nil;
	
	if (![managedObjectContext save:&error]) {
		
		NSLog(@"Error saving...");
		NSLog(@"Operation failed: %@, %@", error, [error userInfo]);

		
	}
	
	
}



-(void) setWordLayout:(Layout *) layout
{
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
					
					newFrame.origin.x = [wd.wdx floatValue];
					newFrame.origin.y = [wd.wdy floatValue];
					
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
-(void)reset:(id) sender
{
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

-(void) _handleTouch:(UITouch *) aTouch
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:200];


	CGPoint touchLocation = [aTouch locationInView:self.view];
	if (self.current != nil) {
		// Use the bias to move the center to.
		CGPoint locWithBias;
		locWithBias.x = touchLocation.x - biasX;
		locWithBias.y = touchLocation.y - biasY;
		self.current.center = locWithBias;
	}
	
	[UIView commitAnimations];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	self.line1  = CGPointMake(-1, -1);
	UITouch * aTouch = [touches anyObject];
	CGPoint touchLocation = [aTouch locationInView:self.view];

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
		if(CGRectContainsPoint(textFrame, touchLocation)){
			self.current = w;
			break;
		}
	}
	// if the touch is not inside a word, then use it to draw a line.
	if (self.current == nil) {
		//NSLog(@"First touch of line\n");
		self.line1  = CGPointMake(touchLocation.x, touchLocation.y);
		
	}
	

	self.startingTransform = self.current.transform;
	
	// set bias as the difference from the center of the touchLocation, and the center of the frame
	self.biasX = touchLocation.x - self.current.center.x;
	self.biasY = touchLocation.y - self.current.center.y;
	
	
	
	[self _handleTouch:[touches anyObject]];
	
	
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (self.line1.x != -1) {
		// Assume there is only one touch at a time
		UITouch * aTouch = [touches anyObject];
		CGPoint touchLocation = [aTouch locationInView:self.view];
		
		self.line2  = CGPointMake(touchLocation.x, touchLocation.y);
		//add touch to final point and call addline
		[self.delegate setTempLine:self.line1 end:self.line2];
	}
	
	
	[self _handleTouch:[touches anyObject]];
	
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	
	if (self.line1.x != -1) {
		CGPoint dummy = CGPointMake(-1, -1);
		[self.delegate setTempLine:dummy end:dummy];
		
		// Assume there is only one touch at a time
		UITouch * aTouch = [touches anyObject];
		CGPoint touchLocation = [aTouch locationInView:self.view];
		
		self.line2  = CGPointMake(touchLocation.x, touchLocation.y);
		//add touch to final point and call addline
		[self.delegate addLine:self.line1 end:self.line2];
	}
	
	self.current = nil;
	self.biasX = 0;
	self.biasY = 0;
	[self _handleTouch:[touches anyObject]];
	
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	//touchesEnded
	NSLog(@"Touches cancelled");
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