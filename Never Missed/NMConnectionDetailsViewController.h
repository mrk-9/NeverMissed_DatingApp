//
//  NMConnectionDetailsViewController.h
//  NeverMissed
//
//  Created by Tom Mignone on 12/23/14.
//  Copyright (c) 2014 William Emmanuel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "NMConnection.h"

@interface NMConnectionDetailsViewController : UIViewController

@property (nonatomic, strong) NMConnection * connection;
@property (nonatomic, strong) PFUser * connectionUser;
@property (weak, nonatomic) IBOutlet UILabel *connectionTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *datePostedLabel;
@property (weak, nonatomic) IBOutlet UILabel *clothingColorLabel;
@property (weak, nonatomic) IBOutlet UILabel *hairColorLabel;
@property (weak, nonatomic) IBOutlet UILabel *hairLengthLabel;
@property (weak, nonatomic) IBOutlet UILabel *hatLabel;
@property (weak, nonatomic) IBOutlet UILabel *heightLabel;

@end
