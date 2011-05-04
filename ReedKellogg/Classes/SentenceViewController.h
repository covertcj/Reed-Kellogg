//
//  NewViewController.h
//  NavigationTest
//
//  Created by Stephen Mayhew on 1/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Student.h"
#import "Lesson.h"
#import "GenericTableView.h"

@interface SentenceViewController : GenericTableView {
	Student *currStudent;
	Lesson *currLesson;
}

@property (nonatomic, retain) Student *currStudent;
@property (nonatomic, retain) Lesson *currLesson;

- (void) updateTitle;

@end
