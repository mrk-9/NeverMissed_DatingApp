//
//  NMPublicTrainConnectionDetailsViewController.h
//  NeverMissed
//
//  Created by Tom Mignone on 5/31/15.
//  Copyright (c) 2015 William Emmanuel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface NMPublicTrainConnectionDetailsViewController : UIViewController


@property (nonatomic, strong) PFObject * connection;

@property (weak, nonatomic) IBOutlet UILabel *lookingFordescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *trainLabel;

- (IBAction)matchButtonWasPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *postedByDescriptionLabel;

@end
