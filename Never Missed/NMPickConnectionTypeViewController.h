//
//  NMPickConnectionTypeViewController.h
//  Never Missed
//
//  Created by William Emmanuel on 9/29/14.
//  Copyright (c) 2014 William Emmanuel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface NMPickConnectionTypeViewController : UIViewController <CLLocationManagerDelegate, PFLogInViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *GPSButton;
@property (strong, nonatomic) CLLocationManager *manager;
@property (weak, nonatomic) IBOutlet UIButton *currentLocationButton;
@property BOOL didFindLocation;
@property (nonatomic, strong) CLLocation *current;
@end
