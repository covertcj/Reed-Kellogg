//
//  Layout.h
//  ReedKellogg
//
//  Created by Prodvend04 on 3/16/11.
//  Copyright 2011 RHIT. All rights reserved.
//

#import <CoreData/CoreData.h>

@class LineData;
@class Sentence;
@class Student;
@class WordData;

@interface Layout :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * comments;
@property (nonatomic, retain) NSNumber * grade;
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

