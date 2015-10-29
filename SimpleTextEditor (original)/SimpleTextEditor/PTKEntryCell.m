//
//  PTKEntryCell.m
//  PhotoKeeper
//
//  Created by Ray Wenderlich on 4/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PTKEntryCell.h"

@implementation PTKEntryCell

@synthesize titleTextField;
@synthesize subtitleLabel;

//[batstat addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    //[titleTextField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
    

    [UIView animateWithDuration:0.1 animations:^{
        if(editing){
           // titleTextField.enabled = YES;
            //titleTextField.borderStyle = UITextBorderStyleRoundedRect;
        }else{
            //titleTextField.enabled = NO;
             titleTextField.borderStyle = UITextBorderStyleNone;
        }
    }];
    
}
//- (IBAction)end:(id)sender {
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"rename" object:self userInfo:[NSDictionary dictionaryWithObject:self.titleTextField.text forKey:@"Note"]];
//    NSLog(@"yeah inform someone of my change");
//}
//- (void)textFieldDidEndEditing:(UITextField *)textField {
//    
//    NSLog(@"yeah inform someone of my change %@", textField.text);
//}
//
//- (BOOL)textFieldShouldClear:(UITextField *)textField {
//    return YES;
//}
//
//- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//    [textField resignFirstResponder];
//    NSLog(@"cleared");
//    return YES;
//}
//-(void)textChanged:(UITextField *)textField
//{
//    NSLog(@"textfield data %@ ",textField.text);
//}
@end
