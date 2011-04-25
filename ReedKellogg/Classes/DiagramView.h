//
//  DiagramView.h
//  ReedKellogg
//
//  Created by Christopher J. Covert on 4/14/11.
//  Copyright 2011 Rose-Hulman Institute of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Line;

@interface DiagramView : UIScrollView {
	NSMutableArray * lines;
	Line           * tempLine;
	
	BOOL showGrid;
	CGFloat gridSize;
}

@property (nonatomic, retain) NSMutableArray * lines;
@property (nonatomic, retain) Line           * tempLine;

@property (nonatomic) BOOL showGrid;
@property (nonatomic) CGFloat gridSize;

- (void) drawLine:(Line *)line withWidth:(CGFloat)width andColor:(CGColorRef)color andContext:(CGContextRef)context;
- (void) addLine:(Line *)line;
- (void) setTemp:(Line *)line;
- (void) removeAllLines;
- (Line *) lineAt:(CGPoint)touch;

@end
