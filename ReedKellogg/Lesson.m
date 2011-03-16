// 
//  Lesson.m
//  NavigationTest
//
//  Created by Stephen Mayhew on 2/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Lesson.h"

#import "Sentence.h"

@implementation Lesson 

@dynamic name;
@dynamic number;
@dynamic sentences;

- (NSString *)description {
	return [NSString stringWithFormat:@"%@ - %@",self.number, self.name];
}

@end
