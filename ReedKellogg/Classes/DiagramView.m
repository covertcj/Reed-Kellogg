//
//  DiagramView.m
//  ReedKellogg
//
//  Created by Christopher J. Covert on 4/14/11.
//  Copyright 2011 Rose-Hulman Institute of Technology. All rights reserved.
//

#import "DiagramView.h"

#import "Line.h"

@implementation DiagramView

@synthesize lines, tempLine, touchedLine;
@synthesize showGrid, gridSize;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
    }
	
    return self;
}

- (void) setupView {
	// set the size of the window
	self.gridSize     = 40;
	CGRect viewFrame       = self.frame;
	viewFrame.size.width  *= 3.0f;
	viewFrame.size.height *= 1.5f;
	self.contentSize = CGSizeMake(viewFrame.size.width, viewFrame.size.height);
	// set the grid size
	self.showGrid     = YES;
	
	// allow only two finger scrolling
	for (id gestureRecognizer in self.gestureRecognizers) {     
		if ([gestureRecognizer  isKindOfClass:[UIPanGestureRecognizer class]])
		{
			UIPanGestureRecognizer * panGR = gestureRecognizer;
			panGR.minimumNumberOfTouches   = 2;
			panGR.maximumNumberOfTouches   = 2;
		}
    }
	
	[self setNeedsDisplay];
}

- (void) drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// draw the grid
	if (showGrid) {
		// vertical lines
		CGFloat x = 0;
		while (x < self.contentSize.width) {
			// draw a single grid line
			CGPoint start = CGPointMake(x, 0);
			CGPoint end   = CGPointMake(x, self.contentSize.height);
			Line * gridLine = [[Line alloc] init];
			gridLine.start  = start;
			gridLine.end    = end;
			[self drawLine:gridLine withWidth:0.5f andColor:[UIColor cyanColor].CGColor andContext:context];
			[gridLine release];
			
			x            += self.gridSize;
		}
		
		// horizontal lines
		CGFloat y = 0;
		while (y < self.contentSize.height) {
			// draw a single grid line
			CGPoint start   = CGPointMake(0, y);
			CGPoint end     = CGPointMake(self.contentSize.width, y);
			Line * gridLine = [[Line alloc] init];
			gridLine.start  = start;
			gridLine.end    = end;
			[self drawLine:gridLine withWidth:0.5f andColor:[UIColor cyanColor].CGColor andContext:context];
			[gridLine release];
			
			y            += self.gridSize;
		}
	}
	int k = self.contentSize.width/self.gridSize;
	
	//draw diagnols
	/*
	CGFloat b = -k*gridSize;
	while (b < self.contentSize.height) {
		// draw a single grid line
		CGPoint start = CGPointMake(0, b);
		CGPoint end   = CGPointMake(self.contentSize.height - b, self.contentSize.height);
		Line * gridLine = [[Line alloc] init];
		gridLine.start  = start;
		gridLine.end    = end;
		[self drawLine:gridLine withWidth:0.5f andColor:[UIColor redColor].CGColor andContext:context];
		[gridLine release];
		b            += self.gridSize;
	}*/
	
	
	// draw the temporary line
	if (self.tempLine != nil) {
		[self drawLine:self.tempLine withWidth:4.0f andColor:[UIColor blackColor].CGColor andContext:context];
	}
	
	// Draw the array of lines
	for (Line * line in self.lines) {
		if (self.touchedLine == line) {
			[self drawLine:line withWidth:4.0f andColor:[UIColor blueColor].CGColor andContext:context];
		}
		else {
			[self drawLine:line withWidth:4.0f andColor:[UIColor blackColor].CGColor andContext:context];
		}
	}
}

- (void) drawLine:(Line *)line withWidth:(CGFloat)width andColor:(CGColorRef)color andContext:(CGContextRef)context {
	// TODO: Implement DiagramView.DrawLine
    CGContextSaveGState(context);
	CGContextSetLineCap(context, kCGLineCapSquare);
	CGContextSetStrokeColorWithColor(context, color);
    CGContextSetLineWidth(context, width);
    CGContextMoveToPoint(context, line.start.x + 0.5, line.start.y + 0.5);
    CGContextAddLineToPoint(context, line.end.x + 0.5, line.end.y + 0.5);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}

- (void) addLine:(Line *)line {
	// TODO: Implement DiagramView.addLine
	if (self.lines == nil) {
		self.lines = [[NSMutableArray alloc] init];
	}
	
	Line * myline  = [[Line alloc] init];
	myline.start   = line.start;
	myline.start   = [self snapToGrid:myline.start];
	myline.end     = line.end;
	myline.end     = [self snapToGrid:myline.end];
	[self snapToGrid:myline.end];
	[self.lines addObject:myline];
	NSLog(@"adding line from (%f, %f) to (%f, %f)",myline.start.x, myline.start.y, myline.end.x, myline.end.y);
	[self setNeedsDisplay];
}

- (CGPoint) snapToGrid:(CGPoint) p{
	p.x = roundf(p.x / self.gridSize) * self.gridSize;
	p.y = roundf(p.y / self.gridSize) * self.gridSize;
									
	return p;
}

- (void) setTemp:(Line *)line {
	if (line == nil) {
		self.tempLine = nil;
		[self.tempLine release];
		return;
	}
	
	if (self.tempLine == nil) {
		self.tempLine = [[Line alloc] init];
	}
	
	self.tempLine.start = line.start;
	self.tempLine.end   = line.end;
	
	[self setNeedsDisplay];
	
}

- (void) removeLine:(Line *)line {
	Line * toRemove;
	
	for (Line * storedLine in self.lines) {
		if (line.start.x == storedLine.start.x &&
			line.start.y == storedLine.start.y &&
			line.end.x   == storedLine.end.x   &&
			line.end.y   == storedLine.end.y) {
			
			toRemove     = line;
			break;
		}
	}
	
	if (toRemove != nil) {
		[self.lines removeObject:toRemove];
		toRemove  = nil;
		[toRemove release];
	}
	
	self.touchedLine = nil;
	[self setNeedsDisplay];
}

- (BOOL) touch:(CGPoint)touch nearLine:(Line *)line {
	CGPoint p1 = line.start;
	CGPoint p2 = line.end;
	
	//on the line
	float rise      = (p2.y - p1.y);
	float run       = (p2.x - p1.x);
	float slope     =  rise / run; 
	float intercept =  p1.y - p1.x * slope;
	
	BOOL vertical = NO;
	BOOL horizontal = NO;
	
	if(fabs(slope) == INFINITY) {
		vertical   = YES;
	}
	
	// Turns out there is such thing as -0
	if (fabs(slope) == 0) {
		horizontal = YES;
	}
	
	
	// within the box - WARNING! Makes horizontal and vertical touches remove nothing
	
	// If the touch is not between the x points of the start and end, then return
	// Ignore if line is vertical 
	if (!vertical  && !(fmin(p1.x, p2.x) < touch.x && touch.x < fmax(p1.x, p2.x))) {
		return NO;
	}
	
	// If the touch is not between the x points of the start and end, then return
	// Ignore if line is horizontal
	if(!horizontal && !(fmin(p1.y, p2.y) < touch.y && touch.y < fmax(p1.y, p2.y))) {
		return NO;
	}
	
	
	
	int distFromLine = 25;
	// Because of the snap, the line is probably vertical, so it will have a high slope
	if (vertical) {
		BOOL left  = touch.x < p1.x + distFromLine;
		BOOL right = touch.x > p1.x - distFromLine;
		
		return left && right;
	}
	
	
	BOOL above = (touch.y - distFromLine) < (slope * touch.x + intercept);
	BOOL below = (touch.y + distFromLine) > (slope * touch.x + intercept);
	
	// I know this isn't the prettiest, but I know it works.
	return above && below;
}

- (void) removeAllLines {
	[lines removeAllObjects];
	[self setNeedsDisplay];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark -
#pragma mark Event Passing

/*- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesBegan:touches withEvent:event];
	NSLog(@"began: %d", [touches count]);
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesMoved:touches withEvent:event];
	NSLog(@"moved: %d", [touches count]);
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesEnded:touches withEvent:event];
	NSLog(@"ended: %d", [touches count]);
}*/

- (void)dealloc {
	if (self.lines    != nil) {
		[self.lines    removeAllObjects];
		self.lines     = nil;
		[self.lines    release];
	}
	
	if (self.tempLine != nil) {
		self.tempLine  = nil;
		[self.tempLine release];
	}
	
    [super dealloc];
}


@end
