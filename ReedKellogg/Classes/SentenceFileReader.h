//
//  SentenceFileReader.h
//  ReedKellogg
//
//  Created by Christopher J. Covert on 5/5/11.
//  Copyright 2011 Rose-Hulman Institute of Technology. All rights reserved.
//

@class Sentence, Lesson;

@interface SentenceFileReader : NSObject {
	NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (Lesson *) addLesson:(NSString *)lesson;
- (void) addSentence:(NSString *)sentence toLesson:(NSString *)lesson sentenceNumber:n;
- (void) readInFile:(NSString *)filename atPath:(NSString *)path;
- (void) readInFiles;

@end
