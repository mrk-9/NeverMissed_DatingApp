//
//  NMGPSSingleton.m
//  NeverMissed
//
//  Created by William Emmanuel on 4/24/15.
//  Copyright (c) 2015 William Emmanuel. All rights reserved.
//

#import "NMGPSSingleton.h"

@implementation NMGPSSingleton

+ (id)shared {
    static NMGPSSingleton *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (id)init {
    if (self = [super init]) {
        _manager = [[CLLocationManager alloc] init];
        _manager.delegate = self;
        _manager.desiredAccuracy = kCLLocationAccuracyKilometer;
        _manager.distanceFilter = 500;
        _manager.distanceFilter = kCLDistanceFilterNone;
    }
    return self;
}

-(void)startGettingLocation {
    [_manager requestAlwaysAuthorization];
    [_manager startMonitoringSignificantLocationChanges];
}

-(void)stopGettingLocation {
    [_manager stopMonitoringSignificantLocationChanges];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *current = [locations firstObject];
    if (current.coordinate.latitude == 0) {
        return;
    }
    _location = current;
    PFUser *user = [PFUser currentUser];
    PFGeoPoint *newLocation = [PFGeoPoint geoPointWithLatitude:current.coordinate.latitude longitude:current.coordinate.longitude];
    [user setObject:newLocation forKey:@"location"];
    [user saveInBackground];
}
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {

}

@end
