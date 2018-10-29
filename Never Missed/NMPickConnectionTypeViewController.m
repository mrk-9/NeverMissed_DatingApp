//
//  NMPickConnectionTypeViewController.m
//  Never Missed
//
//  Created by William Emmanuel on 9/29/14.
//  Copyright (c) 2014 William Emmanuel. All rights reserved.
//
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "NMPickConnectionTypeViewController.h"
#import "NMGPSConnection.h"
#import "NMConnectionAttributesViewController.h"
#import "NMSettingsViewController.h"
#import "NMLoginViewController.h"
#import "NMFirstRunSettingsViewController.h"
#import "NMGPSSingleton.h"
#import "NMCheckForNotificationsSingleton.h"

@interface NMPickConnectionTypeViewController ()

@end

@implementation NMPickConnectionTypeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    _didFindLocation = NO;
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed: 0.0f/255.0f
                                                                           green:81.0f/255.0f
                                                                            blue:81.0f/255.0f
                                                                           alpha:1.0f];;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:19.0];
    label.textAlignment = NSTextAlignmentCenter;
    // ^-Use UITextAlignmentCenter for older SDKs.
    label.textColor = [UIColor whiteColor]; // change this color
    self.navigationItem.titleView = label;
    label.text = @"NeverMissed";
    [label sizeToFit];
    
    _manager = [[CLLocationManager alloc] init];
    _manager.delegate = self;
    _manager.desiredAccuracy = kCLLocationAccuracyBest;
    _manager.distanceFilter = kCLDistanceFilterNone;
	[_GPSButton addTarget:self action:@selector(GPSButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    if ([PFUser currentUser] && // Check if user is cached
        [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [currentInstallation addUniqueObject:[NSString stringWithFormat:@"user_%@", [PFUser currentUser].objectId] forKey:@"channels"];
        [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        }];
    }
    PFUser *currentUser = [PFUser currentUser];
    // if always on matching is enabled
    if([[currentUser objectForKey:@"always_on"] intValue] == 1) {
        NMGPSSingleton *shared = [NMGPSSingleton shared];
        [shared startGettingLocation];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _didFindLocation = NO;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)GPSButtonPressed {
    if ([_manager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [_manager requestWhenInUseAuthorization];
    }
    [_manager startUpdatingLocation];
}

# pragma mark - GPS delegates

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    _current = [locations lastObject];
    if (_didFindLocation == YES || _current.coordinate.longitude == 0) {
        return;
    }
    _didFindLocation = YES;
    [_manager stopUpdatingLocation];
    NMGPSConnection *connection = [[NMGPSConnection alloc] init];
    connection.postedBy = [PFUser currentUser];
    connection.location = _current;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NMConnectionAttributesViewController *myVC = (NMConnectionAttributesViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ConnectionAttributesViewController"];
    myVC.connection = connection;
    [self.navigationController pushViewController:myVC animated:YES];
}
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    UIAlertView *gpsAlert = [[UIAlertView alloc] initWithTitle:@"No GPS" message:@"You need GPS permission and signal to use this feature." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    gpsAlert.delegate = self;
    [gpsAlert show];
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    
    if (username && password && username.length != 0 && password.length != 0) {
        return YES; // Begin login process
    }
    [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                message:@"Make sure you fill out all of the information!"
                               delegate:nil
                      cancelButtonTitle:@"ok"
                      otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation addUniqueObject:[NSString stringWithFormat:@"user_%@", [PFUser currentUser].objectId] forKey:@"channels"];
    [currentInstallation saveInBackgroundWithBlock:nil];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
}

- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

@end
