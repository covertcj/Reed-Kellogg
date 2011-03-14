//
//  addNameViewController.h
//  Locations
//
//  Created by Stephen Mayhew on 1/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol addNameViewControllerDelegate <NSObject>

-(void)didSubmit:(NSString *)string;
-(void)pushTeacher;

@end


@interface addNameViewController : UIViewController {
	id delegate;
	UITextField *nameField;
	UIButton *button;
	UIButton *submitButton;
	NSString *btnTitle;
	NSString *submitBtnTitle;
}

@property (nonatomic, assign) id<addNameViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UITextField * nameField;
@property (nonatomic, retain) IBOutlet UIButton *button;
@property (nonatomic, retain) IBOutlet UIButton *submitButton;
@property (nonatomic, retain) NSString *btnTitle;
@property (nonatomic, retain) NSString *submitBtnTitle;

-(IBAction)buttonPressed:(id)sender;
-(IBAction)teacherPressed:(id)sender;

@end
