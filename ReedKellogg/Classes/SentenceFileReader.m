//
//  SentenceFileReader.m
//  ReedKellogg
//
//  Created by Christopher J. Covert on 5/5/11.
//  Copyright 2011 Rose-Hulman Institute of Technology. All rights reserved.
//

#import "SentenceFileReader.h"
#import "Sentence.h"
#import "Lesson.h"

@implementation SentenceFileReader

- (void) addSentence:(NSString *)sentence toLesson:(NSString *)lesson {
}

- (void) readInFile:(NSString *)filename atPath:(NSString *)path {
	NSString * contents = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", path, filename] encoding:NSUTF8StringEncoding error:nil];
	NSArray  * lines    = [contents componentsSeparatedByString:@"\n"];
	
	NSString * lessonName = [filename stringByDeletingPathExtension];
	
	for (NSString * sentence in lines) {
		[self addSentence:sentence toLesson:lessonName];
	}
	
	NSLog(@"File Read: %@", filename);
}

- (void) readInFiles {
	// find our documents directory
	NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectory = [paths objectAtIndex:0];
	// create an enumerator for that directory
	NSDirectoryEnumerator * enumerator = [[NSFileManager defaultManager] enumeratorAtPath:documentsDirectory];
	
	// loop through all files in the directory
	NSString * filename;
	while (filename = [enumerator nextObject]) {
		// esnure we only grab text files
		if ([[filename pathExtension] isEqualToString:@"txt"]) {
			[self readInFile:filename atPath:documentsDirectory];
		}
	}
}

@end
