//
//  STEMasterViewController.h
//  SimpleTextEditor
//
//  Created by Jason Tsai on 7/30/14.
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
@class STEDetailViewController;

@interface STEMasterViewController : UITableViewController<UISearchBarDelegate,Smc361ProtocolDelegate>
{
    Smc361Device *mSmc361Device;
}
@property (strong, nonatomic) STEDetailViewController *detailViewController;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property NSString *docName;
- (IBAction)addDocument:(id)sender;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
 @property (strong,nonatomic) NSMutableArray *filteredArray;
 
@end
