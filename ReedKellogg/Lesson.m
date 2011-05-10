// 
//  Lesson.m
//  ReedKellogg
//
//  Created by Christopher J. Covert on 5/9/11.
//  Copyright 2011 Rose-Hulman Institute of Technology. All rights reserved.
//

#import "Lesson.h"

#import "Sentence.h"

@implementation Lesson 

@dynamic name;
@dynamic sentences;

- (NSString *) description {
	return self.name;
}

@end
