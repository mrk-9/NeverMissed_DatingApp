//
//  NMLocationSelectionViewController.h
//  Never Missed
//
//  Created by William Emmanuel on 11/26/14.
//  Copyright (c) 2014 William Emmanuel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface NMLocationSelectionViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *continueButton;


@end
