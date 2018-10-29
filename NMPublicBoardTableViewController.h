//
//  NMPublicBoardTableViewController.h
//  NeverMissed
//
//  Created by Tom Mignone on 5/18/15.
//  Copyright (c) 2015 William Emmanuel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMConnection.h"
#import "NMGPSConnection.h"
#import "NMPlaneConnection.h"
#import <CoreLocation/CoreLocation.h>
#import "NMTrainConnection.h"

@interface NMPublicBoardTableViewController : UITableViewController <CLLocationManagerDelegate>


@property (nonatomic, strong) NSMutableArray *connectionArray;
@property (nonatomic, strong) NSMutableArray *connectionDetailsArray;

@property (nonatomic, strong) NSString *boardLocation;
@property (nonatomic, strong) PFGeoPoint *publicLocationCoordinates;


@end
