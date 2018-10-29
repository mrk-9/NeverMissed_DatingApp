//
//  NMPublicLocationConnectionDetailsViewController.h
//  NeverMissed
//
//  Created by Tom Mignone on 5/31/15.
//  Copyright (c) 2015 William Emmanuel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <MapKit/MapKit.h>

@interface NMPublicLocationConnectionDetailsViewController : UIViewController

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic, strong) PFObject * connection;


@property (weak, nonatomic) IBOutlet UILabel *lookingFordescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;

- (IBAction)matchButtonWasPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *postedByDescriptionLabel;


@end
