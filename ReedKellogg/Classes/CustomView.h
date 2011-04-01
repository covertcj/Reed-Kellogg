//
//  CustomView.h
//  NavigationTest
//
//  Created by Stephen Mayhew on 1/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UpdateCustomView.h"
#import "math.h"


@interface CustomView : UIView <UpdateCustomView> {

	NSMutableArray *lines;
	NSArray * tempLine;
	int gridSize;
	
}

@property (nonatomic, retain) NSMutableArray *lines;
@property (nonatomic, retain) NSArray *tempLine;


void draw1PxStroke(CGContextRef context, CGPoint startPoint, CGPoint endPoint);

-(BOOL) touchNearLine:(CGPoint) touch p1:(CGPoint) p1 p2:(CGPoint) p2;
-(int) distanceP1:(CGPoint) p1 P2: (CGPoint)p2;
void drawBox(CGContextRef context,CGRect rect);
@end
