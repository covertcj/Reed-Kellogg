// 
//  Sentence.m
//  NavigationTest
//
//  Created by Stephen Mayhew on 2/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Sentence.h"


@implementation Sentence 

@dynamic number;
@dynamic text;

- (NSString *)description {
	return [NSString stringWithFormat:@"%@ - %@", self.number, self.text];
}

@end
