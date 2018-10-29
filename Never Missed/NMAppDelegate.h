//
//  NMAppDelegate.h
//  Never Missed
//
//  Created by William Emmanuel on 8/9/14.
//  Copyright (c) 2014 William Emmanuel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Foursquare2.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "Foursquare2.h"
@import CoreLocation;
@interface NMAppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) CLLocationManager* locationManager;
@property (strong, nonatomic) CLLocation* location;
@property (strong, nonatomic) NSArray* venues;
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) UINavigationController *navController;
@property (nonatomic,retain) NSString *deviceToken;
@property (nonatomic,retain) NSString *fbToken;
- (void)registerLocation;
@end
