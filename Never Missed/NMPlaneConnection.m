//
//  NMPlaneConnection.m
//  Never Missed
//
//  Created by William Emmanuel on 10/6/14.
//  Copyright (c) 2014 William Emmanuel. All rights reserved.
//

#import "NMPlaneConnection.h"

static const int SEVEN_DAY_AGO_SECONDS = -604800;

@implementation NMPlaneConnection

-(id) init {
    self = [super init];
    if(self) {
        self.pfobject = [PFObject objectWithClassName:@"Posting"];
        [self.pfobject setObject:@"plane" forKey:@"type"];
    }
    return self;
}

-(id) initWithParseObject:(PFObject *)object {
    self = [super initWithParseObject:object];
    if(self) {
        _carrier = [object objectForKey:@"carrier"];
        _flightNo = [[object objectForKey:@"flightNo"] intValue];
    }
    return self;
}

-(void)setCarrier:(NSString *)carrier {
    _carrier = carrier;
    if(self.pfobject)
        [self.pfobject setObject:_carrier forKey:@"carrier"];
}

-(void)setFlightNo:(int)flightNo {
    _flightNo = flightNo;
    if(self.pfobject)
        [self.pfobject setObject:@(_flightNo) forKey:@"flightNo"];
}

-(void)searchForMatches {
    
    PFQuery *matchQuery = [PFQuery queryWithClassName:@"Posting"];
    
    NSDate* now = [NSDate date];
    NSDate* sevenDaysAgo = [now dateByAddingTimeInterval:SEVEN_DAY_AGO_SECONDS];
    [matchQuery whereKey:@"createdAt" greaterThanOrEqualTo:sevenDaysAgo];
    
    [matchQuery whereKey:@"type" equalTo:@"plane"]; 
    [matchQuery whereKey:@"carrier" equalTo:_carrier];
    [matchQuery whereKey:@"flightNo" equalTo:@(_flightNo)];
    [matchQuery includeKey:@"postedBy"];
    [matchQuery findObjectsInBackgroundWithTarget:self selector:@selector(dealWithPossibleMatches:error:)];
}

@end
