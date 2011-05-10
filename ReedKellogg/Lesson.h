//
//  Lesson.h
//  ReedKellogg
//
//  Created by Christopher J. Covert on 5/9/11.
//  Copyright 2011 Rose-Hulman Institute of Technology. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Sentence;

@interface Lesson :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet* sentences;

@end


@interface Lesson (CoreDataGeneratedAccessors)
- (void)addSentencesObject:(Sentence *)value;
- (void)removeSentencesObject:(Sentence *)value;
- (void)addSentences:(NSSet *)value;
- (void)removeSentences:(NSSet *)value;

@end

