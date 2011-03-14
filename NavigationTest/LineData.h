//
//  LineData.h
//  NavigationTest
//
//  Created by Stephen Mayhew on 2/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface LineData :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * x2;
@property (nonatomic, retain) NSNumber * x1;
@property (nonatomic, retain) NSNumber * y2;
@property (nonatomic, retain) NSNumber * y1;

@end



