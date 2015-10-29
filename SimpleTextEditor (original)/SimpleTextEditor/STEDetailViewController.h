//
//  STEDetailViewController.h
//  SimpleTextEditor
//
//  Created by Jason Tsai on 7/30/14.
//  Copyright (c) 2014 nick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STESimpleTextDocument.h"
#import "RNCryptor.h"
#import "RNCryptor+Private.h"
#import "RNCryptorEngine.h"
#import "RNEncryptor.h"
#import "RNDecryptor.h"
#import <CommonCrypto/CommonCryptor.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "Smc361.h"
#import <AVFoundation/AVBase.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSDate.h>	/* for NSTimeInterval */
#import <AvailabilityMacros.h>
#import <CoreAudio/CoreAudioTypes.h>
@interface STEDetailViewController : UIViewController <UISplitViewControllerDelegate,STESimpleTextDocumentDelegate>
{
    Smc361Device *mSmc361Device;
}
@property (strong, nonatomic) NSString* date2;
@property (strong, nonatomic) NSString* pairid;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spin;

@property (strong, nonatomic) NSURL* detailItem;
@property (weak, nonatomic) IBOutlet UIButton *encrypt;
@property (weak, nonatomic) IBOutlet UIButton *decrypt;
@property (strong, nonatomic) NSString* masterTitle1;
@property (strong, nonatomic) IBOutlet UITextField *masterTitle;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property BOOL sound;
@property (strong, nonatomic) IBOutlet UILabel *dateN;

@property (weak, nonatomic) IBOutlet UITextView *textView;
- (IBAction)encrypt:(id)sender;
- (IBAction)decrypt:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *datee;

@property int num;
- (IBAction)passWord:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *pass;
@property(strong)NSString *navTitle;
@end
