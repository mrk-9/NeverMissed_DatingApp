//
//  NMCheckForInterestedSingleton.h
//  NeverMissed
//
//  Created by William Emmanuel on 6/1/15.
//  Copyright (c) 2015 William Emmanuel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface NMCheckForNotificationsSingleton : NSObject

@property (nonatomic, strong) NSMutableArray *interestedPeople; 

+ (id)shared;

- (void)checkForNotifications;

@end
