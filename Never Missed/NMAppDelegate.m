//
//  NMAppDelegate.m
//  Never Missed
//
//  Created by William Emmanuel on 8/9/14.
//  Copyright (c) 2014 William Emmanuel. All rights reserved.
//

#import "NMAppDelegate.h"
#import <Parse/Parse.h>
#import "NMPickConnectionTypeViewController.h"
#import "NMLoginViewController.h"
#import "NMChatViewController.h"
#import "NMConnectionAttributesViewController.h"
#import "NMConnectionModalViewController.h"
#import "NMConnectionsTableViewController.h"
#import "NMLikeToConnectTwoViewController.h"
#import "NMMakeConnectionPublicViewController.h"
#import "ALAlertBanner.h"
//#import <Crashlytics/Crashlytics.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "FSConverter.h"
@import CoreLocation;
@implementation NMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
  //  [Crashlytics startWithAPIKey:@"68fbb33cdb672eedb2c1d327e63498f0e3df7d8a"];
    // This is the final production parse account
    
    [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        configuration.applicationId = @"ottfTzcL5a1EKz32Kkxq0o3aq0v6D1ks2Hq8XQLG";
        configuration.clientKey = @"tul15SBx8C3dPq2UsG1vcDsQZULP0bL2IGS8r28F";
        //configuration.server = @"https://never-missed-prod.herokuapp.com/parse";
        configuration.server = @"https://never-missed-dev.herokuapp.com/parse";
    }]];
    //https://never-missed-dev.herokuapp.com/parse
    //[Parse setApplicationId:@"ottfTzcL5a1EKz32Kkxq0o3aq0v6D1ks2Hq8XQLG"
    //              clientKey:@"tul15SBx8C3dPq2UsG1vcDsQZULP0bL2IGS8r28F"];
     //This is tom & will testing parse account
    //[Parse setApplicationId:@"I3Kr7d6I9Jap3DR7mNkOEkvMCssr44rSxiGQZObi"
     //           clientKey:@"6MZXIKzZmhulOVLRmKIsQMhFwZnPPYPqoD9n5LGR"];

    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    [Foursquare2 setupFoursquareWithClientId:@"NQRJ5LN1JHPQEDJ3MDEBRNPIQZ25KIG3H4LAGLYHOF0ICXXG"
                                      secret:@"1G1F2OYYZ0R55ASODW03JEIBW3ZBRFWA034GUI5444O413MZ"
                                 callbackURL:@"Never_Missed://foursquare"];
    
    // Register for Push Notifications
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    
    
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    
    
    //Dumb hack for now. Alternative is "-all_load -ObjC" linker flags. Will look into it later.
    [PFImageView class];
    [self registerLocation];
    
    return YES;
}


- (void)registerLocation
{
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    [self.locationManager requestWhenInUseAuthorization];
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    NSString * deviceTokenString = [[[[deviceToken description]
                                      stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                     stringByReplacingOccurrencesOfString: @">" withString: @""]
                                    stringByReplacingOccurrencesOfString: @" " withString: @""];
    self.deviceToken = deviceTokenString;
    NSLog(@"The generated device token string is : %@",deviceTokenString);
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    // three channel subsctiptions happen. nmloginviewcontroller, nmpickconnectiontype, and and here
    // we should look at cutting this down
    [currentInstallation addUniqueObject:@"global" forKey:@"channels"];
    [currentInstallation saveInBackground];
}

-(void)application:(UIApplication*) application didReceiveLocalNotification:(UILocalNotification *)notification {
    BOOL background = (application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground);
    if ([[notification.userInfo objectForKey:@"type"] isEqualToString:@"30min"]) {
        [self didReceive30minNotification:notification.userInfo inBackground:background];
    }
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // Check if app is coming from background or inactive state
    BOOL background = (application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground);
    
    // Call the right method per notification type
    if ([[userInfo objectForKey:@"type"] isEqualToString:@"message"]) {
        [self didReceiveMessageNotification:userInfo inBackground:background];
    }
    else if ([[userInfo objectForKey:@"type"] isEqualToString:@"always_on"]) {
        [self didReceiveAlwaysOnNotification:userInfo inBackground:background];
    }
    else if ([[userInfo objectForKey:@"type"] isEqualToString:@"connection"]) {
        [self didReceiveConnectionNotification:userInfo inBackground:background];
    }
}

# pragma mark - notification handling methods

-(void) didReceiveConnectionNotification:(NSDictionary*)userInfo inBackground:(BOOL)inBackground {
    NSString *connectionId = [userInfo objectForKey:@"connection"];
    PFObject *connection = [PFObject objectWithoutDataWithClassName:@"Connection"
                                                           objectId:connectionId];
    
    [connection fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        // Show photo view controller
        if (!error && [PFUser currentUser]) {
            // Check if we have a local notofication that should be dealt with
            NSString *deletedId = [object objectForKey:@"deletedId"];
            [self checkForLocalNotification:deletedId];
            // Launch new match modal
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            NMConnectionModalViewController *myVC = (NMConnectionModalViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ConnectionModalViewController"];
            PFUser *user1 = connection[@"user1"];
            PFUser *user2 = connection[@"user2"];
            NSString *currentUserID = [PFUser currentUser].objectId;
            PFUser *otherUser;
            if([user1.objectId isEqualToString:currentUserID]) {
                otherUser = user2;
            } else if ([user2.objectId isEqualToString:currentUserID]) {
                otherUser = user1;
            }
            [otherUser fetchIfNeeded];
            myVC.connectedUser = otherUser;
            myVC.connection = object;
            UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
            while (topController.presentedViewController) {
                topController = topController.presentedViewController;
            }
            // how to stop multiple presentations??
            [topController presentViewController:myVC animated:YES completion:nil];
        }
    }];
}

-(void) didReceiveMessageNotification:(NSDictionary*)userInfo inBackground:(BOOL)inBackground {
    if (inBackground) {
        NSString *connectionId = [userInfo objectForKey:@"connection"];
        PFObject *connection = [PFObject objectWithoutDataWithClassName:@"Connection"
                                                               objectId:connectionId];
        // Fetch photo object
        [connection fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            // Show photo view controller
            if (!error && [PFUser currentUser]) {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                NMConnectionsTableViewController *tvc = (NMConnectionsTableViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ConnectionTableViewController"];
                NMChatViewController *viewController = (NMChatViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
                
                PFUser *user1 = connection[@"user1"];
                PFUser *user2 = connection[@"user2"];
                NSString *currentUserID = [PFUser currentUser].objectId;
                PFUser *otherUser;
                if([user1.objectId isEqualToString:currentUserID]) {
                    otherUser = user2;
                } else if ([user2.objectId isEqualToString:currentUserID]) {
                    otherUser = user1;
                }
                [otherUser fetchIfNeeded];
                viewController.connection = object;
                viewController.connectionUser = otherUser;
                [(UINavigationController *)self.window.rootViewController popToRootViewControllerAnimated:NO];
                [(UINavigationController *)self.window.rootViewController pushViewController:tvc animated:NO];
                [(UINavigationController *)self.window.rootViewController pushViewController:viewController animated:YES];
            }
        }];
    } else {
        UINavigationController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
        topController = [topController.viewControllers lastObject];
        if ([topController isKindOfClass:[NMChatViewController class]]) {
            NMChatViewController *vc = (NMChatViewController*) topController;
            if ([[vc.connectionUser objectForKey:@"name"] isEqualToString:[userInfo objectForKey:@"name"]]) {
                return ;
            }
        }
        ALAlertBanner *banner = [ALAlertBanner alertBannerForView:topController.view
                                                            style:ALAlertBannerStyleSuccess
                                                         position:ALAlertBannerPositionTop
                                                            title:[NSString stringWithFormat:@"New Message from %@", [userInfo objectForKey:@"name"]]
                                                         subtitle:[userInfo objectForKey:@"messageBody"]];
        [banner show];
    }
}

-(void) didReceive30minNotification:(NSDictionary*)userInfo inBackground:(BOOL)inBackground {
    NSString *connectionId = [userInfo objectForKey:@"id"];
    PFObject *connection = [PFObject objectWithoutDataWithClassName:@"Posting"
                                                           objectId:connectionId];
    
    [connection fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        // Show photo view controller
        if (!error && [PFUser currentUser]) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            NMMakeConnectionPublicViewController *myVC = (NMMakeConnectionPublicViewController *)[storyboard instantiateViewControllerWithIdentifier:@"MakeConnectionPublic"];
            NMGPSConnection *connection = [[NMGPSConnection alloc] initWithParseObject:object];
            myVC.connection = connection;
            UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
            while (topController.presentedViewController) {
                topController
                = topController.presentedViewController;
            }
            // how to stop multiple presentations??
            [topController presentViewController:myVC animated:YES completion:nil];
        }
    }];
}

-(void) didReceiveAlwaysOnNotification:(NSDictionary*)userInfo inBackground:(BOOL)inBackground {
    NSString *connectionId = [userInfo objectForKey:@"connection"];
    PFObject *connection = [PFObject objectWithoutDataWithClassName:@"Posting"
                                                           objectId:connectionId];
    
    [self deleteNotificationFromParse:[userInfo objectForKey:@"notification"]];
    
    [connection fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        // Show photo view controller
        if (!error && [PFUser currentUser]) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            NMLikeToConnectTwoViewController *myVC = (NMLikeToConnectTwoViewController *)[storyboard instantiateViewControllerWithIdentifier:@"LikeToConnectTwo"];
            myVC.connectedUser = [object objectForKey:@"postedBy"];
            NMConnection *connection ;
            if ([[object objectForKey:@"type"] isEqualToString:@"plane"]) {
                connection = [[NMPlaneConnection alloc] initWithParseObject:object];
            } else if ([[object objectForKey:@"type"] isEqualToString:@"train"]) {
                connection = [[NMTrainConnection alloc] initWithParseObject:object];
            } else {
                connection = [[NMGPSConnection alloc] initWithParseObject:object];
            }
            myVC.connection = connection;
            UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
            while (topController.presentedViewController) {
                topController = topController.presentedViewController;
            }
            // how to stop multiple presentations??
            [topController presentViewController:myVC animated:YES completion:nil];
        }
    }];
}

-(void)checkForLocalNotification:(NSString*) deletedId {
    NSMutableArray *localNotifs = [[NSMutableArray alloc] initWithArray:[[UIApplication sharedApplication]scheduledLocalNotifications]];
    for (UILocalNotification* notification in localNotifs) {
        NSString *deletedId=[notification.userInfo valueForKey:@"deletedId"];
        if([notification.userInfo objectForKey:@"deletedId"] && [[notification.userInfo objectForKey:@"deletedId"] isEqualToString:deletedId]) {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }
}

-(void)deleteNotificationFromParse:(NSString*)notification {
    PFQuery *notifQuery = [PFQuery queryWithClassName:@"Notification"];
    [notifQuery getObjectWithId:notification];
    [notifQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        [object deleteInBackground];
    }];
}

# pragma mark - end of notification handling

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    //return [FBAppCall handleOpenURL:url
    //              sourceApplication:sourceApplication
    //                    withSession:[PFFacebookUtils session]];
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //[FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    [FBSDKAppEvents activateApp];
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
/*- (BOOL) application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:nil
                        withSession:[PFFacebookUtils session]];
}*/

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    [self.locationManager stopUpdatingLocation];
    self.location = locations.lastObject;
    NSLog(@"location: %f,%f",self.location.coordinate.latitude, self.location.coordinate.longitude);
    [self searchFSWithString:nil];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"locationManager:didFailWithError");
    [self.locationManager stopUpdatingLocation];
}

#pragma mark - Private Implementation

-(void)searchFSWithString:(NSString*)venue{
                             [Foursquare2
                                venueSearchNearByLatitude:@(self.location.coordinate.latitude)
                                longitude:@(self.location.coordinate.longitude)
                                query:venue
                                limit:nil
                                intent:intentCheckin
                                radius:@(402)
                                categoryId:nil
                                callback:^(BOOL success, id result){
                                    if (success) {
                                        NSDictionary* results = (NSDictionary*)result;
                                        _venues = [results valueForKeyPath:@"response.venues"];
                                        FSConverter *converter = [[FSConverter alloc] init];
                                        _venues = [converter convertToObjects:_venues];
                                        if ([PFUser currentUser]) {
                                            PFUser *currentUser = [PFUser currentUser];
                                            [currentUser setObject:[NSString stringWithFormat:@"%f",self.location.coordinate.longitude] forKey:@"longitude"];
                                            [currentUser setObject:[NSString stringWithFormat:@"%f",self.location.coordinate.latitude] forKey:@"latitude"];
                                            [currentUser setObject:_venues forKey:@"venues"];
                                            [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                                NSLog(@"ERROR -->%@",error);
                                            }];
                                        }
                                       
                                    } else {
                                        NSLog(@"%@",result);
                                    }
                                    
                                }];
}
@end
