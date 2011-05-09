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
@synthesize managedObjectContext;

- (Lesson *) addLesson:(NSString *)lesson{
	NSObject *o = [NSEntityDescription insertNewObjectForEntityForName:@"Lesson" inManagedObjectContext:self.managedObjectContext];	
	Lesson * l = (Lesson *) o;
	[l setName:lesson];
	[l setNumber:[NSNumber numberWithInt:1]];
	
	NSError *error = nil;
	if (![self.managedObjectContext save:&error]) {
		// Handle the error.
	}
	return l;
}

- (void) addSentence:(NSString *)sentence toLesson:(Lesson *)lesson sentenceNumber:n{
	Sentence *s = [NSEntityDescription insertNewObjectForEntityForName:@"Sentence" inManagedObjectContext:self.managedObjectContext];	
	[s setText:sentence];
	[s setNumber:n];
	[lesson addSentencesObject:s];
}

- (void) readInFile:(NSString *)filename atPath:(NSString *)path {
	NSString * contents = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", path, filename] encoding:NSUTF8StringEncoding error:nil];
	NSArray  * lines    = [contents componentsSeparatedByString:@"\n"];
	
	NSString * lessonName = [filename stringByDeletingPathExtension];
	int i = 0;
	for (NSString * sentence in lines) {
		[self addSentence:sentence toLesson:lessonName sentenceNumber: i];
		i++;
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
