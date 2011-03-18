//
//  PasswordEntryDelegate.h
//  ReedKellogg
//
//  Created by Christopher J. Covert on 3/17/11.
//  Copyright 2011 Rose-Hulman Institute of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol PasswordEntryDelegate

@optional
- (void) passwordEntryAcceptPressed:(NSString *) password;

@end
