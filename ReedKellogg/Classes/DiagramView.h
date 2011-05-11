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
	NSMutableArray * dashedLines;
	Line           * tempLine;
	Line           * touchedLine;
	
	BOOL showGrid;
	BOOL tempDashed;
	CGFloat gridSize;
}

@property (nonatomic, retain) NSMutableArray * lines;
@property (nonatomic, retain) NSMutableArray * dashedLines;
@property (nonatomic, retain) Line           * tempLine;
@property (nonatomic, retain) Line           * touchedLine;

@property (nonatomic) BOOL showGrid;
@property (nonatomic) BOOL tempDashed;
@property (nonatomic) CGFloat gridSize;

- (void) setupView;

- (void) drawLine:(Line *)line withWidth:(CGFloat)width color:(CGColorRef)color context:(CGContextRef)context dashed:(BOOL)dashed;
- (void) addLine:(Line *)line dashed:(BOOL)dashed;
- (void) setTemp:(Line *)line dashed:(BOOL)dashed;
- (void) removeLine:(Line *)line;
- (BOOL) touch:(CGPoint)touch nearLine:(Line *)line;
- (void) removeAllLines;
- (CGPoint) snapToGrid:(CGPoint)point;

@end
