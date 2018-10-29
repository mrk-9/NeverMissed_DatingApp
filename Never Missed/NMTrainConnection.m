//
//  NMTrainConnection.m
//  Never Missed
//
//  Created by William Emmanuel on 10/6/14.
//  Copyright (c) 2014 William Emmanuel. All rights reserved.
//

#import "NMTrainConnection.h"

static const int SEVEN_DAY_AGO_SECONDS = -604800;

@implementation NMTrainConnection

-(id) init {
    self = [super init];
    if(self) {
        self.pfobject = [PFObject objectWithClassName:@"Posting"];
        [self.pfobject setObject:@"train" forKey:@"type"];
    }
    return self;
}

-(id) initWithParseObject:(PFObject *)object {
    self = [super initWithParseObject:object];
    if(self) {
        _railway = [object objectForKey:@"railway"];
        _trainNo = [object objectForKey:@"trainNo"];
    }
    return self;
}

-(void)setRailway:(NSString *)railway {
    _railway = railway;
    if(self.pfobject)
        [self.pfobject setObject:_railway forKey:@"railway"];
}

-(void)setTrainNo:(NSString *)trainNo {
    _trainNo = trainNo;
    if(self.pfobject)
        [self.pfobject setObject:trainNo forKey:@"trainNo"];
}

-(void)searchForMatches {
    PFQuery *matchQuery = [PFQuery queryWithClassName:@"Posting"];
    
    NSDate* now = [NSDate date];
    NSDate* sevenDaysAgo = [now dateByAddingTimeInterval:SEVEN_DAY_AGO_SECONDS];
    [matchQuery whereKey:@"createdAt" greaterThanOrEqualTo:sevenDaysAgo];
    
    [matchQuery whereKey:@"type" equalTo:@"train"]; 
    [matchQuery whereKey:@"railway" equalTo:_railway];
    [matchQuery whereKey:@"trainNo" equalTo:_trainNo];
    [matchQuery includeKey:@"postedBy"];
    [matchQuery findObjectsInBackgroundWithTarget:self selector:@selector(dealWithPossibleMatches:error:)];
}

@end
