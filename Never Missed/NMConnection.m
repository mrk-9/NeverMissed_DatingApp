//
//  NMConnection.m
//  Never Missed
//
//  Created by William Emmanuel on 8/19/14.
//  Copyright (c) 2014 William Emmanuel. All rights reserved.
//

#import "NMConnection.h"
#import "NMConnectionModalViewController.h"

#import <sys/socket.h>
#import <netinet/in.h>
#import <SystemConfiguration/SystemConfiguration.h>


@implementation NMConnection

-(id) initWithParseObject:(PFObject*) object {
    self = [super init];
    if (self) {
        _pfobject = object;
        
        _createdAt = object.createdAt;
        _hairColor = [_pfobject objectForKey:@"hairColor"];
        _hairLength = [_pfobject objectForKey:@"hairLength"];
        _clothingColor = [_pfobject objectForKey:@"clothingColor"];
        _patterned = [_pfobject[@"patterned"] boolValue];
        _hat = [_pfobject[@"hat"] boolValue];
        _publicConnection = [_pfobject[@"public"] boolValue];
        _heightInInches = [[_pfobject objectForKey:@"heightInInches"] intValue];
        _myHat = [_pfobject[@"myHat"] boolValue];
        _myPatterned = [_pfobject[@"myPatterned"] boolValue];
        _myClothingColor = [_pfobject objectForKey:@"myClothingColor"];
        _myShoeHeight = [[_pfobject objectForKey:@"myShoeHeight"] intValue];
        _postedBy = [_pfobject objectForKey:@"postedBy"];
    }
    return self;
}

-(void) eventuallySaveToParse {
    [self.pfobject saveInBackgroundWithTarget:self selector:@selector(scheduleNotification)];
}

//-(void) saveToParseEventuallyWithTarget:(id)target andSelector:(SEL)selector {
-(void) saveToParseEventually{
    _pfobject[@"hairColor"] = _hairColor;
    _pfobject[@"hairLength"] = _hairLength;
    _pfobject[@"clothingColor"] = _clothingColor;
    if(_patterned){
        _pfobject[@"patterned"] = @YES;
    }
    else _pfobject[@"patterned"] = @NO;
    if(_hat){
        _pfobject[@"hat"] = @YES;
    }
    else _pfobject[@"hat"] = @NO;
    if(_publicConnection){
        _pfobject[@"public"] = @YES;
    }
    else _pfobject[@"public"] = @NO;
    _pfobject[@"heightInInches"] = @(_heightInInches);
    if(_myHat){
        _pfobject[@"myHat"] = @YES;
    }
    else _pfobject[@"myHat"] = @NO;
    
    if(_myPatterned){
        _pfobject[@"myPatterned"] = @YES;
    }
    else _pfobject[@"myPatterned"] = @NO;
    _pfobject[@"myClothingColor"] = _myClothingColor;
    _pfobject[@"myShoeHeight"] = @(_myShoeHeight);
    _pfobject[@"postedBy"] = _postedBy;
    
    if(self.hasConnectivity){
        NSLog(@"Saving in the background");
        [self.pfobject saveInBackgroundWithTarget:self selector:@selector(scheduleNotification)];
    }
    else{
        NSLog(@"Saving eventually");
        [_pfobject saveEventually];
    }
    //[_pfobject saveInBackgroundWithTarget:target selector:selector];
    
    
}

-(void)setHeightInInches:(int)heightInInches {
    _heightInInches = heightInInches;
    if(_pfobject)
        [_pfobject setObject:@(_heightInInches) forKey:@"heightInInches"];
}

-(void)setMyShoeHeight:(int)myShoeHeight {
    _myShoeHeight = myShoeHeight;
    if(_pfobject)
        [_pfobject setObject:@(_myShoeHeight) forKey:@"myShoeHeight"];
}

-(void)setHairColor:(NSString *)hairColor {
    _hairColor = hairColor;
    if(_pfobject)
        [_pfobject setObject:_hairColor forKey:@"hairColor"];
}

-(void)setHairLength:(NSString *)hairLength {
    _hairLength = hairLength;
    if(_pfobject) {
        [_pfobject setObject:hairLength forKey:@"hairLength"];
    }
}

-(void) setPatterned:(BOOL)patterned {
    _patterned = patterned;
    if(_patterned) {
        if(patterned){
            _pfobject[@"patterned"] = @YES;
        }
        else _pfobject[@"patterned"] = @NO;
    }
}

-(void)setClothingColor:(NSString *)clothingColor {
    _clothingColor = clothingColor;
    if(_clothingColor)
        [_pfobject setObject:clothingColor forKey:@"clothingColor"];
}

-(void)setHat:(BOOL)hat {
    _hat = hat;
    if(_pfobject) {
        if(hat){
            [_pfobject setObject:@YES forKey:@"hat"];
        }
        else [_pfobject setObject:@NO forKey:@"hat"];
    }
}

-(void)setPublicConnection:(BOOL)publicConnection {
    _publicConnection = publicConnection;
    if(_pfobject) {
        if(publicConnection){
            [_pfobject setObject:@YES forKey:@"public"];
        }
        else [_pfobject setObject:@NO forKey:@"public"];
    }
}

-(void)setMyHat:(BOOL)myHat {
    _myHat = myHat;
    if(_pfobject) {
        if(myHat){
            [_pfobject setObject:@YES forKey:@"myHat"];
        }
        else [_pfobject setObject:@NO forKey:@"myHat"];
    }
}

-(void)setMyClothingColor:(NSString *)myClothingColor {
    _myClothingColor = myClothingColor;
    if(_pfobject) {
        [_pfobject setObject:myClothingColor forKey:@"myClothingColor"];
    }
}

-(void)setMyPatterned:(BOOL)myPatterned {
    _myPatterned = myPatterned;
    if(_pfobject) {
        if(myPatterned){
            [_pfobject setObject:@YES forKey:@"myPatterned"];
        }
        else [_pfobject setObject:@NO forKey:@"myPatterned"];
    }
}

-(void) setPostedBy:(PFUser *)postedBy {
    _postedBy = postedBy;
    if(_pfobject) {
        [_pfobject setObject:_postedBy forKey:@"postedBy"];
    }
}

-(void)searchForMatches {
    // stub, override by GPS, Plane, and other connection types
}

-(BOOL) isMatch:(NMConnection *)connection {
    PFUser *poster = [connection.pfobject objectForKey:@"postedBy"];
    NSLog(@"isMatch poster:%@",poster.objectId);
    NSLog(@"userArray (connections):%@",_userArray);
    if ([_userArray containsObject:poster.objectId]) {
        return NO;
    }
    int score = 0;
    PFUser *currentUser = [PFUser currentUser];
    [currentUser fetchIfNeeded];
    if([connection.postedBy.objectId isEqualToString:currentUser.objectId]) {
        return NO;
    }
    // if genders and attrativeness does not match up
    PFUser *otherUser = connection.postedBy;
    if(! [[currentUser objectForKey:@"interestedIn"] isEqualToString:[otherUser objectForKey:@"gender"]]) {
        return NO;
    }
    if(! [[otherUser objectForKey:@"interestedIn"] isEqualToString:[currentUser objectForKey:@"gender"]]) {
        return NO;
    }
    
    // get other user so that the prefrences can be matched!
    // pfquery for other user
    
    // hairColor scoring
    if([connection.hairColor isEqualToString:[currentUser objectForKey:@"hairColor"]]) {
        score += 2;
    }
    // hairLength scoring
    if([connection.hairLength isEqualToString:[currentUser objectForKey:@"hairLength"]]) {
        score += 2;
    }
    // Height scoring
    int myHeight = [[currentUser objectForKey:@"heightInInches"] intValue];
    myHeight += _myShoeHeight;
    int heightDifference = abs(connection.heightInInches - myHeight);
    if(heightDifference < 3) {
        score += 3;
    } else if (heightDifference < 5) {
        score += 1;
    }
    // clothingColor scoring
    if([connection.clothingColor isEqualToString:_myClothingColor]) {
        score += 2;
    }
    // pattern scoring
    if(connection.patterned == _myPatterned) {
        score += 1;
    }
    // hat scoring
    if(connection.hat == _myHat) {
        score += 1;
    }
    
    //Check to see if either user blocked the other user
    PFQuery *usersBlockedByMe = [PFQuery queryWithClassName:@"BlockedUser"];
    [usersBlockedByMe whereKey:@"blocker" equalTo:[PFUser currentUser]];
    PFQuery *usersBlockingMe = [PFQuery queryWithClassName:@"BlockedUser"];
    [usersBlockingMe whereKey:@"user" equalTo:[PFUser currentUser]];
    PFQuery *getConnections = [PFQuery orQueryWithSubqueries:@[usersBlockedByMe,usersBlockingMe]];
    [getConnections includeKey:@"blocker"];
    [getConnections includeKey:@"user"];
    NSArray *results = [getConnections findObjects];
    //For every blocked user entry check to see if the user im about to connect with is blocked me or blocked by me
    for (PFObject* connection in results) {
        PFUser *blockingUser = [connection objectForKey:@"blocker"];
        PFUser *blockedUser = [connection objectForKey:@"user"];
        
        if([blockedUser.objectId isEqualToString:otherUser.objectId]) {
            return NO;
        }
        if([blockingUser.objectId isEqualToString:otherUser.objectId]){
            return NO;
        }
    }
    
    if(score > 4) {
        return YES;
    } else {
        return NO;
    }
}

-(void)dealWithPossibleMatches:(id)result error:(NSError *)error {
    if(result == nil) {
        // error catching
        return;
    }
    _queryReturn = result;
    PFQuery *getConnectionsUser1 = [PFQuery queryWithClassName:@"Connection"];
    [getConnectionsUser1 whereKey:@"user1" equalTo:[PFUser currentUser]];
    PFQuery *getConnectionsUser2 = [PFQuery queryWithClassName:@"Connection"];
    [getConnectionsUser2 whereKey:@"user2" equalTo:[PFUser currentUser]];
    PFQuery *getConnections = [PFQuery orQueryWithSubqueries:@[getConnectionsUser1,getConnectionsUser2]];
    [getConnections includeKey:@"user1"];
    [getConnections includeKey:@"user2"];
    [getConnections findObjectsInBackgroundWithTarget:self selector:@selector(userQueryReturn:error:)];
}

-(void)userQueryReturn:(id)result error:(NSError*)error {
    _userArray = [[NSMutableArray alloc] init];
    //PFUser *current = [PFUser currentUser];
    for (PFObject* connection in result) {
        PFUser *otherUser = [connection objectForKey:@"user1"];
        NSLog(@"user1:%@, user2:%@",[connection objectForKey:@"user1"], [connection objectForKey:@"user2"]);
        if([otherUser.objectId isEqualToString:[PFUser currentUser].objectId]) {
            otherUser = [connection objectForKey:@"user2"];
            [_userArray addObject:otherUser.objectId];
        } else {
            [_userArray addObject:otherUser.objectId];
        }
    }
    NSMutableArray *matches = [NSMutableArray new];
    for(PFObject *possibleMatch in (NSArray*)_queryReturn) {
        NSLog(@"Posting objID:%@",possibleMatch.objectId);
        NMConnection *currentPossibleMatch = [[NMConnection alloc] initWithParseObject:possibleMatch];
        if([self isMatch:currentPossibleMatch])
            [matches addObject:currentPossibleMatch];
    }
    for (NMConnection *match in matches) {
        PFObject *newConnection = [PFObject objectWithClassName:@"Connection"];
        [newConnection setObject:[PFUser currentUser] forKey:@"user1"];
        [newConnection setObject:[match.pfobject objectForKey:@"postedBy"] forKey:@"user2"];
        [newConnection setObject:match.pfobject.objectId forKey:@"deletedId"];
        [newConnection save];
        [match.pfobject deleteEventually];
        [_pfobject deleteEventually];
        
        // send push
        /*PFPush *push = [[PFPush alloc] init];
        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"connection", @"type",
                              newConnection.objectId, @"connection",
                              @"New Connection", @"alert",
                              @"Increment", @"badge",
                              nil];
        
        PFUser *otherUser = [match.pfobject objectForKey:@"postedBy"];
        [push setChannel:[NSString stringWithFormat:@"user_%@", otherUser.objectId]];
        [push setData:data];
        [push sendPushInBackground];*/
        
        // launch modal view controller
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        NMConnectionModalViewController *myVC = (NMConnectionModalViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ConnectionModalViewController"];
        myVC.connectedUser = [match.pfobject objectForKey:@"postedBy"];
        myVC.connection = newConnection;
        UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
        while (topController.presentedViewController) {
            topController = topController.presentedViewController;
        }
        // how to stop multiple presentations??
        [topController presentViewController:myVC animated:YES completion:nil];
    }
}

-(BOOL)hasConnectivity {
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&zeroAddress);
    if(reachability != NULL) {
        SCNetworkReachabilityFlags flags;
        if (SCNetworkReachabilityGetFlags(reachability, &flags)) {
            if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
            {
                return NO;
            }
            
            if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
            {
                return YES;
            }
            
            
            if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
                 (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
            {
                if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
                {
                    return YES;
                }
            }
            
            if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
            {
                return YES;
            }
        }
    }
    
    return NO;
}

-(void) scheduleNotification {
    // create new local notification
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    // schedule 30 min in future
    localNotification.fireDate = [[NSDate date] dateByAddingTimeInterval:1800];
    // for testing
    //localNotification.fireDate = [[NSDate date] dateByAddingTimeInterval:30];
    // add some params with userInfo
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    userInfo[@"type"] = @"30min";
    userInfo[@"id"] = self.pfobject.objectId;
    localNotification.userInfo = userInfo;
    // set text and sound for alert
    localNotification.alertBody = [NSString stringWithFormat:@"Make connection public?"];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    // schedule
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

@end
