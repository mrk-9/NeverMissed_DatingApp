//
//  NMPublicPlaneConnectionDetailsViewController.h
//  NeverMissed
//
//  Created by Tom Mignone on 5/27/15.
//  Copyright (c) 2015 William Emmanuel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface NMPublicPlaneConnectionDetailsViewController : UIViewController

@property (nonatomic, strong) PFObject * connection;

@property (weak, nonatomic) IBOutlet UILabel *lookingFordescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *planeLabel;

- (IBAction)matchButtonWasPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *postedByDescriptionLabel;

@end
