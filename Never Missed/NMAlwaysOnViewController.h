//
//  NMAlwaysOnViewController.h
//  NeverMissed
//
//  Created by William Emmanuel on 4/24/15.
//  Copyright (c) 2015 William Emmanuel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface NMAlwaysOnViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISwitch *alwaysOnToggle;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@end
