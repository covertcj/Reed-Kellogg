//
//  DiagramInfoViewController.h
//  ReedKellogg
//
//  Created by Christopher J. Covert on 5/16/11.
//  Copyright 2011 Rose-Hulman Institute of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DiagramInfoViewController : UIViewController {
	UIBarButtonItem *doneButton;
}

- (IBAction) done:(id)sender;
@property (nonatomic, retain) UIBarButtonItem *doneButton;

@end
