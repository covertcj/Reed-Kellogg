//
//  SentenceFileReader.h
//  ReedKellogg
//
//  Created by Christopher J. Covert on 5/5/11.
//  Copyright 2011 Rose-Hulman Institute of Technology. All rights reserved.
//

@class Sentence, Lesson;

@interface SentenceFileReader : NSObject {
}

- (void) addSentence:(NSString *)sentence toLesson:(NSString *)lesson;
- (void) readInFile:(NSString *)filename atPath:(NSString *)path;
- (void) readInFiles;

@end
