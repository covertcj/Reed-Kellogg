//
//  Lesson.h
//  NavigationTest
//
//  Created by Stephen Mayhew on 2/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Sentence;

@interface Lesson :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) NSSet* sentences;

@end


@interface Lesson (CoreDataGeneratedAccessors)
- (void)addSentencesObject:(Sentence *)value;
- (void)removeSentencesObject:(Sentence *)value;
- (void)addSentences:(NSSet *)value;
- (void)removeSentences:(NSSet *)value;

@end

