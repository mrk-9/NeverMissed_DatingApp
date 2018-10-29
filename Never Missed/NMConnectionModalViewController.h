//
//  NMConnectionModalViewController.h
//  NeverMissed
//
//  Created by William Emmanuel on 12/19/14.
//  Copyright (c) 2014 William Emmanuel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface NMConnectionModalViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *chatButton;
@property (strong, nonatomic)  PFObject *connection;
@property (strong, nonatomic) PFUser *connectedUser;

@end
