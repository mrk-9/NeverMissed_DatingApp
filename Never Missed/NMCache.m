//
//  NMCache.m
//  NeverMissed
//
//  Created by Aaron Preston on 5/11/16.
//  Copyright © 2016 William Emmanuel. All rights reserved.
//

#import "NMCache.h"

#define CACHE_NAME @"NMCache"
#define VENUE_ID_KEY @"venueID"
#define LAST_CHECKIN_TIME_KEY @"lastCheckInTime"
#define INTERESTED_USERS_KEY @"interestedUsers"
#define FOUR_HOURS_AGO -3600*4

@interface NMCache ()

@property (strong, nonatomic) NSUserDefaults* userDefaults;



@end


@implementation NMCache

+(NMCache*)sharedCache {
    static NMCache* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(id)init {
    if(self = [super init]) {
        self.userDefaults = [NSUserDefaults standardUserDefaults];
    }
    
    return self;
}

-(NSMutableArray*)getCache {
    NSMutableArray* _cache = [self.userDefaults objectForKey:CACHE_NAME];
    if(_cache == nil){
        _cache = [NSMutableArray array];
    }
    else {
        _cache = [NSMutableArray arrayWithArray:_cache];
    }
    return _cache;
}

-(void)setCache:(NSMutableArray*)cache {
    [self.userDefaults setObject:cache forKey:CACHE_NAME];
    [self.userDefaults synchronize];
}

-(void)checkInToVenue:(NSString*)venueID {
    NSMutableArray* cache = [self getCache];
    
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"%K = %@",VENUE_ID_KEY,venueID];
    NSArray *filteredContacts = [cache filteredArrayUsingPredicate:filter];
    
    if([filteredContacts count] == 0) {
        NSMutableDictionary* checkInDictionary = [NSMutableDictionary dictionary];
        [checkInDictionary setObject:venueID forKey:VENUE_ID_KEY];
        [checkInDictionary setObject:[NSDate date] forKey:LAST_CHECKIN_TIME_KEY];
        [checkInDictionary setObject:[NSMutableArray array] forKey:INTERESTED_USERS_KEY];
        [cache addObject:checkInDictionary];
        
    }
    else {
        for(NSDictionary* venueCheckIn in filteredContacts) {
            [cache removeObject:venueCheckIn];
        }
        NSMutableDictionary* checkInDictionary = [NSMutableDictionary dictionary];
        [checkInDictionary setObject:venueID forKey:VENUE_ID_KEY];
        [checkInDictionary setObject:[NSDate date] forKey:LAST_CHECKIN_TIME_KEY];
        [checkInDictionary setObject:[NSMutableArray array] forKey:INTERESTED_USERS_KEY];
        [cache addObject:checkInDictionary];
        
    }
    [self setCache:cache];
}

-(BOOL)hasCheckedInToVenue:(NSString*)venueID {
    BOOL hasCheckedIn = NO;
    
    NSMutableArray* cache = [self getCache];
    
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"%K = %@",VENUE_ID_KEY,venueID];
    NSArray *filteredContacts = [cache filteredArrayUsingPredicate:filter];
    
    if([filteredContacts count] != 0){
        for(NSDictionary* venueCheckIn in filteredContacts) {
            NSDate* lastCheckInTime = (NSDate*)[venueCheckIn objectForKey:LAST_CHECKIN_TIME_KEY];
            NSDate* fourHoursAgo = [[NSDate date] dateByAddingTimeInterval:FOUR_HOURS_AGO];
            if([lastCheckInTime compare:fourHoursAgo] == NSOrderedDescending || [lastCheckInTime compare:fourHoursAgo] == NSOrderedSame) {
                hasCheckedIn = YES;
            }
            else {
                [cache removeObject:venueCheckIn];
            }
        }
        [self setCache:cache];
    }
    
    return hasCheckedIn;
}

-(NSMutableArray*)interestedInUsersAtVenue:(NSString*)venueID {
    NSMutableArray* cache = [self getCache];
    
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"%K = %@",VENUE_ID_KEY,venueID];
    NSArray* filteredContacts = [cache filteredArrayUsingPredicate:filter];
    if([filteredContacts count] != 0){
        NSMutableArray* interestedUsers = [NSMutableArray array];
        for(NSDictionary* venueCheckIn in filteredContacts) {
            NSDate* lastCheckInTime = (NSDate*)[venueCheckIn objectForKey:LAST_CHECKIN_TIME_KEY];
            NSDate* fourHoursAgo = [[NSDate date] dateByAddingTimeInterval:FOUR_HOURS_AGO];
            if([lastCheckInTime compare:fourHoursAgo] == NSOrderedDescending || [lastCheckInTime compare:fourHoursAgo] == NSOrderedSame) {
                [interestedUsers addObjectsFromArray:[venueCheckIn objectForKey:INTERESTED_USERS_KEY]];
            }
            else {
                [cache removeObject:venueCheckIn];
            }
        }
        [self setCache:cache];
        return interestedUsers;
    }
    else {
        return [NSMutableArray array];
    }
}

-(void)setInterestedInUsers:(NSMutableArray*)interestedInUsers atVenue:(NSString*)venueID {
    
    NSMutableArray* cache = [self getCache];
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"%K = %@",VENUE_ID_KEY,venueID];
    NSArray* filteredContacts = [cache filteredArrayUsingPredicate:filter];
    if([filteredContacts count] != 0){
        for(NSDictionary* venueCheckIn in filteredContacts) {
            NSMutableDictionary* checkIn = [NSMutableDictionary dictionaryWithDictionary:venueCheckIn];
            [checkIn setObject:interestedInUsers forKey:INTERESTED_USERS_KEY];
            [cache removeObject:venueCheckIn];
            [cache addObject:checkIn];
        }
        
        [self setCache:cache];
        
    }
}



@end
