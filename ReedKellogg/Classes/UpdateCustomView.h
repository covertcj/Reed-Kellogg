//
//  UpdateCustomView.h
//  NavigationTest
//
//  Created by Stephen Mayhew on 1/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol UpdateCustomView

- (void)addLine:(CGPoint)begin end:(CGPoint)end;

- (void)setTempLine:(CGPoint)begin end:(CGPoint)end;

-(void)removeLine:(CGPoint)touch;

-(void)removeAll;
/*
- (CGFloat) getScreenPositionX;
- (CGFloat) getScreenPositionY;
- (void) setGridSize: (int) size;
- (BOOL) showGrid;
- (void) setShowGrid: (BOOL) flag;*/

@end
