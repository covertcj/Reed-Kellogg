// 
//  Student.m
//  NavigationTest
//
//  Created by Stephen Mayhew on 2/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Student.h"


@implementation Student 

@dynamic name;
@dynamic ID;

- (NSString *)description {
	return self.name;
}


@end
