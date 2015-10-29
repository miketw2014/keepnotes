//
//  PTKEntryCell.h
//  PhotoKeeper
//
//  Created by Ray Wenderlich on 4/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Checkbox.h"
@interface PTKEntryCell : UITableViewCell

 
@property (weak, nonatomic) IBOutlet UITextField * titleTextField;
@property (weak, nonatomic) IBOutlet UILabel * subtitleLabel;
@property (nonatomic, weak) IBOutlet Checkbox *checkBox;
@end
