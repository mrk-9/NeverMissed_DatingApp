//
//  NMCache.h
//  NeverMissed
//
//  Created by Aaron Preston on 5/11/16.
//  Copyright © 2016 William Emmanuel. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MAX_INTERESTED_USERS 20

@interface NMCache : NSObject

+(NMCache*)sharedCache;

-(void)checkInToVenue:(NSString*)venueID;
-(BOOL)hasCheckedInToVenue:(NSString*)venueID;
-(NSMutableArray*)interestedInUsersAtVenue:(NSString*)venueID;
-(void)setInterestedInUsers:(NSMutableArray*)interestedInUsers atVenue:(NSString*)venueID;

-(NSMutableArray*)interestedInUsersAtVenues:(NSString*)venueID;

@end
