//
//  NMCheckForInterestedSingleton.m
//  NeverMissed
//
//  Created by William Emmanuel on 6/1/15.
//  Copyright (c) 2015 William Emmanuel. All rights reserved.
//

#import "NMCheckForNotificationsSingleton.h"
#import "NMLikeToConnectTwoViewController.h"
#import "NMGPSConnection.h"
#import "NMPlaneConnection.h"
#import "NMTrainConnection.h"
#import "NMConnection.h"

@implementation NMCheckForNotificationsSingleton

+ (id)shared {
    static NMCheckForNotificationsSingleton *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (id)init {
    if (self = [super init]) {
        _interestedPeople = [[NSMutableArray alloc] init]; 
    }
    return self;
}

-(void)checkForNotifications {
    PFQuery *query = [PFQuery queryWithClassName:@"Notification"];
    [query whereKey:@"for" equalTo:[PFUser currentUser]];
    [query includeKey:@"for"];
    [query includeKey:@"from"];
    [query includeKey:@"posting"];
    [query findObjectsInBackgroundWithTarget:self selector:@selector(dealWithNotifications:error:)];
}

-(void)dealWithNotifications:(id)result error:(NSError *)error {
    for(PFObject *notification in result) {
        NSString *type = [notification objectForKey:@"type"];
        if([type isEqualToString:@"always_on"]) {
            [self dealWithAlwaysOnNotification:notification];
        }
    }
}

-(void) dealWithAlwaysOnNotification:(PFObject*)notification {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NMLikeToConnectTwoViewController *myVC = (NMLikeToConnectTwoViewController *)[storyboard instantiateViewControllerWithIdentifier:@"LikeToConnectTwo"];
    myVC.connectedUser = [notification objectForKey:@"from"];
    NMGPSConnection *connection = [[NMGPSConnection alloc] initWithParseObject:[notification objectForKey:@"posting"]];
    myVC.connection = connection;
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    [notification deleteInBackground];
    // how to stop multiple presentations??
    [topController presentViewController:myVC animated:YES completion:nil];
}

@end
