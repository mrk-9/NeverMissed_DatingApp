//
//  NMGPSSingleton.h
//  NeverMissed
//
//  Created by William Emmanuel on 4/24/15.
//  Copyright (c) 2015 William Emmanuel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <Parse/Parse.h>

@interface NMGPSSingleton : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *manager;
@property (nonatomic, strong) CLLocation *location;

+ (id)shared;

-(void)startGettingLocation;
-(void)stopGettingLocation;

@end
