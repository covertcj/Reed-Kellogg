//
//  LineData.h
//  ReedKellogg
//
//  Created by Christopher J. Covert on 5/10/11.
//  Copyright 2011 Rose-Hulman Institute of Technology. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface LineData :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * x2;
@property (nonatomic, retain) NSNumber * x1;
@property (nonatomic, retain) NSNumber * dashed;
@property (nonatomic, retain) NSNumber * y2;
@property (nonatomic, retain) NSNumber * y1;

@end



