//
//  NMChatDetailViewController.h
//  NeverMissed
//
//  Created by William Emmanuel on 10/20/15.
//  Copyright © 2015 William Emmanuel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface NMChatDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *schoolLabel;
@property (weak, nonatomic) IBOutlet UILabel *interest1;
@property (weak, nonatomic) IBOutlet UILabel *interest2;
@property (weak, nonatomic) IBOutlet UILabel *interest3;
@property (nonatomic, strong) PFUser * connectionUser;
@property (nonatomic, strong) PFObject* connection;

@end
