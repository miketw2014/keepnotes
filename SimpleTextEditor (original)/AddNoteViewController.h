//
//  AddNoteViewController.h
//  SimpleTextEditor
//
//  Created by Jason Tsai on 7/30/14.
//  Copyright (c) 2014 nick. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddNoteViewController : UIViewController
- (IBAction)save:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *noteName;

- (IBAction)cancel:(id)sender;
@end
