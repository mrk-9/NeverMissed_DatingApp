//
//  NMSettingsViewController.h
//  Never Missed
//
//  Created by William Emmanuel on 8/9/14.
//  Copyright (c) 2014 William Emmanuel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface NMSettingsViewController : UIViewController <PFLogInViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBar;

@property (weak, nonatomic) IBOutlet UIButton *homeButton;
@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureBackground;
- (IBAction)logoutPressed:(id)sender;
- (IBAction)closePressed:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end
