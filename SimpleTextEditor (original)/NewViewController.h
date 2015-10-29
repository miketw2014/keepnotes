//
//  NewViewController.h
//  SimpleTextEditor
//
//  Created by Jason Tsai on 8/7/14.
//  Copyright (c) 2014 nick. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "Smc361.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "Smc361.h"
#import <AVFoundation/AVBase.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSDate.h>	/* for NSTimeInterval */
#import <AvailabilityMacros.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "PTKEntryCell.h"
#import "CMPopTipView.h"
@class STEDetailViewController;

@interface NewViewController : UIViewController<UITableViewDataSource,UITableViewDelegate, UISearchBarDelegate,Smc361ProtocolDelegate,UIToolbarDelegate,UITextFieldDelegate,CMPopTipViewDelegate>
{
     IBOutlet UITableView *Table;
    Smc361Device *mSmc361Device;
   
}
@property(strong,nonatomic)UIImageView *main;
@property(strong,nonatomic)UIImageView *main1;
 @property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spin;
@property (nonatomic, retain) UITableView*  Table;
@property (strong, nonatomic) STEDetailViewController *detailViewController;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property NSString *docName;
@property UILabel *labelOne ;
- (IBAction)addDocument:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *del;

- (IBAction)del:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *pair;
- (IBAction)pair:(id)sender;

 
 
@property (strong,nonatomic) NSMutableArray *filteredArray;
@end
