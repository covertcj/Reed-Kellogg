//
//  Rect.h
//  ReedKellogg
//
//  Created by Christopher J. Covert on 4/13/11.
//  Copyright 2011 Rose-Hulman Institute of Technology. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Frame : NSObject {
	int x, y;
}

- (Frame *) initWithX:(int)_x Y:(int)_y Width:(int)w Height:(int)h;

@property (nonatomic) int x;
@property (nonatomic) int y;

@end
