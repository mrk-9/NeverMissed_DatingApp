//
//  NMGPSConnection.h
//  Never Missed
//
//  Created by William Emmanuel on 8/20/14.
//  Copyright (c) 2014 William Emmanuel. All rights reserved.
//

#import "NMConnection.h"
#import <CoreLocation/CoreLocation.h>
#import "NMGPSSingleton.h"

@interface NMGPSConnection : NMConnection

@property (nonatomic, strong) CLLocation *location;

-(BOOL) isAlwaysOnMatch:(PFUser*) user;
-(void) eventuallySaveToParse;
-(void) saveToParseEventually;

@end
