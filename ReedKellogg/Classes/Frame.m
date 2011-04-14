//
//  Rect.m
//  ReedKellogg
//
//  Created by Christopher J. Covert on 4/13/11.
//  Copyright 2011 Rose-Hulman Institute of Technology. All rights reserved.
//

#import "Frame.h"

@implementation Frame

@synthesize x, y;

- (Frame *) initWithX:(int)_x Y:(int)_y {
	self.x      = _x;
	self.y      = _y;
	
	return self;
}

@end
