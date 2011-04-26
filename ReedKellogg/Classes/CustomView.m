//
//  CustomView.m
//  NavigationTest
//
//  Created by Stephen Mayhew on 1/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CustomView.h"


@implementation CustomView

@synthesize lines;
@synthesize tempLine;
@synthesize gridSize;
@synthesize showGrid;

- (id)initWithFrame:(CGRect)frame {
	showGrid = YES;
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor clearColor];

    }
	self.lines = [NSMutableArray arrayWithCapacity:20];
    return self;
}

//Maintain array of lines

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();

	if(showGrid){
		//draw grid
		
		//vertical
		CGFloat x = 0;
		while (x<self.frame.size.width) {
			CGPoint start;
			start.x = x;
			start.y = 0;
			CGPoint end;
			end.x = x;
			end.y = self.frame.size.height;
			draw1PxStroke(context, start, end, .5, [UIColor cyanColor].CGColor);
			x=x+self.gridSize;
		}
	
		//horizontal 
		CGFloat y = 0;
		while (y<self.frame.size.height) {
			CGPoint start;
			start.x = 0;
			start.y = y;
			CGPoint end;
			end.x = self.frame.size.width;
			end.y = y;
			draw1PxStroke(context, start, end, .5, [UIColor cyanColor].CGColor);
			y=y+self.gridSize;
		}
	}
	if (tempLine != nil) {
		// Draw temp line
		NSValue *start = [self.tempLine objectAtIndex:0];
		NSValue *end = [self.tempLine objectAtIndex:1];
		CGPoint tempStartPoint;
		CGPoint tempEndPoint;
		[start getValue:&tempStartPoint];
		[end getValue:&tempEndPoint];
		draw1PxStroke(context, tempStartPoint, tempEndPoint, 5, [UIColor blackColor].CGColor);
	}	
	
	// Draw out of array
	for(NSArray *line in self.lines){
		NSValue *start = [line objectAtIndex:0];
		NSValue *end = [line objectAtIndex:1];
		CGPoint startPoint;
		CGPoint endPoint;
		[start getValue:&startPoint];
		[end getValue:&endPoint];
		draw1PxStroke(context, startPoint, endPoint, 5, [UIColor blackColor].CGColor);		
	}	
	
	//NSLog(@"Drawing now");
}

void draw1PxStroke(CGContextRef context, CGPoint startPoint, CGPoint endPoint, CGFloat width, CGColorRef color) {
	
    CGContextSaveGState(context);
    CGContextSetLineCap(context, kCGLineCapSquare);
    //CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
	CGContextSetStrokeColorWithColor(context, color);
    CGContextSetLineWidth(context, width);
    CGContextMoveToPoint(context, startPoint.x + 0.5, startPoint.y + 0.5);
    CGContextAddLineToPoint(context, endPoint.x + 0.5, endPoint.y + 0.5);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);        
	
}

- (void)addLine:(CGPoint)begin end:(CGPoint)end{
	begin.x = roundf(begin.x/self.gridSize)*self.gridSize;
	begin.y = roundf(begin.y/self.gridSize)*self.gridSize;
	end.x = roundf(end.x/self.gridSize)*self.gridSize;
	end.y = roundf(end.y/self.gridSize)*self.gridSize;
	
	/* Old snapping code
	// If the distance is less than 15, then don't even
	// draw the line. Typically, a double-tap will happen within
	// a distance of 15, so this excludes double-taps.
	if ([self distanceP1:begin P2:end] < 30) {
		return;
	}
	
	BOOL horiz = NO;
	BOOL vert = NO;
	
	// Consider moving all this to a snap function
	// Modify so if lines are close to horizontal, they will snap to
	int snapAmount = 40;
	if (fabs(begin.x - end.x) < snapAmount && [self distanceP1:begin P2:end] > 1.5*snapAmount) {
		end.x = begin.x;
		vert = YES;
	}
	
	// ...or close to vertical
	if (fabs(begin.y - end.y) < snapAmount && [self distanceP1:begin P2:end] > 1.5*snapAmount) {
		end.y = begin.y;
		horiz = YES;
	}
	
	// If a line endpoint is near another line, then snap to it. 
	for(NSArray *line in lines){
		NSValue *startLine = [line objectAtIndex:0];
		NSValue *endLine = [line objectAtIndex:1];
		
		CGPoint startPoint;
		CGPoint endPoint;
		[startLine getValue:&startPoint];
		[endLine getValue:&endPoint];
		
		// get slope and intercept from line
		float rise = (endPoint.y - startPoint.y);
		float run = (endPoint.x - startPoint.x);
		float slope =  rise / run; 
		float intercept = startPoint.y - startPoint.x * slope;
		int dist = [self distanceP1:begin P2:end];
		int moveAmount = dist / sqrt(2);
		
		if ([self touchNearLine:begin p1:startPoint p2:endPoint]) {
			begin.y = slope * begin.x + intercept;
			
			//	if necessary, change end as well, to keep line vert. or horiz.
			if (vert) {
				// move end to be have the same y
				end.y = begin.y;
			}else if (horiz) {
				// move end to have the same x
				end.x = begin.x;
			}else {
				// Make end at 45 degrees, with the same distance
				// deal with quadrant
				int xsign = (end.x - begin.x)/fabs(end.x - begin.x);
				int ysign = (end.y - begin.y)/fabs(end.y - begin.y);
				
				end.x = begin.x + xsign*moveAmount;
				end.y = begin.y + ysign*moveAmount;
				
			}

			//we only want to snap to one line...
			break;
		}
		
		if ([self touchNearLine:end p1:startPoint p2:endPoint]) {

			// keep begin.x the same
			// compute y
			end.y = slope * end.x + intercept;
			
			//	if necessary, change begin as well, to keep line vert. or horiz.
			if (vert) {
				// move begin to be have the same y
				begin.y = end.y;
			}else if (horiz) {
				// move end to have the same x
				begin.x = end.x;
			}else {
				// Make end at 45 degrees, with the same distance
				// deal with quadrant
				int xsign = (begin.x - end.x)/fabs(begin.x - end.x);
				int ysign = (begin.y - end.y)/fabs(begin.y - end.y);
				
				begin.x = end.x + xsign*moveAmount;
				begin.y = end.y + ysign*moveAmount;
			}
			
			
			
			
			//	move it so it touches the line
			//	if necessary, change begin as well, to keep line vert. or horiz.
			NSLog(@"End should move to be near line");
			//we only want to snap to one line...
			break;
		}	
		
		// If they are both touching, then...move both until they touch, and are straight
	}
	*/
	
	NSLog(@"added line. dist: %d", [self distanceP1:begin P2:end]);
	
	// This is a little clunky, but a line is represented as an NSArray of
	// NSValues which encapsulate CGPoints, which are the endpoints
	NSArray *line = [NSArray arrayWithObjects:
					   [NSValue valueWithCGPoint:begin],
					   [NSValue valueWithCGPoint:end],
					   nil];

	
	[lines addObject:line];
	//NSLog(@"Addline: p1: (%.0f, %.0f),  p2: (%.0f, %.0f)\nLines size: %d", begin.x, begin.y, end.x, end.y, [lines count]);
	[self setNeedsDisplay];
}

// The temp line is what you see as you drag your finger from the first point
// to the next. If this didn't exist, no line would be drawn until the touches ended.
- (void)setTempLine:(CGPoint)begin end:(CGPoint)end{
	
	if (begin.x == -1) {
		self.tempLine = nil;
	}else{
		self.tempLine = [NSArray arrayWithObjects:
					 [NSValue valueWithCGPoint:begin],
					 [NSValue valueWithCGPoint:end],
					 nil];
	
		[self setNeedsDisplay];
	}
}

-(void)removeLine:(CGPoint)touch{
	
	for(NSArray *line in lines){
		NSValue *start = [line objectAtIndex:0];
		NSValue *end = [line objectAtIndex:1];
		
		CGPoint startPoint;
		CGPoint endPoint;
		[start getValue:&startPoint];
		[end getValue:&endPoint];
		
		// Make bounding box using startPoint and endPoint
		// Is touch inside bounding box?
		if ([self touchNearLine:touch p1:startPoint p2:endPoint]) {
			[lines removeObject:line];
			NSLog(@"Line removed");
			[self setNeedsDisplay];
			return;
		}
	}
	
	NSLog(@"removeline called. Lines: %d", [lines count]);	
}

-(NSMutableArray *)getLineList{
	return lines;
}

- (BOOL) showGrid
{
	return showGrid;
}

-(void) removeAll{
	//NSLog(@"Remove all");
	[lines removeAllObjects];
	[self setNeedsDisplay];
}


// This is used for removing lines (by a double-tap) but could also be used
// for changing line position
- (BOOL) touchNearLine:(CGPoint) touch p1:(CGPoint) p1 p2:(CGPoint) p2{
	
	//on the line
	float rise = (p2.y - p1.y);
	float run = (p2.x - p1.x);
	float slope =  rise / run; 
	float intercept = p1.y - p1.x * slope;
	
	BOOL vertical = NO;
	BOOL horizontal = NO;
	
	if(fabs(slope) == INFINITY){
		vertical = YES;
	}
	
	// Turns out there is such thing as -0
	if (fabs(slope) == 0) {
		horizontal = YES;
	}
	
	
	// within the box - WARNING! Makes horizontal and vertical touches remove nothing
	
	// If the touch is not between the x points of the start and end, then return
	// Ignore if line is vertical 
	if (!vertical && !(fmin(p1.x, p2.x) < touch.x && touch.x < fmax(p1.x, p2.x))){
		return NO;
	}
		  
	// If the touch is not between the x points of the start and end, then return
	// Ignore if line is horizontal
	if(!horizontal && !(fmin(p1.y, p2.y) < touch.y && touch.y < fmax(p1.y, p2.y))){
		return NO;
	}
	

	
	int distFromLine = 25;
	// Because of the snap, the line is probably vertical, so it will have a high slope
	if (vertical) {
		BOOL left = touch.x < p1.x + distFromLine;
		BOOL right = touch.x > p1.x - distFromLine;
		
		return left && right;
	}
	
	
	BOOL above = (touch.y - distFromLine) < (slope*touch.x + intercept);
	BOOL below = (touch.y + distFromLine) > (slope*touch.x + intercept);
	
	// I know this isn't the prettiest, but I know it works.
	return above && below;
}

-(int) distanceP1:(CGPoint) p1 P2: (CGPoint)p2{
	
	return sqrt(pow(p1.x - p2.x,2) + pow(p1.y-p2.y,2));
	
}


- (void)dealloc {
	[lines dealloc];
    [super dealloc];
}


@end
