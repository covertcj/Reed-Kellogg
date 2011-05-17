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

- (Lesson *) addLesson:(NSString *)lesson {
	// create the request
	NSFetchRequest * request = [[[NSFetchRequest alloc] init] autorelease];
	[request setEntity:[NSEntityDescription entityForName:@"Lesson" inManagedObjectContext:self.managedObjectContext]];
	[request setPredicate:[NSPredicate predicateWithFormat:@"name == %@", lesson]];
	
	// query core data
	NSError * error;
	NSArray * results = [managedObjectContext executeFetchRequest:request error:&error];
	
	NSLog(@"addLesson: %@", results);
	
	// ensure the lesson doesn't exist yet
	if([results count] == 0) {
		NSObject *o = [NSEntityDescription insertNewObjectForEntityForName:@"Lesson" inManagedObjectContext:self.managedObjectContext];	
		Lesson * l = (Lesson *) o;
		[l setName:lesson];
		
		NSError *error = nil;
		if (![self.managedObjectContext save:&error]) {
			// Handle the error.
		}
		
		return l;
	}
	
	return nil;
}

- (void) addSentence:(NSString *)sentence toLesson:(Lesson *)lesson sentenceNumber:(int)n {
	Sentence *s = [NSEntityDescription insertNewObjectForEntityForName:@"Sentence" inManagedObjectContext:self.managedObjectContext];	
	[s setText:sentence];
	[s setNumber:[NSNumber numberWithInt:n]];
	[lesson addSentencesObject:s];
	NSError * error = nil;
	[self.managedObjectContext save:&error];
}

- (void) readInFile:(NSString *)filename atPath:(NSString *)path {
	NSString * contents = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", path, filename] encoding:NSUTF8StringEncoding error:nil];
	NSArray  * lines    = [contents componentsSeparatedByString:@"\n"];
	
	Lesson * lesson     = [self addLesson:[filename stringByDeletingPathExtension]];
	
	// if the lesson already existed, quit
	if (lesson == nil) {
		return;
	}
	
	// add the sentences
	int i = 1;
	for (NSString * sentence in lines) {
		if (![sentence isEqualToString:@""]) {
			[self addSentence:sentence toLesson:lesson sentenceNumber: i];
			i++;
		}
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
