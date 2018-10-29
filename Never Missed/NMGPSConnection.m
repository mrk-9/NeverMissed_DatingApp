//
//  NMGPSConnection.m
//  Never Missed
//
//  Created by William Emmanuel on 8/20/14.
//  Copyright (c) 2014 William Emmanuel. All rights reserved.
//

#import "NMLikeToConnectViewController.h"

static const int SEVEN_DAY_AGO_SECONDS = -604800;

@implementation NMGPSConnection

-(id) init {
    self = [super init];
    if(self) {
        self.pfobject = [PFObject objectWithClassName:@"Posting"];
        [self.pfobject setObject:@"gps" forKey:@"type"];
    }
    return self;
}

-(id) initWithParseObject:(PFObject*) object {
    self = [super initWithParseObject:object];
    if (self) {
        PFGeoPoint *loc = [object objectForKey:@"location"];
        self.location = [[CLLocation alloc] initWithLatitude:loc.latitude longitude:loc.longitude];
    }
    return self;
}

-(void) setLocation:(CLLocation *)location {
    _location = location;
    if(self.pfobject) {
        PFGeoPoint *newLocation = [PFGeoPoint geoPointWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
        [self.pfobject setObject:newLocation forKey:@"location"];
    }
}

-(void)searchForMatches {
    NSDate* now = [NSDate date];
    NSDate* sevenDaysAgo = [now dateByAddingTimeInterval:SEVEN_DAY_AGO_SECONDS];
    
    PFQuery *matchQuery = [PFQuery queryWithClassName:@"Posting"];
    [matchQuery whereKey:@"type" equalTo:@"gps"];
    [matchQuery whereKey:@"createdAt" greaterThanOrEqualTo:sevenDaysAgo];
    PFGeoPoint *queryLocation = [PFGeoPoint geoPointWithLatitude:self.location.coordinate.latitude longitude:self.location.coordinate.longitude];
    [matchQuery includeKey:@"postedBy"]; 
    [matchQuery whereKey:@"location" nearGeoPoint:queryLocation withinMiles:2.0];
    [matchQuery findObjectsInBackgroundWithTarget:self selector:@selector(dealWithPossibleMatches:error:)];
    PFUser *currentUser = [PFUser currentUser];
    // TODO - check this out...not sure if this is right
    if ([[currentUser objectForKey:@"always_on"] intValue] == 1) {
        PFQuery *alwaysOnQuery = [PFQuery queryWithClassName:@"_User"];
        [alwaysOnQuery whereKey:@"always_on" equalTo:@YES];
        queryLocation = [PFGeoPoint geoPointWithLatitude:self.location.coordinate.latitude longitude:self.location.coordinate.longitude];
        [alwaysOnQuery whereKey:@"location" nearGeoPoint:queryLocation withinMiles:2.0];
        [alwaysOnQuery findObjectsInBackgroundWithTarget:self selector:@selector(dealWithPossibleAlwaysOnMatches:error:)];
    }
}

-(void)dealWithPossibleAlwaysOnMatches:(id)result error:(NSError *)error {
    if(result == nil) {
        // error catching
        return;
    }
    NSMutableArray *matches = [NSMutableArray new];
    for(PFUser *possibleMatch in (NSArray*)result) {
        if([self isAlwaysOnMatch:possibleMatch])
            [matches addObject:possibleMatch];
    }
    for(PFUser *match in matches) {
        // launch modal view controller
        // prompt user--would you be interested in the always on match? 
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        NMLikeToConnectViewController *myVC = (NMLikeToConnectViewController *)[storyboard instantiateViewControllerWithIdentifier:@"LikeToConnectModal"];
        myVC.connectedUser = match;
        myVC.connection = self;
        UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
        while (topController.presentedViewController) {
            topController = topController.presentedViewController;
        }
        // how to stop multiple presentations??
        [topController presentViewController:myVC animated:YES completion:nil];
    }
}

-(BOOL) isAlwaysOnMatch:(PFUser*) user {
    PFUser *currentUser = [PFUser currentUser];
    int score = 0;
    [currentUser fetchIfNeeded];
    // if genders and attrativeness does not match up
    if([user.objectId isEqualToString:currentUser.objectId]) {
        return NO;
    }
    if(! [[currentUser objectForKey:@"interestedIn"] isEqualToString:[user objectForKey:@"gender"]]) {
        return NO;
    }
    if(! [[user objectForKey:@"interestedIn"] isEqualToString:[currentUser objectForKey:@"gender"]]) {
        return NO;
    }
    // hair color
    if([self.hairColor isEqualToString:[user objectForKey:@"hairColor"]]) {
        score += 2;
    }
    // hair length
    if([self.hairLength isEqualToString:[user objectForKey:@"hairLength"]]) {
        score += 2;
    }
    // height in inches
    int myHeight = [[currentUser objectForKey:@"heightInInches"] intValue];
    int theirHeight = [[user objectForKey:@"heightInInches"] intValue];
    int heightDifference = abs(myHeight - theirHeight);
    if(heightDifference < 3) {
        score += 3;
    } else if (heightDifference < 5) {
        score += 1;
    }
    if (score > 3) {
        return YES;
    } else  {
        return NO;
    }
}

-(void) saveToParseEventually {
    self.pfobject[@"hairColor"] = self.hairColor;
    self.pfobject[@"hairLength"] = self.hairLength;
    self.pfobject[@"clothingColor"] = self.clothingColor;
    if(self.patterned){
        self.pfobject[@"patterned"] = @YES;
    }
    else self.pfobject[@"patterned"] = @NO;
    if(self.hat){
        self.pfobject[@"hat"] = @YES;
    }
    else self.pfobject[@"hat"] = @NO;
    
    if(self.publicConnection){
        self.pfobject[@"public"] = @YES;
    }
    else self.pfobject[@"public"] = @NO;
    
    self.pfobject[@"heightInInches"] = @(self.heightInInches);
    if(self.myHat){
        self.pfobject[@"myHat"] = @YES;
    }
    else self.pfobject[@"myHat"] = @NO;
    
    if(self.myPatterned){
        self.pfobject[@"myPatterned"] = @YES;
    }
    else self.pfobject[@"myPatterned"] = @NO;
    self.pfobject[@"myClothingColor"] = self.myClothingColor;
    self.pfobject[@"myShoeHeight"] = @(self.myShoeHeight);
    self.pfobject[@"postedBy"] = self.postedBy;
    
    if(self.hasConnectivity){
        NSLog(@"Saving in the background");
        [self.pfobject saveInBackgroundWithTarget:self selector:@selector(scheduleNotification)];
    }
    else{
        NSLog(@"Saving eventually");
        // If we don't have connectivity, then the 30 minute notification will not be scheduled
        [self.pfobject saveEventually];
    }
}

@end
