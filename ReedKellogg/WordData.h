//
//  WordData.h
//  NavigationTest
//
//  Created by Stephen Mayhew on 2/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface WordData :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * wdRotation;
@property (nonatomic, retain) NSNumber * wdx;
@property (nonatomic, retain) NSNumber * wdIndex;
@property (nonatomic, retain) NSNumber * wdy;

@end



