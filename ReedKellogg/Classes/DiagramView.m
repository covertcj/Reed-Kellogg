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

@synthesize lines, tempLine;
@synthesize showGrid, gridSize;


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
    }
	
    return self;
}

- (void) setupView {
	// set the size of the window
	CGRect viewFrame       = self.frame;
	viewFrame.size.width  *= 3.0f;
	viewFrame.size.height *= 1.5f;
	self.contentSize = CGSizeMake(viewFrame.size.width, viewFrame.size.height);
	
	// set the grid size
	self.gridSize     = 40;
	self.showGrid     = YES;
	
	// allow only two finger scrolling
	self.multipleTouchEnabled  = YES;
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
	
	// draw the temporary line
	if (self.tempLine != nil) {
		[self drawLine:self.tempLine withWidth:4.0f andColor:[UIColor blackColor].CGColor andContext:context];
	}
	
	// Draw the array of lines
	for (Line * line in self.lines) {
		[self drawLine:line withWidth:4.0f andColor:[UIColor blackColor].CGColor andContext:context];
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
	NSLog(@"addLineLine: (%f, %f) to (%f, %f)", line.start.x, line.start.y, line.end.x, line.end.y);
	
	NSLog(@"addLine: %@", self.lines);
	
	// TODO: Implement DiagramView.addLine
	if (self.lines == nil) {
		self.lines = [[NSMutableArray alloc] init];
	}
	
	Line * myline  = [[Line alloc] init];
	myline.start   = CGPointMake(roundf(line.start.x / self.gridSize) * self.gridSize, roundf(line.start.y / self.gridSize) * self.gridSize);
	myline.end     = CGPointMake(roundf(line.end.x   / self.gridSize) * self.gridSize, roundf(line.end.y   / self.gridSize) * self.gridSize);
	[self.lines addObject:myline];
	
	NSLog(@"addLine2: %@", self.lines);
	
	[self setNeedsDisplay];
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

- (void) removeAllLines {
	if (self.lines != nil) {
		for (Line * line in self.lines) {
			[line release];
		}
		
		[self.lines removeAllObjects];
		[self setNeedsDisplay];
	}
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
/*
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[self.nextResponder touchesBegan:touches withEvent:event];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	[self.nextResponder touchesMoved:touches withEvent:event];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[self.nextResponder touchesEnded:touches withEvent:event];
}
- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
	return NO;
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
