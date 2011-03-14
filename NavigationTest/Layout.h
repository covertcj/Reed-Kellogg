//
//  Layout.h
//  NavigationTest
//
//  Created by Stephen Mayhew on 2/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class LineData;
@class Sentence;
@class Student;
@class WordData;

@interface Layout :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * Comments;
@property (nonatomic, retain) NSString * grade;
@property (nonatomic, retain) NSSet* LinesData;
@property (nonatomic, retain) Student * creator;
@property (nonatomic, retain) NSSet* WordsData;
@property (nonatomic, retain) Sentence * sentence;

@end


@interface Layout (CoreDataGeneratedAccessors)
- (void)addLinesDataObject:(LineData *)value;
- (void)removeLinesDataObject:(LineData *)value;
- (void)addLinesData:(NSSet *)value;
- (void)removeLinesData:(NSSet *)value;

- (void)addWordsDataObject:(WordData *)value;
- (void)removeWordsDataObject:(WordData *)value;
- (void)addWordsData:(NSSet *)value;
- (void)removeWordsData:(NSSet *)value;

@end

