//
//  Line.h
//  ReedKellogg
//
//  Created by Christopher J. Covert on 4/23/11.
//  Copyright 2011 Rose-Hulman Institute of Technology. All rights reserved.
//

@interface Line : NSObject {
	CGPoint start;
	CGPoint end;
}

@property (nonatomic) CGPoint start;
@property (nonatomic) CGPoint end;

@end
